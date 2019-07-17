#!/bin/bash -

apt update
apt install -y python python-pip xfce4 firefox
git clone --depth 1 https://github.com/trustedsec/social-engineer-toolkit.git set/
chown -R vagrant:vagrant set
cd set
pip install -r requirements.txt
