#!/bin/bash

# Initialize some common variables.
os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"

# Install and set up software dependencies.
apt-get update && apt-get --yes install \
    apt-transport-https ca-certificates curl \
    gnupg-agent software-properties-common \
    conntrack xdg-utils firefox
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update && apt-get --yes install \
    docker-ce docker-ce-cli containerd.io

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
    --addons dashboard \
    --addons metrics-server \
        2> /tmp/minikube-start.log \
    || cat /tmp/minikube-start.log

# Download some workshop materials.
[ -d ~vagrant/kubernetes-in-action-2nd-edition ] \
    || sudo --login -u vagrant git clone https://github.com/luksa/kubernetes-in-action-2nd-edition.git
