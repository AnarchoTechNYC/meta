#!/bin/bash

# Install dependent software.
apt update && apt install --yes \
    apt-transport-https \
    ca-certificates curl \
    gnupg-agent software-properties-common \
    conntrack
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update && apt install --yes \
    docker-ce docker-ce-cli containerd.io

usermod -a -G docker vagrant

# Install kubectl.
snap install --classic kubectl \
    && kubectl completion bash > /etc/bash_completion.d/kubectl

# Install Minikube.
which minikube || {
    curl --silent --location --output minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    chmod +x minikube
    install minikube /usr/local/bin/
    rm minikube
}

# Start the Minikube cluster as the default non-root (`vagrant`) user.
sudo --login -u vagrant minikube start 2> /tmp/minikube-start.log || cat /tmp/minikube-start.log

# Download some workshop materials.
[ -d k8s-workshop ] || sudo --login -u vagrant git clone https://github.com/fabacab/k8s-workshop.git
[ -d kubernetes-in-action-2nd-edition ] || sudo --login -u vagrant git clone https://github.com/luksa/kubernetes-in-action-2nd-edition.git
