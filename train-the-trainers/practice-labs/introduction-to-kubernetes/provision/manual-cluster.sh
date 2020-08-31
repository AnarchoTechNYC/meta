#!/bin/bash
#
# This script follows the instructions from
#
#     https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/
#
# It's intended to provide a (faster) quickstart for a more "real" K8s
# environment that can be extended with additional nodes by adding VMs
# to the lab environment. This is in contrast with the default Minkube
# provisioner, which is limited to spinning up only single-node
# Kubernetes clusters due to the nature and intent of Minikube itself.

# Simplistic positional arguments. (Passed from the `Vagrantfile`.)
pod_network_cidr="$1"
cni_manifest_url="$2"

# (Install Docker CE)
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install -y \
      apt-transport-https ca-certificates curl software-properties-common gnupg2

# Add Docker's official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Add the Docker apt repository:
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

# Install Docker CE
apt-get update && apt-get install -y \
    containerd.io=1.2.13-2 \
    docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) \
    docker-ce-cli=5:19.03.11~3-0~ubuntu-$(lsb_release -cs)

# Set up the Docker daemon
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m"
   },
   "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
systemctl daemon-reload
systemctl enable docker
systemctl restart docker

# Install the `kubeadm` and `kubectl` CLI tools, and the `kubelet` daemon.
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Initialize the Kubernetes control plane.
kubeadm init --pod-network-cidr="$pod_network_cidr"

# Configure `kubectl` (administrative) context for the new cluster.
sudo --login --user vagrant sh -c 'mkdir -p $HOME/.kube'
cp /etc/kubernetes/admin.conf ~vagrant/.kube/config
chown vagrant:vagrant ~vagrant/.kube/config

# Deploy the chosen CNI plugin into the cluster.
sudo --login --user vagrant kubectl apply -f "$cni_manifest_url"

# Allow control plane node to host data plane (worker node) pods, too.
sudo --login --user vagrant kubectl taint nodes --all node-role.kubernetes.io/master-
