#!/bin/bash

# Initialize some common variables.
os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"

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
    docker-ce docker-ce-cli containerd.io \
    helm

usermod -a -G docker vagrant

# Install Minikube and set up its built-in `kubectl` utility.
which minikube || {
    curl -sLO "https://storage.googleapis.com/minikube/releases/latest/minikube-${os}-${arch}"
    install "minikube-${os}-${arch}" /usr/local/bin/minikube
    rm -f "minikube-${os}-${arch}"
}
minikube completion bash > /etc/bash_completion.d/minikube
ln -s "$(which minikube)" /usr/local/bin/kubectl \
    && kubectl completion bash > /etc/bash_completion.d/kubectl 2> /dev/null

# Install the Krew plugin manager.
# TODO: This may not actually work well with Minikube's built-in K8s
#       client (`kubectl`) binary, but we'll pick it up anyway.
cd "${TMPDIR:-/tmp}"
curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz"
tar -xzf krew.tar.gz
"./krew-${os}_${arch}" install krew
cd -
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> /home/vagrant/.profile

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
kubectl --kubeconfig $host_kubeconfig config unset clusters.minikube.certificate-authority
kubectl --kubeconfig $host_kubeconfig config unset users.minikube.client-certificate
kubectl --kubeconfig $host_kubeconfig config unset users.minikube.client-key
kubectl --kubeconfig $host_kubeconfig config \
    set clusters.minikube.certificate-authority-data "$(base64 ~vagrant/.minikube/ca.crt)"
kubectl --kubeconfig $host_kubeconfig config \
    set users.minikube.client-certificate-data "$(base64 ~vagrant/.minikube/profiles/minikube/client.crt)"
kubectl --kubeconfig $host_kubeconfig config \
    set users.minikube.client-key-data "$(base64 ~vagrant/.minikube/profiles/minikube/client.key)"
kubectl --kubeconfig $host_kubeconfig config \
    set clusters.minikube.server "https://localhost:8443"
# For the above to work, we must also route requests from the host to
# the API server's actual IP address, which is really owned by Docker.
gateway_ip="$(ip route show default | cut -d ' ' -f 3)"
api_server="$(kubectl --kubeconfig ~vagrant/.kube/config config view \
    | grep 'server:' | tr -d ' ' | sed -e 's/.*\/\///')"
iptables -t nat -I PREROUTING -p tcp -s "$gateway_ip" --dport 8443 \
    -j DNAT --to-destination "$api_server" \
    -m comment --comment "API server access for Vagrant host"

# Download some workshop materials.
[ -d ~vagrant/kubernetes-in-action-2nd-edition ] \
    || sudo --login -u vagrant git clone https://github.com/luksa/kubernetes-in-action-2nd-edition.git
