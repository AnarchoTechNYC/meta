#!/bin/bash -

# Install and set up software dependencies.
apt-get update && apt-get --yes install \
    apt-transport-https ca-certificates curl \
    gnupg-agent software-properties-common \
    conntrack
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
curl -fsSL https://baltocdn.com/helm/signing.asc | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
add-apt-repository "deb https://baltocdn.com/helm/stable/debian/ all main"
apt-get update && apt-get --yes install \
    docker-ce docker-ce-cli containerd.io

usermod -a -G docker vagrant

# Install userland utilities with `asdf` for ease of provisioning.
sudo --login -u vagrant git clone https://github.com/asdf-vm/asdf.git ~vagrant/.asdf --branch v0.9.0
echo "source \$HOME/.asdf/asdf.sh" >> ~vagrant/.bash_profile
echo "source \$HOME/.asdf/completions/asdf.bash" >> ~vagrant/.bash_profile
asdf_tools=(
    helm
    krew
    kubectl
    minikube
)
for tool in "${asdf_tools[@]}"; do
    sudo --login -u vagrant bash -c "asdf plugin add ${tool}; asdf install ${tool} latest; asdf global ${tool} latest"
done
echo 'export PATH="${PATH}:${HOME}/.krew/bin"' >> ~vagrant/.bash_profile
sudo --login -u vagrant kubectl completion bash > /etc/bash_completion.d/kubectl 2>/dev/null
sudo --login -u vagrant minikube completion bash > /etc/bash_completion.d/minikube 2>/dev/null

# Start a multi-node Minikube with some built-in add-ons enabled.
sudo --login -u vagrant minikube start \
    --nodes 2 \
    --cni calico \
    --addons metrics-server \
        2> /tmp/minikube-start.log \
    || cat /tmp/minikube-start.log

# Expose Minikube's `.kube/config` to the host as new Kubeconfig file,
# enabling the Vagrant host to use its own `kubectl`/Lens/`k9s` as well.
host_kubeconfig="/vagrant/kubeconfig-minikube.yaml"
cp ~vagrant/.kube/config $host_kubeconfig
sudo --login -u vagrant kubectl --kubeconfig $host_kubeconfig config unset clusters.minikube.certificate-authority
sudo --login -u vagrant kubectl --kubeconfig $host_kubeconfig config unset users.minikube.client-certificate
sudo --login -u vagrant kubectl --kubeconfig $host_kubeconfig config unset users.minikube.client-key
sudo --login -u vagrant kubectl --kubeconfig $host_kubeconfig config \
    set clusters.minikube.certificate-authority-data "$(base64 ~vagrant/.minikube/ca.crt)"
sudo --login -u vagrant kubectl --kubeconfig $host_kubeconfig config \
    set users.minikube.client-certificate-data "$(base64 ~vagrant/.minikube/profiles/minikube/client.crt)"
sudo --login -u vagrant kubectl --kubeconfig $host_kubeconfig config \
    set users.minikube.client-key-data "$(base64 ~vagrant/.minikube/profiles/minikube/client.key)"
sudo --login -u vagrant kubectl --kubeconfig $host_kubeconfig config \
    set clusters.minikube.server "https://localhost:8443"
# For the above to work, we must also route requests from the host to
# the API server's actual IP address, which is really owned by Docker.
gateway_ip="$(ip route show default | cut -d ' ' -f 3)"
api_server="$(sudo --login -u vagrant kubectl --kubeconfig ~vagrant/.kube/config config view \
    | grep 'server:' | tr -d ' ' | sed -e 's/.*\/\///')"
iptables -t nat -I PREROUTING -p tcp -s "$gateway_ip" --dport 8443 \
    -j DNAT --to-destination "$api_server" \
    -m comment --comment "API server access for Vagrant host"

# Download some workshop materials.
[ -d ~vagrant/kubernetes-in-action-2nd-edition ] \
    || sudo --login -u vagrant git clone https://github.com/luksa/kubernetes-in-action-2nd-edition.git
