#!/bin/bash -

apt update
apt install --yes python3 python3-pip xfce4 firefox
git clone --depth 1 https://github.com/trustedsec/social-engineer-toolkit.git set/
chown -R vagrant:vagrant set
cd set
pip3 install -r requirements.txt
