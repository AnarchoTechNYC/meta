#!/bin/bash -e

terraform_version="1.1.9"
tprovider_version="latest" # Or a specific version in SemVer format.
golang_version="1.18.1"
terragrunt_version="v0.36.9"

apt-get update && apt-get install --yes unzip

cd "${TMPDIR:-/tmp}"

# Install Terraform.
url="https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_$(uname -s | tr '[A-Z]' '[a-z]')_$(dpkg --print-architecture).zip"
curl -sLO "$url"
unzip -o "$(basename "$url")"
install terraform /usr/local/bin

# Install Terragrunt.
url="https://github.com/gruntwork-io/terragrunt/releases/download/${terragrunt_version}/terragrunt_$(uname -s | tr '[A-Z]' '[a-z]')_$(dpkg --print-architecture)"
curl -sLO "$url"
install "terragrunt_$(uname -s | tr '[A-Z]' '[a-z]')_$(dpkg --print-architecture)" /usr/local/bin/terragrunt

# Install a Proxmox provider for Terraform.
vend="danitso"
repo="terraform-provider-proxmox"
if [ "latest" == "$tprovider_version" ]; then
    # Install Go binaries.
    url="https://golang.org/dl/go${golang_version}.$(uname -s | tr '[A-Z]' '[a-z]')-$(dpkg --print-architecture).tar.gz"
    cd ${TMPDIR:-/tmp};
    curl --silent -LO "$url"
    tar -C /usr/local -xzf "$(basename "$url")"
    export PATH="$PATH:/usr/local/go/bin"
    [ 1 -eq $(grep --quiet "\$PATH:/usr/local/go/bin" ~vagrant/.profile; echo $?) ] \
        && echo "export PATH=\$PATH:/usr/local/go/bin" >> ~vagrant/.profile

    # Install build requirements.
    apt-get install --yes make
    # Build and install latest version of Proxmox provider via source.
    gopath=$(go env GOPATH)
    mkdir -p "$gopath/src/github.com/$vend"
    cd "$gopath/src/github.com/$vend"
    if [ -d "$repo" ]; then
        cd "$repo"; git pull; cd ..;
    else
        git clone "https://github.com/$vend/$repo.git"
    fi
    cd "$repo"
    new_version="$(grep TerraformProviderVersion proxmoxtf/version.go | grep -o -e '[0-9]\.[0-9]\.[0-9]')"
    make init
    make build
    install -D -o vagrant -g vagrant cache/plugins/registry.terraform.io/${vend}/proxmox/${new_version}/$(uname -s | tr '[A-Z]' '[a-z]')_$(dpkg --print-architecture)/terraform-provider-proxmox_v${new_version}* \
        ~vagrant/.terraform.d/plugins/localhost.localdomain/$vend/proxmox/$new_version/$(uname -s | tr '[A-Z]' '[a-z]')_$(dpkg --print-architecture)/${repo}_v$new_version
else
    # We've asked for a specific Proxmox provider version.
    url="https://github.com/$vend/$repo/releases/download/$tprovider_version/${repo}_v${tprovider_version}-custom_$(uname -s | tr '[A-Z]' '[a-z]')_$(dpkg --print-architecture).zip"
    curl -sLO "$url"
    unzip -o "$(basename "$url")"
    install -D -o vagrant -g vagrant \
        "$repo"*[^.zip] \
        ~vagrant/.terraform.d/plugins/localhost.localdomain/$vend/"$(echo -n $repo | rev | cut -d '-' -f 1 | rev)"/$tprovider_version/$(uname -s | tr '[A-Z]' '[a-z]')_$(dpkg --print-architecture)/${repo}_v$tprovider_version
fi

# Copy the initial lab files over.
mkdir -p ~vagrant/lab
cp -R /vagrant/terraform ~vagrant/lab
chown -R vagrant:vagrant ~vagrant
