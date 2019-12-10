#!/bin/bash -

apt update
apt install --yes python python-pip xfce4 firefox
git clone --depth 1 --branch fix-pymssql --single-branch https://github.com/meitar/social-engineer-toolkit.git set/
chown -R vagrant:vagrant set
cd set
pip install -r requirements.txt
