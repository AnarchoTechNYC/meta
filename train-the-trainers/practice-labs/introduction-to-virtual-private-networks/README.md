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

That's because, so far, the tunnelled network connection remains unprotected: there is no confidentiality or integrity guarantee available to the traffic because no encryption cipher is being used to encrypt the traffic and no Hashed Message Authentication Code (HMAC) is used to authenticate the packets as they arrive. Moreover, no user authentication is being performed, meaning anyone who can reach the OpenVPN server is able to connect to it without identifying who they are, and vice versa for the client, which cannot authenticate the server. To confirm these weaknesses, one merely needs to snoop on the VPN tunnel traffic.

**Do this** with the point-to-point VPN established earlier still connected:

1. Log in to the VPN server.
    ```sh
    vagrant ssh server
    ```
1. Set up a simple TCP server using the `nc` utility so that we can send some traffic across the tunnel:
    ```sh
    nc -l 10.8.0.1 -p 9999 # Where 10.8.0.1 is the VPN's IP address.
    ```
1. In another terminal window, log in to the VPN client.
    ```sh
    vagrant ssh client
    ```
1. Begin eavesdropping on the VPN tunnel traffic by capturing packets on the interface outside of the tunnel:
    ```sh
    sudo tcpdump -i enp0s8 -X
    ```
1. In yet another terminal window, log back into the VPN client and connect to the simple TCP server:
    ```sh
    nc 10.8.0.1 9999
    ```
1. Now send any message from either the server to the client or from the client to the server and observe that the plain text is clearly visible in the terminal window running `tcpdump`.

To fix these issues, we need make use of OpenVPN's cryptographic capabilities.

OpenVPN does not, itself, perform any cryptographic functions. Instead, every installation of OpenVPN is built with support for one or more cryptographic *engines*. The most popular of these is the [OpenSSL](https://www.openssl.org/) project, the longstanding de facto standard implementation of many cryptographic routines. Find out which crypto engines your OpenVPN instance supports with the `--show-engines` option:

```sh
openvpn --show-engines
```
```
OpenSSL Crypto Engines

Intel RDRAND engine [rdrand]
Dynamic engine loading support [dynamic]
```

If your installation supports multiple crypto engines you can explicitly choose one over another with the `--engine` option, although it's usually best to let the software pick for you.

You'll need to pick cryptographic algorithms more often you'll need to pick a crypto engine explicitly. Additional options that begin with `--show-*` are available to list out what algorithms are available to your OpenVPN instance:

```sh
# Show available data channel transport encryption ciphers.
openvpn --show-ciphers # (Use the `--cipher` option to apply one.)

# Show available data channel traffic authentication (HMAC) algorithms.
openvpn --show-digests # (Use the `--auth` option to apply one.)

# Show available control channel encryption and traffic authentication schemes.
openvpn --show-tls # (Use the `--tls-cipher` option to apply one.)
```

Each of the cryptographic algorithms requires the use of a cryptographic primitive known as a *key* that is used to derive the output of the cryptographic engine's calculations. OpenVPN has two cryptographic operating modes. While both modes require keys, the two modes differ in a number of ways, such as how those keys should be generated:

* OpenVPN's *static key mode* is the simpler of the two modes.
    * Beyond being simpler, one of its major benefits is that a properly configured OpenVPN tunnel operating in static key mode cannot be identified as an OpenVPN tunnel because fingerprintable actions such as key negotiation, handshaking, and so on are performed by the VPN operators at each side of the tunnel, before the VPN tunnel is established, allowing the wire protocol to omit these details.
    * Unfortunately, this also means OpenVPN's static key mode does not currently implement perfect forward secrecy; if the pre-shared, static key is ever compromised, an attacker who has recorded past VPN traffic can decrypt the entire conversation.
    * Another downside is that this mode only supports point-to-point connections (one server, one client). For these reasons, static key mode is most useful for ad-hoc, point-to-point links where a pre-existing secure channel between endpoints is already available.
* OpenVPN's *TLS mode* is more flexible and thus more complex but, when configured correctly, arguably more secure.
    * In TLS mode, OpenVPN creates a control channel and a separate data channel for each VPN connection, allowing the client and server to negotiate cryptographic details over the control channel while implementing security enhancements such as perfect forward secrecy over the data channel.
    * The major drawback to TLS mode is the fact that it requires a pre-existing public key infrastructure (PKI) for the server and client to authenticate their TLS certificates against. To help administrators create and maintain their PKI, the OpenVPN project maintains a subproject called Easy RSA that provides simple utilities to generate, administer, and eventually revoke TLS certificates for use in an OpenVPN PKI.
    * Since both client and server authentication is verified using each endpoint's TLS certificate, this mode supports a theoretically unlimited number of clients per server (capped, of course, by the VPN's own network topology and physical resource limits).

**Do this** to protect your VPN with a secret, static key:

