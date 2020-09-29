# Introduction to Virtual Private Networks

> :construction: TODO

# Contents

1. [Objectives](#objectives)
1. [Bill of materials](#bill-of-materials)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
1. [Practice](#practice)
1. [Discussion](#discussion)
1. [Additional references](#additional-references)

# Objectives

When you complete this lab, you will have acquired the following capabilities:

> :construction: TODO

# Bill of materials

This folder contains the following files and folders:

* `README.md` - This file.
* `Vagrantfile` - The Vagrant configuration for our lab environment.
* `provision/` - Folder that houses some artifacts for the lab environment. You can safely ignore this folder.

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

Once both the virtual machines are running, you can continue to the next step.

# Practice

> :construction: TK-TODO
>
> Some notes follow.

First, understand the basics of an OpenVPN server.

1. Log in to the machine that will be used to run the OpenVPN server:
    ```sh
    vagrant ssh server
    ```
1. Once the OpenVPN packages are installed, templated systemd service unit files will be available. One template is for launching OpenVPN as a client (`openvpn-client@.service`), and another for launching OpenVPN as a server (`openvpn-server@.service`).
    ```sh
    systemctl list-unit-files openvpn*
    ```
    ```
    UNIT FILE               STATE
    openvpn-client@.service disabled
    openvpn-server@.service disabled
    openvpn.service         enabled
    openvpn@.service        disabled

    4 unit files listed.
    ```
1. As can be seen from the service unit template files themselves, both expect the template instance to be named the same as an OpenVPN configuration file:
    ```sh
    # Find the location of the unit file.
    systemctl show --property FragmentPath openvpn.service
    ```
    ```
    FragmentPath=/lib/systemd/system/openvpn.service
    ```
    ```sh
    # Now look for where the instance name is used in the template,
    # along with what the unit's working directory is set to.
    grep -E 'WorkingDirectory|%i' /lib/systemd/system/openvpn-{client,server}@.service
    ```
    ```
    /lib/systemd/system/openvpn-client@.service:WorkingDirectory=/etc/openvpn/client
    /lib/systemd/system/openvpn-client@.service:ExecStart=/usr/sbin/openvpn --suppress-timestamps --nobind --config %i.conf
    /lib/systemd/system/openvpn-server@.service:WorkingDirectory=/etc/openvpn/server
    /lib/systemd/system/openvpn-server@.service:ExecStart=/usr/sbin/openvpn --status %t/openvpn-server/status-%i.log --status-version 2 --suppress-timestamps --config %i.conf
    ```
    The `--config` option to `openvpn` is used to point the OpenVPN application to a given configuration, which are expected in the `/etc/openvpn/client` or `/etc/openvpn/server` directories, depending on whether the service unit used is the client or server template.
1. Simple configurations have already been provided as part of the lab:
    ```sh
    ls /etc/openvpn/{client,server}
    ```
    Have a look at one of the examples, such as [the example `p2p-server.conf` configuration file](provision/p2p-server.conf), more closely to know what to expect when you use it:
    1. The `dev` directive maps to the `--dev` command line option. It's being passed the value `tun`, indicating automatic creation of a `tun` typed network device.
    1. The `topology` directive maps to the `--topology` command line option. It's being passed the value `p2p`, indicating to OpenVPN that we'd like to create a point-to-point network, i.e., a network consisting of exactly two endpoints, which is one server and one client. (Don't confuse this with [PPTP, the Point-to-Point Tunneling Protocol](https://en.wikipedia.org/wiki/Point-to-Point_Tunneling_Protocol), which is an entirely different VPN technology. Note also that this mode is not compatible with Windows clients and is typically used to connect the gateways of two disparate networks, such as a company's remote office branches or large campuses where one part of the network is physically separated from the main campus network. Use the similar [`subnet-server.conf` example](provision/subnet-server.conf) for Windows clients.) Since this configuration does not specify a `remote` directive (equivalent to the `--remote` command line option), it is going to act as the server.
    1. The `ifconfig` directive maps to the `--ifconfig` command line option. (This is not the same as the `ifconfig(8)` command line utility of the same name.) The `--ifconfig` option offers a way to configure the interface OpenVPN will be using, which in this case is the `tun` device selected earlier. It's being passed two IP addresses as values, the first one for this machine and the second one for the IP address to assign the connecting client endpoint.
1. Given the systemd configuration observed earlier, the server can thus be started like so:
    ```sh
    sudo systemctl start openvpn-server@p2p-server
    systemctl show --property StatusText !$
    ```
    ```
    StatusText=Pre-connection initialization successful
    ```
1. When the `p2p-server` OpenVPN configuration is loaded, the privileged `openvpn` process also automatically configured a `tun` device, probably called `tun0`. It creates a virtual Layer 3 (`tun` typed) network interface, brings it up (online), and configures the interface with an IPv4 address:
    ```sh
    ip tuntap show mode tun          # Show list of all `tun`-typed devices.
    ip link show tun0                # Show physical link information for device `tun0`.
    ip -f inet address show dev tun0 # Show IPv4 address information for device `tun0`.
    ```
    The VPN server is now running, but is not yet serving any clients.
1. Finally, note the VPN server's public IP address (or hostname). This is the address to which VPN clients will need to connect.
    ```sh
    ip -f inet address show enp0s8
    ```
    ```
    3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        inet 172.22.33.2/24 brd 172.22.33.255 scope global enp0s8
           valid_lft forever preferred_lft forever
    ```
    The VPN server's own IP address is `172.22.33.2/24`. Note that this IP address is in a completely different network than the IP address assigned to the virtual network's own interface.

Now we can look more closey at an OpenVPN client.

1. Log in to the virtual machine that will be acting as the OpenVPN client if you are not already logged in:
    ```sh
    vagrant ssh client
    ```
1. TODO

Despite having created a virtual network, very little about this set up can be said to be private. That is, it is more of a "virtual network" rather than a Virtual *Private* Network.

That's because, so far, the tunnelled network connection remains unprotected: there is no confidentiality or integrity guarantee available to the traffic because no encryption cipher is being used to encrypt the traffic and no Hashed Message Authentication Code (HMAC) is used to authenticate the packets as they arrive. Moreover, no user authentication is being performed, meaning anyone who can reach the OpenVPN server is able to connect to it without identifying who they are, and vice versa for the client, which cannot authenticate the server.

To fix these issues, we need to select and use OpenVPN's cryptographic options.

1. OpenVPN does not, itself, perform any cryptographic functions. Instead, every installation of OpenVPN is built with support for one or more cryptographic *engines*. The most popular of these is Free Software [OpenSSL](https://www.openssl.org/) project. Find out which crypto engines your OpenVPN instance supports with the `--show-engines` option:
    ```sh
    openvpn --show-engines
    ```
    ```
    OpenSSL Crypto Engines

    Intel RDRAND engine [rdrand]
    Dynamic engine loading support [dynamic]
    ```
    If your installation supports multiple crypto engines you can explicitly choose one over another with the `--engine` option, although it's usually best to let the software pick for you.
1. You'll need to pick cryptographic algorithms more often you'll need to pick a crypto engine explicitly. Additional options that begin with `--show-*` are available to list out what algorithms are available to your OpenVPN instance:
    ```sh
    # Show available data channel transport encryption ciphers.
    openvpn --show-ciphers # (Use the `--cipher` option to apply one.)

    # Show available data channel traffic authentication (HMAC) algorithms.
    openvpn --show-digests # (Use the `--auth` option to apply one.)

    # Show available control channel encryption and traffic authentication schemes.
    openvpn --show-tls # (Use the `--tls-cipher` option to apply one.)
    ```

# Discussion

> :construction: TK-TODO

# Additional references

> :construction: TK-TODO
