#!/bin/bash -

apt update
apt install --yes python3 python3-pip python3-venv \
    xfce4 firefox \
    ettercap-graphical

# Install Social Engineer's Toolkit.
git clone --depth 1 https://github.com/trustedsec/social-engineer-toolkit.git set/
chown -R vagrant:vagrant set
cd set
pip3 install -r requirements.txt

# Install recent mitmproxy, as well.
pip3 install pipx
sudo --login -u vagrant pipx install mitmproxy
