# Introduction to Basic Network Administration

> :construction: TK-TODO

# Contents

1. [Objectives](#objectives)
1. [Bill of materials](#bill-of-materials)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
1. [Practice](#practice)
    1. [Introduction](#introduction)
    1. [Network connectivity checking](#network-connectivity-checking)
    1. [DHCP server configuration (in VirtualBox)](#dhcp-server-configuration-in-virtualbox)
1. [Discussion](#discussion)
    1. [Network interfaces in GNU/Linux](#network-interfaces-in-gnulinux)
    1. [Network masks and subnetting](#network-masks-and-subnetting)
    1. [IPv6 addressing](#ipv6-addressing)
    1. [DHCP options](#dhcp-options)
1. [Additional references](#additional-references)

# Objectives

When you complete this lab, you will have acquired the following capabilities:

> :construction: TK-TODO

# Bill of materials

This folder contains the following files and folders:

* `README.md` - This file.
* `Vagrantfile` - The Vagrant configuration for our virtual private cloud.

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

* For managing the virtual machines: [VirtualBox](https://www.virtualbox.org/) version 5.0 or newer, sometimes written as *VBox*.
* For automatically configuring virtual machine settings: [Vagrant](https://vagrantup.com/) version 2.1 or newer.

Complete the [Introduction to Virtual Machine Management with Vagrant](../introduction-to-virtual-machine-management-with-vagrant/README.md) practice lab before this one if you do not yet have VirtualBox and Vagrant installed or are unfamiliar with how to use them.

Then, bring the virtual machines for the lab online.

**Do this:**

1. Boot both virtual machines needed for the lab:
    ```sh
    vagrant up
    ```

Once both the virtual machines are running, you can continue to the next step.

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

> :construction: TK-TODO

## Network connectivity checking

Networked services such as those available on the Internet, including Web sites, email, VoIP calling, and more, all require at least two computers communicating over a network. This implies that the two computers must be able to send messages to and receive messages from one another, whether secured or not. If the two computers can't reach one another over this network for any reason, then the specific service or application you're using is a moot point, since there is no way to make use of it in the first place Therefor, before we even concern ourselves with any given service or application, we need to ensure that the one machine is able to contact the other, and vice versa.

Further, in order for one machine to send a message to another, it must have the name of the place at which the intended recipient can be found. This name is called an *address*. At this fundamental level, computer addresses work exactly the same way as postal addresses. If you've ever sent a postcard to a family member or friend while on vacation, you've written an address. Likewise, if you've ever sent an email to a coworker, chatted with a friend on Facebook, or placed a telephone call, you've used an address to direct the message towards your recipient. Postcards use *mailing addresses*, Facebook chats use Facebook *user names*, e-mails use *email addresses*, and telephone calls use *telephone numbers*. These are all examples of addresses.

In many modern digital networks (like the Internet), the "place" in the network at which a given machine can be found is an address called an *[Internet Protocol (IP)](https://simple.wikipedia.org/wiki/Internet_Protocol) address*. In order for our virtual machines to be able to communicate with one another, both of them need to have their own IP address. When one sends a message to the other, it will write its own IP address on the message's envelope in the *source IP* field and, unsurprisingly, it will write the IP address of its intended recipient on the message's envelope in the *destination IP* field. These message envelopes are called *packet headers*.

> :beginner: :bulb: If you think about it, of course, it's not enough merely to give two machines addresses. These addresses need to be *routable* between each other. That is, there needs to be an unbroken pathway from point A (the source) to point B (the destination), which further means each intermediary device handling their messages can forward them in the appropriate direction. Internetwork routing is beyond the scope of this lab, but have a look at [Henrik Frystyk's excellent (and superbly brief) *Introduction to the Internet*](https://www.w3.org/People/Frystyk/thesis/Internet.html), circa 1994, for more information. His article also lists references that, while old, are still profoundly relevant today.

In this lab, both virtual machines are connected to two different networks: the NAT network required by Vagrant connects the virtual machine to the Internet, and the VirtualBox internal network we named `testnet` is intended to allow the virtual machines to communicate with one another. It is our connections to this second network that we will be examining more closely.

**Do this:**

1. Log in to the CentOS virtual machine using `vagrant ssh centos` if you have not already done so.
1. Look up the current IP network address configurations of the virtual machine by invoking [the `ip address` command](https://explainshell.com/explain?cmd=ip+address). You will see a readout showing you information about each of the machine's IP network devices and the current state of each of them:
    ```sh
    $ ip address
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host
           valid_lft forever preferred_lft forever
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
        link/ether 52:54:00:c9:c7:04 brd ff:ff:ff:ff:ff:ff
        inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
           valid_lft 85862sec preferred_lft 85862sec
        inet6 fe80::5054:ff:fec9:c704/64 scope link
           valid_lft forever preferred_lft forever
    3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
        link/ether 08:00:27:aa:0a:e6 brd ff:ff:ff:ff:ff:ff
        inet6 fe80::a00:27ff:feaa:ae6/64 scope link
           valid_lft forever preferred_lft forever
    ```
    > :beginner: If you're not familiar with IP internetwork routing, the amount of information presented here can feel overwhelming. Don't worry, though, we'll only be concerning ourselves with a few important bits. These are:
    >
    > * The *logical device name*. In the output above, we see three devices. The first is named `lo`, the second is named `eth0`, and the third is named `eth1`. You can see this in the lines that begin with `1: lo`, `2: eth0`, and `3: eth1`.
    > * The IP address assigned to the named device. In this case, the `lo` device has the IP address `127.0.0.1/8`, the `eth0` device has the IP address `10.0.2.15/24`, and the `eth1` device doesn't have an IP address at all. You can see this in the indented lines that start with `inet`. Note that the third device's indented block does not have a line that begins with `inet` at all.
    >
    > Each of these devices corresponds to a (virtualized, in our case) hardware network adapter installed in the virtual machine, or a virtual network interface, such as the `lo` device in this example. Yes, that's a virtual network interface in a virtual machine. For more information about network devices, see the [Network interfaces in GNU/Linux](#network-interfaces-in-gnulinux) discussion section.
    >
    > Finally, note that each of the IP addresses end with a forward slash (`/`) and another number. The number following the forward slash is called a *network mask* or *netmask* for short. The forward slash itself indicates a particular notation called [Classless Inter-Domain Routing (CIDR)](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation. For a more thorough treatment of netmasks and their use for creating sub-networks (networks within networks), see the [Network masks and subnetting](#network-masks-and-subnetting) discussion section. For now, all you need to know is that reading netmasks correctly is an important part of determining how, and if, two machines can route messages to each other, because the netmask determines whether or not the two machines are logically located within "the same network" or not. So when reading IP addresses, remember to look at the netmask as well!
    >
    > :beginner: :bulb: In the output shown by the `ip address` command, lines starting with `inet` denote Internet Protocol version 4 information. There is another, newer version of the Internet Protocol called [IP version 6, or IPv6](https://en.wikipedia.org/wiki/IPv6) for short. Information about a machine's IPv6 addresses is also shown by the `ip address` command on lines that start with `inet6`. A network adapter can have an IPv4 and an IPv6 address at the same time. You'll see that IPv6 addresses look different than IPv4 addresses: they use hexadecimal numbers separated by a colon, instead of decimal numbers separated by a dot, but both versions still end with a forward slash and a decimal number to denote the address's netmask. For the purposes of this lab, we won't be dealing with IPv6 at all, but have a look at the [IPv6 addressing](#ipv6-addressing) discussion section for more information about the differences between IPv4 and IPv6.
1. Exit the virtual machine by using [the `exit` command](https://explainshell.com/explain?cmd=exit). This will return you to your host operating system.
1. Log in to the Ubuntu virtual machine and investigate its IP address configuration by using the `ip address` command again. You'll see similar but probably not identical output as you did on CentOS:
    ```sh
    $ ip address
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host
           valid_lft forever preferred_lft forever
    2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
        link/ether 02:48:3e:15:b5:0c brd ff:ff:ff:ff:ff:ff
        inet 10.0.2.15/24 brd 10.0.2.255 scope global enp0s3
           valid_lft forever preferred_lft forever
        inet6 fe80::48:3eff:fe15:b50c/64 scope link
           valid_lft forever preferred_lft forever
    3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
        link/ether 08:00:27:62:c4:26 brd ff:ff:ff:ff:ff:ff
        inet6 fe80::a00:27ff:fe62:c426/64 scope link
           valid_lft forever preferred_lft forever
    ```
    > :beginner: Did you notice the difference in these device names? For example, it was `eth1` on CentOS but is `enp0s8` on Ubuntu. The `eth` prefix is a historical abbreviation for *[ethernet](https://simple.wikipedia.org/wiki/Ethernet)*, the lower-level networking technology on which many IP networks still depend. In contrast, `enp` stands for *ethernet network peripheral*. See the [Predictable Network Interface Names page on the Freedesktop Project's wiki](https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/) for details about these naming choices.

Astute readers will no doubt have noticed that `eth0` on the CentOS machine and `enp0s3` on the Ubuntu machine both have the same IP address. This is because both devices are set to use VirtualBox's NAT [networking mode](../introduction-to-virtual-machine-management-with-vagrant/README.md#virtualbox-networking-modes). These devices are attached to completely separated networks and can therefore have the same IP address without conflicting with one another. This is like two people sharing the same name, but being in totally different conversations. No one will be confused about who is being referred to by the name "Alex" if there is only one Alex in the room.

If your IP address configurations look like the above, there is an obvious problem: the two virtual machines cannot yet communicate with one another. This is because VirtualBox has not given them IP addresses to use while on the `testnet` internal network. To resolve this situation, we need to instruct VirtualBox to start doling out IP addresses to machines that are connected to this named internal network.

### Ping

* emitting a network probe from the Ubuntu Bionic virtual machine using the `ping(1)` command to each of the IP addresses within [the DHCP address pool you configured earlier](#virtualbox-dhcp-server-configuration) and seeing which one responds:
    ```sh
    ping 172.16.1.10 # Is a machine on the network at this address?
    ping 172.16.1.11 # How about this address?
    ping 172.16.1.12 # And so on.
    ping 172.16.1.13
    ping 172.16.1.14 # Don't forget that one of these will be you!
    ping 172.16.1.15 # You can ping yourself, but that won't help
    ping 172.16.1.16 # you find a remote server. :)
    ping 172.16.1.17
    ping 172.16.1.18
    ping 172.16.1.19
    ping 172.16.1.20
    ```
    > :beginner: The `ping(1)` command is famous for exactly this use: to see if a network device is online. It's actually an abbreviation for "packet Internet groper," and it is analogous to the concept of a ping used in sonar technologies. While the `ping` command can do a number of neat things, all we're doing here is sending a message to the address you specify asking for a response. Much like making a telephone call to a friend, if they pick up and a response arrives, you know they're alive. If no response arrives, well, one hopes they're just not answering their phone right now. It happens!
    >
    > On most systems, invoking `ping` this way will cause your machine to try reaching the destination address forever. If no response arrives within a few seconds, though, it's very unlikely that trying for any longer will succeed. To stop `ping`, press the `Control` key and, while keeping it pressed, press the `c` key on your keyboard. This keyboard sequence is sometimes notated as `^C` (often called "Emacs style" or "hat style" notation) or `C-c` (often called "Vim style").
    >
    > If the address you probe does not respond, you might see output like that shown below. Notice that the `^C` indicates when the Control-C key combination was pressed to stop `ping`ing:
    > ```sh
    > vagrant@ubuntu-bionic:~$ ping 172.16.1.20
    > PING 172.16.1.20 (172.16.1.20) 56(84) bytes of data.
    > From 172.16.1.10 icmp_seq=1 Destination Host Unreachable
    > From 172.16.1.10 icmp_seq=2 Destination Host Unreachable
    > From 172.16.1.10 icmp_seq=3 Destination Host Unreachable
    > ^C
    > --- 172.16.1.20 ping statistics ---
    > 5 packets transmitted, 0 received, +3 errors, 100% packet loss, time 4010ms
    > ```
    >
    > In contrast, if you do get a response, you'll see output more like this, showing how long it took your machine to hear a response to "echo-location" request:
    >
    > ```sh
    > vagrant@ubuntu-bionic:~$ ping 172.16.1.11
    > PING 172.16.1.11 (172.16.1.11) 56(84) bytes of data.
    > 64 bytes from 172.16.1.11: icmp_seq=1 ttl=64 time=0.409 ms
    > ^C
    > --- 172.16.1.11 ping statistics ---
    > 1 packets transmitted, 1 received, 0% packet loss, time 0ms
    > rtt min/avg/max/mdev = 0.409/0.409/0.409/0.000 ms
    > ```
    >
    > Note that the specific IP addresses that respond to you may be different that those shown above because your DHCP server may have assigned your virtual machines different IP addresses than the author's. However, you should get a response from exactly two machines in the DHCP address pool: one is the Ubuntu Bionic virtual machine, and the other is the CentOS 7 virtual machine. Make sure you know which is which. Remember, you can always look up your current machine's IP address with the `ip address` command.
    >
    > :beginner: If only one machine within the DHCP address range responds, make sure that both your virtual machines are turned on and that you have correctly [configured the VirtualBox DHCP server](#virtualbox-dhcp-server-configuration), discussed earlier. In this lab, if you can't `ping` one machine from the other, then you also can't use `ssh` to connect to one from the other.

## DHCP server configuration (in VirtualBox)

When a machine first joins a network, it doesn't necessarily have an IP address. Among other issues, this means it won't be able to receive messages from other machines, since no other machine knows how to address their messages to it. This is the dilemma that the [Dynamic Host Configuration Protocol (DHCP)](https://simple.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) was designed to solve.

A DHCP server, then, is typically a machine that has joined a network ahead of time and is ready to assign IP addresses to new machines as they join the network after it has. These late comers are called *DHCP clients*. DHCP services could be offered by an entirely separate, wholly dedicated machine attached to the network, or they could be offered by any other machine running DHCP server software. For example, in a small home network, the Wi-Fi router probably has a DHCP server running on it. By using DHCP, you can avoid the need to manually configure the IP network settings of each device that wants to use the network each time that device joins the network.

> :beginner: :bulb: DHCP is not limited to assigning IP addresses. It can be used to automatically configure all sorts of network settings, such as the address of upstream DNS servers, network boot images, and more. See the [DHCP options](#dhcp-options) discussion section for more information about the network settings that DHCP can automatically configure.

Much like your home Wi-Fi router, VirtualBox itself has the ability to offer DHCP services to any of the networks it virtualizes. We'll be using this VirtualBox feature to ensure that the virtual machines on the `testnet` network have IP addresses. Using [the `VBoxManage list dhcpservers` command](https://www.virtualbox.org/manual/ch08.html#vboxmanage-list), you can see all the DHCP servers that VirtualBox has added to its virtualized networks.

> :beginner: The `VBoxManage(1)` command is the command-line equivalent of the VirtualBox Manager graphical application you used earlier. Everything that can be accomplished with the graphical point-and-click application can be accomplished with the `VBoxManage` command line, and then some. Each `VBoxManage` command takes a subcommand (such as `list` in the example above), which then may take additional options and arguments. Use the `--help` option to get a quick reference guide for how to use `VBoxManage`. For example, `VBoxManage --help` will show you a usage reference for every `VBoxManage` subcommand, while `VBoxManage list --help` will show you the usage reference just for the `VBoxManage list` subcommand. [Chapter 8 of the VirtualBox Manual](https://www.virtualbox.org/manual/ch08.html) covers the `VBoxManage` command in more complete detail.

**Do this:**

1. Open a terminal on your host machine.
1. Get a list of all the VirtualBox DHCP servers currently installed. Your output will look something like the snippet below, which is truncated for length and clarity:
    ```sh
    $ VBoxManage list dhcpservers
    NetworkName:    NatNetwork
    IP:             10.0.2.3
    NetworkMask:    255.255.255.0
    lowerIPAddress: 10.0.2.4
    upperIPAddress: 10.0.2.254
    Enabled:        Yes

    NetworkName:    intnet
    IP:             172.16.222.1
    NetworkMask:    255.255.255.0
    lowerIPAddress: 172.16.222.100
    upperIPAddress: 172.16.222.111
    Enabled:        Yes
    ```

In the output above, we see two of VirtualBox's default DHCP servers. (There will probably more than two in the complete output; the above is just a small snippet.) Each DHCP server listing has the same format:

* `NetworkName` displays the name of the VirtualBox network to which this DHCP server is attached. In the example above, `NatNetwork` refers to the `NAT` [VirtualBox networking mode](../introduction-to-virtual-machine-management-with-vagrant/README.md#virtualbox-networking-modes). This is the DHCP server from which your virtual machines received an IP address assignment when they started up the first time.
* `IP` is the IP address of the DHCP server itself. Like any other machine, the DHCP server needs an IP address so that it can communicate with other machines on the network. DHCP servers themselves typically get *static* IP addresses, which is to say, their IP addresses are assigned manually by network administrators. You'll be doing this yourself in just a moment.
* [`NetworkMask` is the other important part of an IP address](#network-masks-and-subnetting), and is displayed by VirtualBox in this output using the older dotted decimal notation, rather than the newer CIDR notation. A netmask of `255.255.255.0` in this older notation is equivalent to `/24` in CIDR notation.
* `lowerIPAddress` is the first IP address available for DHCP clients. This is the lower bound in the range of IP addresses you'd like to make available for new machines to use as they join.
* `upperIPAddress` is the last IP address available for DHCP clients. This is the upper bound in the range of IP addresses you'd like to make available for new machines to use as they join.
    > :beginner: Taken together, the lower and upper IP address range is called an *IP address pool*. So, for example, if your lower IP address is 1.1.1.1 and your upper IP address is 1.1.1.2, you have an IP address pool consisting of two IP addresses. This means only two machines at a time will be given an IP address. If a third machine joins the same network, it must wait until one of the first two machines are done using their addresses before it will get an IP address of its own. This may take some time, hours or even days, depending on how the DHCP server is configured and how promptly the DHCP clients notify the server that they no longer need to use the IP address assigned to them.
    >
    > :construction: TK-TODO: Discuss the concept of a DHCP lease, reservation, and lease time. Describe `release`ing a DHCP lease (re-requesting a new DHCP lease), as well, which is a common command that Windows user will be familiar with: `ipconfig /renew`. GNU/Linux users will likely want to explore [the `dhclient(8)` command](https://linux.die.net/man/8/dhclient).
* `Enabled` shows whether or not the VirtualBox DHCP server is actually turned on or not. If the DHCP server is not enabled, it will of course not respond to requests for IP assignments. :)

In order to add DHCP services to our `testnet` network, we merely need to instruct VirtualBox to enable a DHCP server on that named network. We do this using [the `VBoxManage dhcpserver` command](https://www.virtualbox.org/manual/ch08.html#vboxmanage-dhcpserver). If you didn't see a DHCP server listed for the `testnet` network when you ran `VBoxManage list dhcpservers`, you'll need to use the `VBoxManage dhcpserver add` command to install a new DHCP server on the network. Otherwise, if you did see a DHCP server listed for the `testnet` network, you can use `VBoxManage dhcpserver modify` with the exact same arguments as you would have used for the `add` invocation to edit the DHCP server's settings.

Let's configure the DHCP server for the `testnet` network now.

**Do this:**

1. At a terminal on your host machine, add a new DHCP server for the `testnet` network that will offer a small number of IP addresses for the virtual machines to use:
    ```sh
    VBoxManage dhcpserver add --netname testnet --ip 172.16.1.1 --netmask 255.255.255.0 --lowerip 172.16.1.10 --upperip 172.16.1.20 --enable
    ```
1. If you receive an error like `VBoxManage: error: DHCP server already exists`, run the same command but replace `add` with `modify`:
    ```sh
    VBoxManage dhcpserver modify --netname testnet --ip 172.16.1.1 --netmask 255.255.255.0 --lowerip 172.16.1.10 --upperip 172.16.1.20 --enable
    ```
    > :beginner: :construction: TK-TODO: Go over this command invocation in more detail.
1. Confirm that the VirtualBox hypervisor will provide DHCP services to the `testnet` network by invoking `VBoxManage list dhcpservers` again. You should see a DHCP server listed in the output whose configuration matches this output:
    ```
    NetworkName:    testnet
    IP:             172.16.1.1
    NetworkMask:    255.255.255.0
    lowerIPAddress: 172.16.1.10
    upperIPAddress: 172.16.1.20
    Enabled:        Yes
    ```

With the DHCP server in place and enabled, you can now instruct your virtual machines to request IP addresses from it. The easiest way to do this is simply to reboot them. Vagrant provides [the `vagrant reload` command](https://www.vagrantup.com/docs/cli/reload.html) as a shortcut for `vagrant halt` and a subsequent `vagrant up` to turn off a virtual machine and then immediately turn it back on.

**Do this:**

1. Reboot both your CentOS and your Ubuntu virtual machines using Vagrant:
    ```sh
    vagrant reload
    ```
1. Log in to one of your virtual machines using `vagrant ssh` again.
1. Look up the IP address configuration of the virtual machine. If the VirtualBox DHCP server is configured and responding correctly, the network adapter attached to the `testnet` network should now have an IP address associated with it. You can use the `ip address show dev eth1` command to show the IP address(es) assigned to the logical network interface device named `eth1`. (You'll want to replace `eth1` with the name of the device in your virtual machine; this is likely `enp0s8` in the Ubuntu guest.) Doing this on the CentOS virtual machine should now show you output similar to the following:
    ```sh
    $ ip address show dev eth1
    3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
        link/ether 08:00:27:aa:0a:e6 brd ff:ff:ff:ff:ff:ff
        inet 172.16.1.10/24 brd 172.16.1.255 scope global noprefixroute dynamic eth1
           valid_lft 1162sec preferred_lft 1162sec
        inet6 fe80::a00:27ff:feaa:ae6/64 scope link
           valid_lft forever preferred_lft forever
    ```

Notice the presence of the `inet` line. This readout indicates that the virtual machine has been assigned an IP address. The address itself is in the range that we configured as the IP address pool for the DHCP server to oversee, which is a good indication that the DHCP server is responding correctly.

# Discussion

## Network interfaces in GNU/Linux

> :construction: TK-TODO

> TK-TODO: Talk a little bit about `udev`, the `/dev` hierarchy, and what a "[device file](https://en.wikipedia.org/wiki/Device_file)" is. Also touch on [looback devices](https://en.wikipedia.org/wiki/Localhost#Loopback).

## Network masks and subnetting

> :construction: TK-TODO

Let's take a closer look at an example IP address and network mask combination, say `192.168.9.10/24` for example.

```
192       . 168       . 9         . 10        /24
1100 0000 . 1010 1000 . 0000 1001 . 0000 1010
     ^
     | The 1s mean "read this bit as part of a network ID."
     v
255       . 255       . 255       . 0
1111 1111 . 1111 1111 . 1111 1111 . 0000 0000
```

See also: [Practical Networking's Subnetting Mastery](https://www.practicalnetworking.net/stand-alone/subnetting-mastery/) is a pretty decent introduction.

## IPv6 addressing

> :construction: TK-TODO

## DHCP options

> :construction: TK-TODO

> More about what you can do with DHCP: set a client's DNS server, provide PXE boot addresses, etc.

# Additional references

> :construction: TK-TODO
