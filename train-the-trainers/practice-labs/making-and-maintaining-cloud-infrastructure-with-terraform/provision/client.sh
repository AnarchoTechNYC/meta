#!/bin/bash -e

terraform_version="0.13.2"
tprovider_version="0.3.0"

apt update && apt install --yes unzip

cd "${TMPDIR:-/tmp}"

# Install Terraform.
url="https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_$(uname -s | tr '[A-Z]' '[a-z]')_$(dpkg --print-architecture).zip"
curl -sLO $url
unzip -o "$(basename "$url")"
install terraform /usr/local/bin

# Install a Proxmox provider for Terraform.
vend="danitso"
repo="terraform-provider-proxmox"
url="https://github.com/$vend/$repo/releases/download/$tprovider_version/${repo}_v${tprovider_version}-custom_$(uname -s | tr '[A-Z]' '[a-z]')_$(dpkg --print-architecture).zip"
curl -sLO "$url"
unzip -o "$(basename "$url")"
install -D -o vagrant -g vagrant \
    "$repo"*[^.zip] \
    ~vagrant/.terraform.d/plugins/localhost.localdomain/$vend/"$(echo -n $repo | rev | cut -d '-' -f 1 | rev)"/$tprovider_version/$(uname -s | tr '[A-Z]' '[a-z]')_$(dpkg --print-architecture)/${repo}_v$tprovider_version

# Copy the initial lab files over.
mkdir -p ~vagrant/lab
cp -R /vagrant/terraform ~vagrant/lab
chown -R vagrant:vagrant ~vagrant
