#!/bin/bash -
#
# This script provisions the demo and lab environment. It installs the
# following tools:
#
#     * Ettercap
#     * Social Engineer's Toolkit (SET)
#     * mitmproxy
#     * Evilginx
#
# In addition, it installs an XFCE4 Desktop Environment along with the
# Firefox Web browser, and a few necessary utilities. The additional
# attack tools are included to support various sections of this lab's
# "Discussion" sections.

apt-get update
apt-get install --yes python3 python3-pip python3-venv unzip \
    xfce4 firefox \
    ettercap-graphical

git clone --depth 1 https://github.com/trustedsec/social-engineer-toolkit.git set/
chown -R vagrant:vagrant set
cd set
pip3 install -r requirements.txt
cd -

pip3 install pipx
sudo --login -u vagrant pipx install mitmproxy

mkdir /tmp/evilginx2
wget --quiet -O /tmp/evilginx2/evilginx2.zip \
    https://github.com/kgretzky/evilginx2/releases/download/2.3.0/evilginx_linux_x86_2.3.0.zip
unzip -d /tmp/evilginx2 /tmp/evilginx2/evilginx2.zip
cd /tmp/evilginx2
# Run external `bash` process since install script is not executable.
bash /tmp/evilginx2/install.sh && chmod a+x /usr/local/bin/evilginx
cd -
rm -rf /tmp/evilginx2

# Evilginx has its own DNS server, and it needs localhost port 53
# available to run, so let's make it easy to get `systemd-resolved`
# out of the way.
mkdir -p /etc/systemd/resolved.conf.d
cat << EOF > /etc/systemd/resolved.conf.d/99-evilginx.conf
[Resolve]
DNSStubListener=no
EOF
rm /etc/resolv.conf
ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
systemctl restart systemd-resolved.service