1. Generate an OpenVPN static key that both sides of the VPN tunnel can use:
    ```sh
    openvpn --genkey --secret /vagrant/myovpn.key
    ```
    > :beginner: Since our lab environment shares the `/vagrant` directory across all machines in the lab, it is a "secure" channel. In the real world, you might have to safely copy your newly generated static key file to the other end of the VPN connection in some other way, such as via SSH using `scp(1)`. Refer to [Introduction to Securing (Virtualized) Secure Shell Servers](../introduction-to-securing-virtualized-secure-shell-servers/README.md) for more information about administering and using SSH for secure remote administration.
1. Stop the OpenVPN processes on each side of the tunnel to bring it down.
    ```sh
    # On the server:
    sudo systemctl stop openvpn-server@p2p-server

    # On the client:
    sudo systemctl stop openvpn-client@p2p-client
    ```
1. Add the following configuration directive to both the server's `p2p-server.conf` and the client's `p2p-client.conf` OpenVPN configuration files:
    ```
    secret /vagrant/myovpn.key
    ```
    The `secret` directive is equivalent to the `--secret` command line option.
1. Bring both ends of the VPN tunnel back up:
    ```sh
    # On the server:
    sudo systemctl start openvpn-server@p2p-server

    # On the client:
    sudo systemctl start openvpn-client@p2p-client
    ```
1. Repeat the exercise with the simple TCP server, above, to confirm that your tunnel is now encrypted. You can also observe a clear difference by also capturing traffic from inside the VPN tunnel itself:
    ```sh
    sudo tcpdump -i tun0 -X # Where `tun0` is the VPN tunnel's interface.
    ```
    Note that while the traffic is visible in plaintext when you view it from inside the tunnel, it is visible only as ciphertext when you view it from outside the tunnel. This is the primary way VPNs offer data confidentiality to their users.

By configuring the VPN tunnel with a static key, your OpenVPN configuration now provides the two critical security properties of confidentiality and integrity for any traffic that travels inside the tunnel. No outside observer can eavesdrop on the contents of the conection and, moreover, they can also not distinguish the tunnelled traffic as being an OpenVPN connection in the first place because it merely looks like completely random data. However, should your static key ever be compromised (stolen by a hacker, leaked to an adversary, etcetera), any previously-recorded traffic that traversed this tunnel will be visible unless it is itself an encrypted protocol, such as HTTPS or SSH traffic that travelled across the VPN tunnel.

> :bulb: As an added security measure, you can supply a `key-direction` directive (or its equivalent `--key-direction` command line option) to each of the configuration files. Without this option, OpenVPN's static key mode uses the same key bidirectionally; the server uses the same key to encrypt traffic as the client does, and vice versa. In other words, there are only two keys in use: one for traffic encryption and another for packet authentication. By adding `key-direction 0` to the server and `key-direction 1` to the client (note the complementary option arguments), the server and client will use two different encryption keys based on whether they are currently receiving or sending traffic. That is, there will be a total of four keys in use. This provides slightly better security guarantees because:
>
> * a compromise of one direction's keys will only result in the traffic flowing in that one direction becoming visible, and
> * certain kinds of Denial of Service (DoS) and replay attacks become more difficult for attackers to mount.
>
> When using a static key, always consider specifying the `key-direction` to enhance the security of the OpenVPN tunnel. It is easy to do and adds no computing overhead or network latency to the VPN connection, so it's hard to imagine a scenario in which one wouldn't want to take advantage of the benefits this option offers.

> :bulb: With your OpenVPN tunnel now configured to source its cryptographic keys from the static key file generated earlier, another way to increase the security of the tunnel is to explicitly choose the cryptographic algorithms that the tunnel will use. If you omit these, OpenVPN's defaults will be used. These aren't particularly bad choices, but they can be better.
>
> For example, the default packet authentication (HMAC) algorithm is `SHA1`, which as of 2017 has been susceptible to a chosen prefix collision attack, and has continued to show increasing frailty under cryptanalytic pressures. Use the `auth` configuration directive (or the `--auth` command line option) to choose a stronger algorithm, such as `SHA512`. Remember, you can invoke OpenVPN with `openvpn --show-digests` to see a list of all the HMAC algorithms supported by your OpenVPN installation. Also remember that you must apply the same cryptographic algorithm configuration to both the server and the client of the VPN tunnel in order for the traffic to successfully transit the tunnel.
>
> Similarly, the default data encryption cipher is Blowfish in cipher block chaining mode (`BF-CBC`), but this is no longer generally recommended for production use. Use the `cipher` configuration directive (or `--ciphers` command line option) to choose a stronger data encryption algorithm. Invoked with `openvpn --show-ciphers`, OpenVPN will show you a list of data encryption algorithms it supports. We recommend you use the strongest available to you, which is `AES-256-CBC` when OpenVPN is operating in static key mode, and `AES-256-GCM` when operating in TLS mode. As with the HMAC algorithm you use, this configuration must be applied to both the client and the server endpoints of the VPN tunnel.

# Discussion

> :construction: TK-TODO

# Additional references

> :construction: TK-TODO
