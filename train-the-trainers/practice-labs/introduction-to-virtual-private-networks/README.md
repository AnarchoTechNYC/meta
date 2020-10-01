# Introduction to Virtual Private Networks

> :construction: TODO

# Contents

1. [Objectives](#objectives)
1. [Bill of materials](#bill-of-materials)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
1. [Practice](#practice)
    1. [Cryptography](#cryptography)
    1. [Routing](#routing)
    1. [Simple production site-to-site VPN](#simple-production-site-to-sitevpn)
        1. [Restricting VPN access by network address](#restricting-vpn-access-by-network-address)
        1. [Dropping privileges after connecting](#dropping-privileges-after-connecting)
        1. [Dealing with fascist firewalls](#dealing-with-fascist-firewalls)
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

## Cryptography

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

With your OpenVPN tunnel now configured to source its cryptographic keys from the static key file generated earlier, it's worth considering ways to increase the security of the tunnel itself. One way to do this is to explicitly choose the cryptographic algorithms that the tunnel will use. If you omit these, OpenVPN will fall back to its default choices. These are fine for most casual uses, but they can be better, and should definitely be strengthened for any sensitive applications.

For example, the default packet authentication (HMAC) algorithm is [`SHA1`, which as of 2017 has been susceptible to a chosen prefix collision attack](https://shattered.io/), and has continued to show increasing frailty under cryptanalytic pressures. Use the `auth` configuration directive (or the `--auth` command line option) to choose a stronger algorithm, such as `SHA512`. Remember, you can invoke OpenVPN with `openvpn --show-digests` to see a list of all the HMAC algorithms supported by your OpenVPN installation. Also remember that you must apply the same cryptographic algorithm configuration to both the server and the client of the VPN tunnel in order for the traffic to successfully transit the tunnel.

Similarly, the default data encryption cipher is Blowfish in cipher block chaining mode (`BF-CBC`), but this is no longer generally recommended for production use. Use the `cipher` configuration directive (or `--cipher` command line option) to choose a stronger data encryption algorithm. Invoked with `openvpn --show-ciphers`, OpenVPN will show you a list of data encryption algorithms it supports. We recommend you use the strongest available to you, which is `AES-256-CBC` when OpenVPN is operating in static key mode, and `AES-256-GCM` when operating in TLS mode. As with the HMAC algorithm you use, this configuration must be applied to both the client and the server endpoints of the VPN tunnel.

Regardless of what choice you ultimately make here, remember to return in the future and audit your prior choices to stay current with the state of the art in cryptanalytic techniques. Since changing a given algorithm is usually a simple matter of replacing a line or two in a configuration file (on both the server and any connecting clients), and restarting the VPN software, you can easily work this into any patch management routines you have already automated. (You have [automated patch management](../../mr-robots-netflix-n-hack/week-2/shellshock-and-the-importance-of-patch-management/README.md), haven't you?)

## Routing

With the two VPN endpoints now securely connected, you might imagine that any traffic received by one is visible to the other, but this isn't how OpenVPN works. In fact, OpenVPN is not responsible for anything other than the single virtual network connection between the connecting endpoints. In order for a computer other than the endpoint itself to be able to reach the far side of the VPN tunnel, the VPN endpoint(s) must be able and willing to route traffic just as any other typical router might.

This is usually not something most VPN end users need concern themselves with because, to connect to the VPN server in the first place, clients are given a configuration file that supplies appropriate routing information by their VPN administrator. OpenVPN also has the capability to dynamically push routes from the server to the connecting client, which it will then faithfully add to the local system's routing tables.

In the case of the simple point-to-point VPN tunnel established earlier, these routes were automatically added to the system routing tables on both the VPN server and the VPN client. For example, to view the route from the client to the server, use the following command on the VPN client:

```sh
ip route show to 10.8.0.1/24
```
```
10.8.0.0/24 dev tun0 proto kernel scope link src 10.8.0.2
```

Removing this route (using `sudo ip route del 10.8.0.0/24`) will cause applications attempting to send traffic across the tunnel from the client to server to fail, even though the VPN tunnel is alive and well. That's because the VPN itself is simply a virtual ("overlay") network. Once established, it's up to the Operating System's kernel, not OpenVPN, to determine which traffic should actually transit the VPN tunnel. For that, a correct route must be present.

If you deleted the route to see what would happen, you can re-add it as you might expect:

```sh
sudo ip route add 10.8.0.0/24 dev tun0
```

Once the route is added, bidirectional connectivity between the endpoints is restored. You can once again `ping` the other end of the tunnel, for example.

The fact that OpenVPN is not itself responsible for routing decisions is among the most confusing aspect of VPN use for most new users. Although OpenVPN can be instructed to make changes to a system's routing table by adding the `route` configuration directive to its configuration file (or the equivalent `--route` command line option to the program's invocation), all this does is inform OpenVPN that it should execute the equivalent actions for whatever appropriate command is used to edit the routing tables on the underlying system (usually `ip route` on modern GNU/Linux devices, `route add` on BSD systems, and `route ADD` on Windows computers). Likewise, when the OpenVPN process finishes, it removes the routes from the system's routing tables to clean up after itself in the same way (`ip route del`, `route delete`, etcetera).

> :construction: TK-TODO: Add another device and configure routing appropriately to permit it access to the VPN tunnel without itself being a VPN client. (I.e., a service behind the OpenVPN server, or a workstation that accesses such a service via the OpenVPN client as a gateway.)

## Simple production site-to-site VPN

With the above routes applied, our simple point-to-point VPN tunnel can now serve as a bridge between physically separate networks. This common scenario is often also called a "site-to-site VPN," because each endpoint connected to the VPN tunnel serves as a gateway routing traffic between two geographically disparate sites administered by the same organization. For example, perhaps the VPN server is running at Headquarters, while a satellite, secondary, or branch office or campus connects to the main network via the VPN.

One of the benefits of the above design is that users located in the satellite office or secondary campus don't need to be aware of the VPN's existence at all. From their perspective, the services running at Headquarters are simply available to them because they seem to be "directly" connected to them via their local network connection. They don't even have to install any VPN software; everything "just works."

While the above configurations would work, they are a little sparse. For a better production setup, you'll want to make some additional tweaks to further harden security and improve the VPN's reliability.

### Restricting VPN access by network address

Implementing a site-to-site VPN like this can be made even safer by using the `remote` configuration directive on the server as well as the client. When used on the client, the `remote` option causes the VPN client to attempt a connection with the computer located at the IP address or hostname given. When used on the server, the `remote` option causes the VPN server to reject connections that aren't coming from a specific IP address or hostname; for an OpenVPN server, `remote` acts as a filter.

For example, to implement the point-to-point VPN we've established earlier, use the following command on the server:

```sh
sudo openvpn --dev tun --topology p2p --ifconfig 10.8.0.1 10.8.0.2 \
    --remote 172.22.33.3 --secret /vagrant/myovpn.key --key-direction 0
```

And use this command on the client:

```sh
sudo openvpn --dev tun --topology p2p --ifconfig 10.8.0.2 10.8.0.1 \
    --remote 172.22.33.2 --secret /vagrant/myovpn.key --key-direction 1
```

Notice that the `--remote` option's argument has been flipped from the server to the client, just like the `--ifconfig` and `--key-direction` arguments have been. The client will attempt a connection to the server, and the server will reject connections *unless* that connection's incoming packet headers claim to originate at the client's IP address. Note that since source IP addresses can be easily spoofed, OpenVPN will still enforce packet authentication via the chosen HMAC algorithm; this is simply a defense-in-depth measure.

This kind of restriction is, of course, mostly useful when you already know the IP addresses of each endpoint, such as is the case in a larger site-to-site VPN deployment.

### Dropping privileges after connecting

In order to change the system's routing tables, create or modify interfaces, and so on, OpenVPN needs privileged access. That's why OpenVPN typically runs as the `root` user on UNIX-like systems, at least initially. Once these modifications have been made, though, there isn't any need for the `openvpn` process to retain these enhanced privileges, so OpenVPN can also relinquish them voluntarily by switching to a different effective user and group ID by using the `user` and `group` configuration directives (or the equivalent `--user` and `--group` command line options).

Changing to an unprivileged user protects the VPN endpoint from attack against the VPN tunnel itself by limiting the potential damage an attacker can do if a vulnerability in the OpenVPN codebase itself is exploited. Most GNU/Linux systems have a designated user (`nobody`) and group (`nobody` or `nogroup`) with no special privileges for exactly this reason. It's almost always a good idea to use these options to further secure your VPN system.

> :bulb: In some more complex setups, such as when a client needs to dynamically recreate an interface after the first is already established, dropping privileges this way can cause connection problems. In these situations, the `persist-tun` and `persist-key` options can help. They instruct OpenVPN to reuse the existing `tun` device (instead of closing and reopening it) or keying material (instead of re-reading the file from disk, which should probably be readable only by the `root` user) whenever the tunnel is restarted.

### Dealing with fascist firewalls

A properly secured site will most likely be protected by a firewall whose job it is to monitor incoming and, possibly, outgoing traffic. Strict firewalls will also intentionally block or reset connections that have been idle for some period of time. Since a VPN tunnel is designed to hide its traffic from outside observers, including firewalls, VPN connections are themselves sometimes also blocked.

In order to pass through or maintain a VPN tunnel across these strict firewalls, you may need to configure your endpoints to deal with them.

When a firewall simply outright blocks the default OpenVPN port (`1194`), you can instruct your OpenVPN endpoints to use other, permitted ports instead. The most common of these is port 443, the default port for HTTPS traffic. Since firewalls already expect to be unable to inspect encrypted Web traffic, and an OpenVPN tunnel operating in static key mode cannot be identified as such, using port 443 is a simple way to establish a VPN connection across an otherwise fascist firewall.

The `port` option (`--port` on the command line) is a shorthand option that simultaneously sets the `lport` (local port) and `rport` (remote port) options. Invoke OpenVPN with `--port 443` on both the client and the server to have both sides of the connection attempt to disguise themselves as encrypted Web traffic instead of OpenVPN traffic.

On the server:

```sh
sudo openvpn --dev tun --topology p2p --ifconfig 10.8.0.1 10.8.0.2 \
    --remote 172.22.33.3 --port 443 \
    --secret /vagrant/myovpn.key --key-direction 0
```

> :bulb: The `--port` option can also be set as a second argument to the `--remote` option. The above invocation could also have used `--remote 172.22.33.3 443`

> :bulb: This may still not be enough in some circumstances, because HTTP is traditionally carried by TCP, while OpenVPN uses UDP by default. More recently, newer versions of HTTP, namely HTTP/3, use UDP by default, but it's still common for firewalls to expect only TCP traffic over port 443. Fortunately, OpenVPN can use either UDP or TCP, as well. You can specify which (Layer 4) transport protocol you'd like OpenVPN to use for your tunnel with the `proto` configuration directive (or `--proto` command line option).
>
> Depending on what you are using your VPN tunnel for, making the tunnel with TCP instead of OpenVPN's default UDP may negatively impact the VPN's performance. This is because when TCP is tunneled over an underlying, but unreliable, TCP connection (a "TCP-over-TCP" scenario), packet loss on the underlying connection will trigger twice the retransmissions than normal as both the outer and the inner data streams each resend the lost packets independently of one another. Still, `--proto tcp` is occasionally very handy.
>
> As with the `--port` option, you can also specify the value for `--proto` as part of the `--remote` option by supplying a third argument. To switch the tunnel from UDP to TCP, you could therefore also have invoked OpenVPN with `--remote 172.22.33.3 443 tcp`. This is the most "HTTPS-like" OpenVPN tunnel you can make.

Once you have a connection established, however, you may find that the connection is lost every so often unless you are actively using the tunnel. This can happen when a stateful firewall places a time limit on an idle connection in the `ESTABLISHED` state. Since most Web traffic is bursty (load a page, then disconnect; then load a page a few minutes later, then disconnect again) while VPN traffic isn't (traffic flows only if you use the tunnel), you can easily find yourself disconnected annoyingly often.

The easiest way to deal with this is to use the `keepalive` configuration directive (`--keepalive` on the command line). This is a shorthand for the `--ping` and `--ping-restart` options, so it takes two arguments, one for each. For example `--keepalive 10 60` sets `--ping 10` and `--ping-restart 60`.

The `--ping 10` option sends a simple heartbeat-like message across the tunnel every ten seconds. This helps ensure otherwise "idle" connections are viewed as active by intermediary devices like firewalls. Meanwhile, `--ping-restart 60` instructs OpenVPN to restart the tunnel if 60 seconds pass without receiving a ping from the other side of the tunnel.

You can set both options to sensible values on both the server and the client by using the `--keepalive` option on the server only, but there's no harm in using `--keepalive` on both the server's and the client's configuration. When set on the server, using `--keepalive` doubles the value for `--ping-restart` in order to ensure the client will restart before the server does.

# Discussion

> :construction: TK-TODO

# Additional references

> :construction: TK-TODO
