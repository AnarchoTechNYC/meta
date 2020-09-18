#!/bin/bash

# Install OpenVPN OSS version from its repos. See:
# https://community.openvpn.net/openvpn/wiki/OpenvpnSoftwareRepos
apt-get update && apt-get -y install ca-certificates wget net-tools gnupg
wget -qO - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add -
echo "deb http://build.openvpn.net/debian/openvpn/stable $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/openvpn-aptrepo.list
apt-get update && apt-get -y install openvpn easy-rsa

# Install the OpenVPN configurations.
install /vagrant/provision/*-client.conf /etc/openvpn/client
install /vagrant/provision/*-server.conf /etc/openvpn/server
