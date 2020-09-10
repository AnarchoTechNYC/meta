#!/bin/bash

ip_addr="$1"

# (re)set the keyboard layout.
cat >/etc/default/keyboard <<'EOF'
# KEYBOARD CONFIGURATION FILE
# Consult the keyboard(5) manual page.
XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS=""
KEYMAP="us-latin1"
BACKSPACE="guess"
EOF
setupcon

# Enable network configuration hot-apply capability.
export DEBIAN_FRONTEND=noninteractive
apt-get install --yes ifupdown2

# We don't need this temporary file as we'll be writing our own soon.
# (This is the same as hitting "Revert" in the Web GUI.)
rm -f /etc/network/interfaces.new

# Configure the network for simple bridged mode. See:
#     https://pve.proxmox.com/wiki/Network_Configuration#_default_configuration_using_a_bridge
ifdown vmbr0
cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet manual

auto vmbr0
iface vmbr0 inet dhcp
    bridge-ports eth0
    bridge-stp off
    bridge-fd 0
#DHCP to Internet

auto eth1
iface eth1 inet manual

auto vmbr1
iface vmbr1 inet static
    address $ip_addr/24
    bridge-ports eth1
    bridge-stp off
    bridge-fd 0
#Static IPs to hostonly network
EOF
ifup eth0 vmbr0 eth1 vmbr1
