# Introduction to Securing (Virtualized) Secure Shell Servers

[Secure Shell (SSH)](https://simple.wikipedia.org/wiki/Secure_Shell) is an encrypted network protocol originally developed in 1995. Since the 90’s, SSH has been a cornerstone of remote administration. It’s one of the first and still one of the most important tools any system administrator must learn to use. The most widely known use of SSH is its application as a remote login tool. The SSH protocol provides the operator of a computer system a secure channel over an unsecured network (like the Internet) to use to access the command line of a remote system, although any network-capable service can be secured using the SSH protocol.

To learn SSH, you need at least two computers talking to each other: one playing client (the administrator's workstation or laptop), and one playing server (the remote system that the admin wants to log in to from afar). These days, multi-machine setups like this are easy to create using the magic of [Virtual Machine (VM)](https://simple.wikipedia.org/wiki/Virtual_machine) hypervisors, which can create many (virtual) machines in just a few clicks. Sometimes referred to as a [“Virtual Private Cloud” (VPC)](https://en.wikipedia.org/wiki/Virtual_private_cloud), these lab environments offer completely free and astonishingly powerful educational and operational opportunities.

This workshop presents a brief crash course in configuring and hardening SSH. By digging into the gritty of hardening (securing) your SSH server and client configurations, you can be more confident that your computers are letting your comrades in and keeping [the CIA](https://www.ssh.com/ssh/cia-bothanspy-gyrfalcon) out.

# Contents

1. [Objectives](#objectives)
1. [Bill of materials](#bill-of-materials)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
1. [Practice](#practice)
    1. [Introduction](#introduction)
    1. [SSH server host keys and fingerprints](#ssh-server-host-keys-and-fingerprints)
    1. [Choosing safer host keys and host key algorithms](#choosing-safer-host-keys-and-host-key-algorithms)
    1. [Host key verification failures](#host-key-verification-failures)
    1. [Basic SSH authentication methods](#basic-ssh-authentication-methods)
        1. [SSH `password` authentication](#ssh-password-authentication)
        1. [SSH `publickey` authentication](#ssh-publickey-authentication)
1. [Discussion](#discussion)
    1. [What are NIST curves and why can't they be trusted?](#what-are-nist-curves-and-why-cant-they-be-trusted)
    1. [SSH certificates versus SSH keys](#ssh-certificates-versus-ssh-keys)
    1. [Additional host key verification options](#additional-host-key-verification-options)
    1. [PAM and GSSAPI SSH authentication methods](#pam-and-gssapi-ssh-authentication-methods)
    1. [Additional SSH authentication methods](#additional-ssh-authentication-methods)
        1. [SSH `hostbased` authentication](#ssh-hostbased-authentication)
        1. [SSH Kerberos authentication](#ssh-kerberos-authentication)
        1. [SSH `keyboard-interactive` authentication](#ssh-keyboard-interactive-authentication)
    1. [Requiring multiple SSH authentication methods](#requiring-multiple-ssh-authentication-methods)
    1. [Auditing your SSH configuration using `ssh-audit.py`](#auditing-your-ssh-configuration-using-ssh-auditpy)
    1. [Using SSH to create Virtual Private Networks (VPNs)](#using-ssh-to-create-virtual-private-networks-vpns)
        1. [SSH-based Virtual Private Networks with OpenSSH](#ssh-based-virtual-private-networks-with-openssh)
        1. [Transparent proxy VPN using SSH with `sshuttle`](#transparent-proxy-vpn-using-ssh-with-sshuttle)
1. [Additional references](#additional-references)

# Objectives

When you complete this lab, you will have acquired the following capabilities:

* The ability to verify the identity of the SSH server to which you are connecting.
* The ability to log in to an SSH server using SSH's public key-based ("passwordless") authentication mechanism.
* The ability to audit SSH server and client configuration files to spot potential security weaknesses and prove that these hardened configurations are in effect on both server and client endpoints.

To successfully complete this lab, you will need to construct a virtualized network that matches the diagram shown below. We suggest that you refer to this diagram throughout this practice lab to check your understanding of the material presented herein.

![Desired state of the virtualized network topology.](https://github.com/AnarchoTechNYC/meta/raw/master/train-the-trainers/practice-labs/introduction-to-securing-virtualized-secure-shell-servers/Virtualized%20Network%20Topology.svg?sanitize=true)

# Bill of materials

This folder contains the following files and folders:

* `README.md` - This file.
* `Vagrantfile` - The Vagrant configuration for our virtual private cloud, including the CentOS 7 SSH server and Ubuntu Bionic SSH client.
* `Virtualized Network Topology.svg` - A Scalable Vector Graphics image file displaying the desired network topology for this lab.
* `Virtualized Network Topology.xml` - An editable [Draw.IO](https://draw.io/) diagram that can be exported as SVG to produce the `Virtualized Network Topology.svg` image file.

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

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

Secure Shell (SSH) servers are more common than you might think. Although we've been focusing on creating a practice lab environment to experiment in, you should know that almost every computer has the capacity to function as an SSH server. The laptop you use every day can do it and, especially if you've been given a machine from your employer, it's possible that an SSH server is already running on it so that the IT department can administer it remotely. Many home routers have both a Web interface and a command line interface, and SSH is often what provides this command-line access.

> :beginner: There are many implementations of the SSH software suite in use today. In this lab, we use [OpenSSH](https://www.openssh.com/) because it is distributed with Apple's macOS, as well as most BSD and GNU/Linux operating systems by default. OpenSSH is also fully [Free Software](https://www.gnu.org/philosophy/free-sw.html). It was developed by building on the original, freely-distributed implementation of SSH as its base. A notable OpenSSH alternative is Tectia, the commercial implementation of the SSH suite productized by [SSH Communications Security (SCS), Incorporated](https://ssh.com/). Another notable alternative is [Dropbear SSH](https://matt.ucc.asn.au/dropbear/dropbear.html), which is designed to run more efficiently on devices with low power. For the most part, all of these implementations are interopable with one another; you can use any suite's `ssh` client to log in to a machine running any other suite's `sshd` server.
>
> :beginner: SSH is not the only remote command-line login tool. [Telnet](https://simple.wikipedia.org/wiki/Telnet) is a longstanding alternative, which many computers such as home routers still offer today. However, Telnet is fundamentally insecure because it has no built-in encryption capabilities. This omission is both why SSH was created in the first place and why SSH is so often used to replace Telnet. The other notable ancestor to SSH was the suite of programs known as the [Berkeley r-commands](https://en.wikipedia.org/wiki/Berkeley_r-commands), such as `rsh` ("remote shell") and `rlogin` ("remote login"). Like Telnet, these programs and their protocol lack encryption, so have all been obsoleted by SSH.

Of course, if you can access a machine's command line over SSH, so too can anyone else. This is why securing SSH access is so critically important. An SSH server is something like the "front door" to your computer. An unsecured SSH server on a network is by far the first thing most intruders look for. These days, if you put an SSH server up on the Internet, you'll see login attempts within minutes.

Of course, whether or not someone can actually log in to your computer via its SSH server depends on a number of factors. Most obviously, they must possess the appropriate *access credentials*. For example, they need to know the username and password combination for a user account that has SSH access, or they must have a copy of that user's private SSH key, which is literally a key to the front door. In this lab, we'll explore both of these *authentication methods*, and we'll see why password-based authentication is much less secure than SSH key-based authentication. We'll also reconfigure the SSH server so that only the more secure options are available for use, a process often known as *hardening*.

Moreover, the name "Secure Shell" has, over time, become something of a misnomer. Although originally invented as a mechanism to provide secure command line access to a shell over an unsecured network (hence the name, "secure shell"), SSH is actually a suite of several applications, none of which is a shell and only one of which is actually called `ssh`. The name also refers to a [specific transport protocol, called `SSH-TRANS`, that was eventually standardized as RFC 4253](https://tools.ietf.org/html/rfc4253). Thanks to this generic communications protocol, SSH can be used to secure any kind of communication between two endpoints, a process often referred to as *SSH tunneling*. For example, you can route your Web browser through an "SSH tunnel," thus making it appear to the Web site you're browsing as though your computer is the SSH server itself, and not your laptop.

> :beginner: [SSH tunneling](https://en.wikipedia.org/wiki/Tunneling_protocol#Secure_Shell_tunneling) is so termed because the protection SSH provides is on-the-fly encryption by the sender and on-the-fly decryption by the receiver. While a message is travelling from the sender to the receiver, it is impenetrable to any eavesdroppers who happen to be somewhere along the same path the message takes to get to its destination. Metaphorically, the message has entered "an encrypted tunnel." In network engineering parlance, when you route one application's network traffic inside a tunnel provided by a second, we say that you have *encapsulated* the first application's traffic inside the second's; to use the Web browsing example from earlier, we might say you have "encapsulated HTTP within SSH." This same form of impenetrable tunnel is also how vanilla SSH connections work, although in that case we typically say that the connection is simply "using SSH" rather than "being tunnelled." For more information, see this [visual guide to SSH tunnels](https://robotmoon.com/ssh-tunnels/).
>
> :beginner: :bulb: Technically, there are four (not one) distinct SSH protocols. The SSH Transport Layer Protocol (SSH-TRANS) is a base on which the other SSH protocols rely in order to operate securely over unsecured networks, making it the most interesting for our purposes. The other three SSH protocols, the SSH Authentication Protocol (SSH-AUTH), the SSH Connection Protocol (SSH-CONN), and the SSH File Transfer Protocol (SSH-SFTP) work in concert with the SSH Transport Layer Protocol (SSH-TRANS) to provide the full set of services provided by the whole suite of SSH software. Two of the other protocols have also been formally standardized as [RFC 4252 (SSH-AUTH)](https://tools.ietf.org/html/rfc4252), and [RFC 4254 (SSH-CONN)](https://tools.ietf.org/html/rfc4254), while the third, [SSH-SFTP, is still in "draft" status](https://tools.ietf.org/html/draft-ietf-secsh-filexfer-13).

Finally, despite its name, the "Secure" Shell still has some security weaknesses. For example, putting aside legal implications, it makes little difference if you lock your front door with a lock that's easy to pick. Intruders will still be able to get in through that very same front door. This is also true with SSH: using a weak SSH key won't keep any committed intruders out. Similarly, it doesn't matter how good your front door's lock is if the patio window is wide open. Burglars will just enter through the open window. This, too, matters when securing a machine that has an SSH server on it: why bother trying to break in through the SSH server if there's an easier way in?

Security is always going to be a process in which you are trying to raise the bar to unauthorized entry. There is never just one thing to do that will magically "secure" your stuff. The more precautions you take, the less likely you'll be chosen as a target of opportunistic attackers, and the longer it will take a dedicated adversary to intrude. The task of securing something ("hardening" it) is to slow attackers down as much as possible for as long as possible.

Let's get started by taking a look around.

## SSH server host keys and fingerprints

SSH has two main parts: a client, invoked by the `ssh(1)` command, and a server, invoked by the `sshd(8)` command. In day-to-day use, you'll start with using an SSH client and will be making connections to (i.e., requests of) a listening SSH server. Once the server hears (receives) a request from a client, it will respond in some way, either allowing or denying the request. Every SSH connection involves these two parts. We call these parts *endpoints* because they are each one end of the connection. This request-and-response model, in which one program makes requests of another, is called a [*client-server architecture*](https://wiki.wikipedia.org/wiki/Client%E2%80%93server_model).

> :beginner: There isn't anything particularly magical about "servers." For the purposes of this lab, we will always be treating the CentOS 7 virtual machine as the SSH server. The Ubuntu Bionic virtual machine will therefore be our SSH client. However, it doesn't particularly matter which operating system or even which machine is the client and which the server. When talking about servers and clients (any servers and clients, not just SSH) all that matters is that the server application is running. Wherever the server application is running is called "the server." This same logic holds for the client: wherever the `ssh` client program is run is said to be "the client." A single machine can thus be both a server and a client at the same time simply by running both the server application and a corresponding client application on it. Even in this case, however, we still speak about "the server" and "the client" as distinct entities.

Let's have a look around our SSH server first.

**Do this:**

1. Access a command line of your CentOS 7 virtual machine. You can do this by invoking the `vagrant ssh server`.
    > :beginner: Yes, it's a little ironic that Vagrant already provides an SSH facility for us to use. This is in fact the same SSH facility that we will be hardening. Not to worry, though! All this means is that we won't need to *install* the SSH software ourselves, since all Vagrant boxes already package SSH as part of their base box. This, like the first network adapter, is a hard requirement of all Vagrant boxes since Vagrant itself uses SSH to remotely administer the virtual machine. In fact, commands like `vagrant halt` are simply shortcuts for opening an SSH connection to your virtual machine and issuing the `shutdown(1)` command (or an equivalent, if the virtual machine is not running an operating system for which `shutdown` is a recognized command).
1. Have a close look at the `/etc/ssh` directory by invoking [`ls -l /etc/ssh`](https://explainshell.com/explain?cmd=ls+-l+%2Fetc%2Fssh). You will see a number of files, which are used by the various SSH programs, in a readout that looks something like this:
    ```sh
    [vagrant@localhost ~]$ ls -l /etc/ssh
    total 604
    -rw-r--r--. 1 root root     581843 Apr 11 04:21 moduli
    -rw-r--r--. 1 root root       2276 Apr 11 04:21 ssh_config
    -rw-------. 1 root root       3916 May 12 18:54 sshd_config
    -rw-r-----. 1 root ssh_keys    227 Aug 20 21:11 ssh_host_ecdsa_key
    -rw-r--r--. 1 root root        162 Aug 20 21:11 ssh_host_ecdsa_key.pub
    -rw-r-----. 1 root ssh_keys    387 Aug 20 21:11 ssh_host_ed25519_key
    -rw-r--r--. 1 root root         82 Aug 20 21:11 ssh_host_ed25519_key.pub
    -rw-r-----. 1 root ssh_keys   1679 Aug 20 21:11 ssh_host_rsa_key
    -rw-r--r--. 1 root root        382 Aug 20 21:11 ssh_host_rsa_key.pub
    ```

We will explore each of these files in detail soon but, for now, it's enough to have a look and see that the files are there. When looking at this list, you'll see there are two configuration files (`sshd_config` and `ssh_config`), and most of the other ones are key pairs (e.g., `ssh_host_ecdsa_key` and `ssh_host_ecdsa_key.pub`).

> :beginner: [Configuration files](https://github.com/AnarchoTechNYC/meta/wiki/Configuration-file) are a common way that programs describe application preferences or allow a user to customize a program's options. There's no need to be intimidated when you encounter configuration files. They are a simply a textual analog to the "Preferences" or "Settings" or "Options" windows is graphical applications.

The `sshd_config` file in the `/etc/ssh` folder on the server is the SSH server's primary configuration file. That is to say it is the file read by the `sshd` (SSH daemon) program whenever it is launched. The `sshd` program is the program that starts and runs the SSH server process; it is *the* SSH server part of your "SSH server machine." Tweaking the values of the various configuration directives in this file will change the behavior of your SSH server. We will be spending a great deal of this lab modifying the values in this file and ensuring that our changes have been applied.

> :beginner: As you may know, when available on a given system, the `man` command can be used to look up details about command invocations. This same `man` command can also be used to look up information about configuration files. Section 5 of the manual is the typical place to store file format information, and so invoking `man sshd_config` or `man 5 sshd_config` will often show you a manual page that describes the format of the `sshd_config` file along with many, if not all, of its configuration directives. Unfortunately, [CentOS 7's Vagrant box does not include manual pages for SSH](https://bugs.centos.org/view.php?id=14633), but most other systems do. Try `man sshd_config` on the Ubuntu Bionic virtual machine, for example.
>
> :beginner: You may have noticed the `ssh_config` file. Not to be confused with the `sshd_config` file, this is the system-wide configuration file for the `ssh` client program. We will have a closer look at this file when we explore our SSH client's environment. So, for now, simply take care not to confuse the SSH daemon's configuration file (`sshd_config`) with the SSH client program's configuration file (`ssh_config`). Both files exist on the same machine since a single machine might be running both an SSH client and an SSH server at the same time.

The set of files that begin with `ssh_host_` and end in `_key` are called, rather predictably, *host keys*. There are a number of them: `ssh_host_ecdsa_key`, `ssh_host_ed25519_key`, `ssh_host_rsa_key`, and so forth. Each of these files contains the server's own, private cryptographic identity, which uniquely identifies this SSH server distinct from any other SSH server. Therefore, these files are called *private host keys*. When the server receives a request from a client asking the server to identify itself using the [Elliptic Curve Digital Signature Algorithm (ECDSA)](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm), the server will respond with data partly derived from reading the `ssh_host_ecdsa_key` file. If the client makes a similar request but asks the server to use the [Rivest–Shamir–Adleman (RSA) algorithm](https://en.wikipedia.org/wiki/RSA_%28cryptosystem%29), the server will respond with data partly derived from its `ssh_host_rsa_key` file, and so on.

> :beginner: :construction: TK-TODO: Don't stress about cryptographic public key algorithms. :)

It is critically important that your server's private host keys remain safe, that is, accessible only to you and the SSH server itself. Preferably, this could mean they are also *physically* located on the server, i.e., that the files map to data stored on a physical hard disk installed within the SSH server's metal chassis. If an attacker is able to read one of these files, they can copy it, install it into their own SSH server, and pretend to be your server to any SSH clients that request a connection. There may be no way for you to know that you are making a connection to the attacker's machine rather than your own. This is why we often refer to key files as *identity files* in SSH parlance; host keys, not IP addresses or usernames, are SSH identities.

Each private host key file has a counterpart, which is safe to share somewhat more publicly, whose name is the same as the private key file except for the fact that it ends in `.pub`. These files are predictably termed *public host keys*. The public key file for a given private key is the second "half" of the input data that the server uses to generate its response to a request from a client to identify itself. When you're using SSH to connect to a remote machine, this data is ultimately presented to you, the human, so that you can make a judgement about whether or not you feel safe enough continuing the conversation with the machine on the other end of the line.

> :beginner: Public keys are not really "half" of anything. They are simply a less-sensitive counterpart to their more sensitive component, the matching private key. The terms public and private keys can also be confusing. One easy way to remember which is which is simply to remember that a private key is so named because it must remain secret (private). This means you must take care never to send your private key files in unsecured messages, such as unencrypted emails, text messages, or place them in unsafe locations such as a shared file server (like Google Drive). In contrast, public keys are so named because doing any of those things is probably fine.
>
> In the context of SSH, you can further think of private keys as identities, *who* you are. (Indeed, you'll often hear private keys referred to as "identity files" when dealing with SSH.) Meanwhile, you can think of public keys as a representation of your appearance, *what you look like*. When you share your SSH public key with another system, you are making it possible for that system to recognize you, so they don't treat you like a stranger, but you would never want to have them able to *be* you, which is why you keep your private key, well, private.

Let's have a look at what it means to make a judgement about whether or not to continue a conversation with some SSH server on the other end of the line.

**Do this:**

1. From a terminal in your CentOS 7 virtual machine, print the contents of the `/etc/ssh/ssh_host_ecdsa_key.pub` file to your screen:
    ```sh
    cat /etc/ssh/ssh_host_ecdsa_key.pub
    ```
    You'll see a line of text that begins with `ecdsa-sha2-nistp256`, followed by a single space, followed by a long string of letters and numbers, and a few symbols. This long string is an encoded representation of the server's ECDSA public host key itself.
    > :beginner: :construction: TK-TODO: The encoding used here is a common one called *Base64 encoding*.
1. Next, start a connection from the server to itself using the `ssh` client program:
    ```sh
    ssh localhost
    ```
    As soon as you do so, you'll be prompted to make a security decision: continue connecting, or not? Your terminal output may look something like this:
    ```sh
    The authenticity of host 'localhost (::1)' can't be established.
    ECDSA key fingerprint is SHA256:bC7KnOz29hPzOtCHTI5faWHfOh7Hw2LmS13UWuZQsO0.
    ECDSA key fingerprint is MD5:5e:f9:00:ec:e1:83:cb:4a:d2:d0:8a:d7:24:9b:4d:65.
    Are you sure you want to continue connecting (yes/no)?
    ```
    > :beginner: Note that the specific fingerprints shown above will be different for you than they are in this practice lab guide. This is because your SSH server is not the author's. Indeed, when you first performed [the `vagrant up` procedure described in the "Virtual machine startup" section of the set up](#virtual-machine-startup) (a process known as *provisioning*), one of the steps Vagrant automatically takes is to regenerate the SSH server's host keys to ensure that it has a new, unique identity.

    You're being prompted because the user account from which you initiated the SSH connection has never tried connecting to this SSH server before. As far as SSH is concerned, you're talking to a stranger. By defintion, SSH has no prior knowledge of this server, and therefore wants you to personally approve communication with this particular endpoint. The fingerprint that `ssh` shows you here is a unique identity (like a literal fingerprint) of the specific endpoint that responded to your connection request. How do we know if this is the right SSH server or not? Well, since we already have a command line on this server, we can check its public key fingerprint ourselves.

    > :beginner: :bulb: If you are trying to connect to an SSH server for the first time for which you don't already have some way of reading the public host key, you need to find some other way of checking the server's fingerprint before you continue connecting. Typically, this is done by simply asking the server's administrator for the SSH server's public key fingerprint over some other secure channel, such as an authenticated (signed) email, a Signal private message with a verified contact, or an equivalent. You could also simply trust that this first connection is not being intercepted, a paradigm cleverly termed [TOFU ("Trust On First Use")](https://en.wikipedia.org/wiki/Trust_on_first_use), but this is obviously suboptimal for the appropriately paranoid among us.
1. Type `no` at the SSH prompt and hit the `Return` or `Enter` key to abort your connection.
1. Compute the SSH server's public ECDSA fingerprint using one of the SSH suite's programs, `ssh-keygen(1)`:
    ```sh
    ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub
    ```
    The `-l` option asks `ssh-keygen` to show fingerprints of keys, while the `-f` option specifies the path to the file containing keys that we care to view. The output of this command should show you an exact match for the fingerprint you saw earlier. For example:
    ```sh
    [vagrant@localhost ~]$ ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub
    256 SHA256:bC7KnOz29hPzOtCHTI5faWHfOh7Hw2LmS13UWuZQsO0 no comment (ECDSA)
    ```
    > :beginner: On CentOS 7, `ssh-keygen`'s default is to show keys using the SHA-256 hashing algorithm. You can ask for an alternative representation by passing the `-E` option. For example, to show the same key's MD5 fingerprint instead of its SHA-256 fingerprint:
    >
    > ```sh
    > [vagrant@localhost ~]$ ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub -E md5
    > 256 MD5:5e:f9:00:ec:e1:83:cb:4a:d2:d0:8a:d7:24:9b:4d:65 no comment (ECDSA)
    > ```
    >
    > Although there are security implications regarding which hashing algorithm you choose (and we strongly recommend avoiding older ones, like MD5), the important thing to notice for now is that regardless of which algorithm you choose, it matches the fingerprint reported by `ssh` when you tried to connect a moment ago. See [Foundations: Cryptographic hash](https://github.com/AnarchoTechNYC/meta/wiki/Cryptographic-hash) for more information about hashing algorithms.

Now you can see how host keys are used as SSH's mechanism for identifying servers to clients. You must check the server's fingerprint to be confident that you're connecting to the machine you intended to reach. Inversely, this same mechanism is fundamentally the same for identifying clients to servers, so the server can be confident that it's only allowing authorized users to log in. We'll look at client SSH keys in more detail soon but, first, let's have a quick look at our SSH client itself.

**Do this:**

1. From your host machine, access a command line of your Ubuntu Bionic virtual machine. You can do this through the VirtualBox Manager graphical application or by invoking the `vagrant ssh client`.
1. Use `ssh` to start a connection to the SSH server using its IP address:
    ```sh
    vagrant@ssh-client:~$ ssh 172.16.1.111
    The authenticity of host '172.16.1.111 (172.16.1.111)' can't be established.
    ECDSA key fingerprint is SHA256:bC7KnOz29hPzOtCHTI5faWHfOh7Hw2LmS13UWuZQsO0.
    Are you sure you want to continue connecting (yes/no)?
    ```
    Before you do anything else, take a moment to read the output here carefully. You are once again confronted with the message, "`The authenticity of host '172.16.1.111 (172.16.1.111)' can't be established.`" Following that, you see the fingerprint of one of the server's host keys (the ECDSA one, in this case). This fingerprint uniquely identifies the machine to which you are connecting. Notice that even though the IP address of the host is different this time than last time (where it was `localhost (::1)`), the fingerprint is the same. Again, IP addresses are addresses, not server identities. Always use the server's key fingerprint to ensure you are connecting to the endpoint you intend.
1. Type `no` and then press the `Return` or `Enter` keys to abort your connection.

Don't worry, we'll connect again in just a moment. Before we do, though, we need to become familiar with a few important files that your SSH client uses regularly. These are all located in your user account's home folder, inside a hidden folder called `.ssh`. Let's have a look inside it.

> :beginner: A "hidden folder" is not exactly hidden per se, it's just not shown by default. You can tell it's a hidden folder because its name begins with a single dot (`.`). These so-called "dotfiles" are omitted from directory listings such as when you invoke the `ls(1)` command, unless you explicitly ask for them to be shown by using the `-a` ("show all files") option. Hidden folders or files typically store information that isn't usually relevant to someone's day-to-day use of their computer, or that the application they relate to doesn't want a novice user to be editing manually, but they aren't special in any other way. Don't mistake a "hidden" folder for a folder that has actual security controls placed on it; they are not the same.

**Do this:**

1. List the contents of your Ubuntu Bionic machine's `vagrant` home directory:
    ```sh
    cd    # Be sure you are starting from your home folder.
    ls    # This will return no output, even though the folder is *not* empty.
    ls -a # This will reveal the existence of "hidden" files and folders.
    ```
1. List the contents of `vagrant`'s `.ssh` directory. You will see only one file, for now:
    ```sh
    vagrant@ssh-client:~$ ls .ssh/
    authorized_keys
    ```
    Take note of the `authorized_keys` file, and that no other files are present.
    > :beginner: The `authorized_keys` file is discussed in [the "Basic SSH authentication methods" section](#basic-ssh-authentication-methods), so ignore it for now. This file exists because it was created by the creator of the Vagrant box. It's what allows you to use the `vagrant ssh` command successfully. In a brand-new machine that you build from scratch, you may need to make this file yourself. That's not difficult but, again, is discussed later.
1. Make another connection to the CentOS 7 SSH server. After double-checking that the fingerprint is correct, type `yes` when prompted to continue the connection. The complete output might look something like this:
    ```sh
    vagrant@ssh-client:~$ ssh 172.16.1.111
    The authenticity of host '172.16.1.111 (172.16.1.111)' can't be established.
    ECDSA key fingerprint is SHA256:bC7KnOz29hPzOtCHTI5faWHfOh7Hw2LmS13UWuZQsO0.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added '172.16.1.111' (ECDSA) to the list of known hosts.
    Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
    ```
    This was *not* a successful login (as shown by the line starting with "`Permission denied`"), but that's to be expected at this time. The important thing to note is the `Warning` informing you that the `ECDSA` key fingerprint for the server at `172.16.1.111` was added to the list of known hosts.
1. List the contents of your `.ssh` directory again. This time, you will see a second file, called `known_hosts`:
    ```sh
    vagrant@ssh-client:~$ ls .ssh/
    authorized_keys  known_hosts
    ```
1. Make another connection to the CentOS SSH server again. This time, notice that we are not presented with the key fingerprint as we have been before:
    ```sh
    vagrant@ssh-client:~$ ssh 172.16.1.111
    Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
    ```
    The reason, as you may have guessed, is because the key fingerprint is now stored in the `known_hosts` file, which (unsurprisingly) contains a list of all the hosts (servers) known to the SSH client. In other words, it's a list of the addresses of non-strangers, along with information about what the servers at that address should look like (i.e., their key fingerprint).
1. Have a look at the raw contents of the SSH client's `known_hosts` file:
    ```sh
    cat ~/.ssh/known_hosts
    ```
    Notice that the end of the single line on this file matches exactly the contents of the CentOS 7 server's `ssh_host_ecdsa_key.pub` file. It is a copy of the server's ECDSA public key.
1. Have a look at the same file, but this time using the `ssh-keygen` command:
    ```sh
    ssh-keygen -l -f ~/.ssh/known_hosts
    ```
    Notice again that the fingerprint shown matches that of the fingerprint first presented to you when you connected to the server.
1. Have one final look at the file, but this time adding the `-F` option, which finds a specific host in the file:
    ```sh
    ssh-keygen -l -f ~/.ssh/known_hosts -F 172.16.1.111
    ```
    This is the most human-readable output, as it displays the SSH server's address and fingerprint in the same manner as when you are using the `ssh` client program itself. All of these formats are equivalent, it's just a matter of presenting the data therein in one way or another. The point here is to illustrate that once you make a connection to a server, your SSH client program remembers this fact by writing a new line with the relevant details into the `known_hosts` file.
    > :bulb: In older versions of SSH, the `known_hosts` file listed the addresses of remote servers in cleartext. Newer versions of SSH (such as those used in this lab) no longer default to this behavior, which is why the host address portion of a `known_hosts` file is obscured. As long as your SSH client programs support it, you can immediately improve the security of your `known_hosts` file by hashing all the addresses with `ssh-keygen`'s `-H` option:
    >
    > ```sh
    > ssh-keygen -H -f ~/.ssh/known_hosts # Hash known host addresses.
    > # If everything looks oaky, then...
    > rm -i ~/.ssh/known_hosts.old        # ...delete the backup file created by `ssh-keygen`.
    > ```
    >
    > :beginner: If you're just getting started with SSH, the above procedure is probably irrelevant because your SSH is (hopefully!) new enough that this happens by default. Anytime you make a connection to an SSH server and save its fingerprint in your `known_hosts` file (by answering `yes` to the connection prompt), the address is automatically obscured for you. Therefore, we won't spend any more time on it. If you've been using SSH for a while and already have a `known_hosts` file, though, consider trying out the above for good measure. Obscuring the addresses of the SSH servers you know about makes it that much harder for a dedicated attacker to spread havoc in your network because, even if they do somehow get a copy of your `known_hosts` file, they won't be able to learn where you're making SSH connections to as easily as they would have if the `known_hosts` file contained unencrypted addresses.
    >
    > :beginner: Should you ever want to remove an SSH server from the list of known hosts, you can do so with `ssh-keygen`'s `-R` option:
    >
    > ```sh
    > # Remove host 172.16.1.111.
    > ssh-keygen -R 172.16.1.111 -f ~/.ssh/known_hosts
    > rm -i ~/.ssh/known_hosts.old # Optionally, remove the backup file `ssh-keygen` made.
    > ```
    >
    > Feel free to play around with adding and removing hosts from the `known_hosts` file. Just remember that if you remove the SSH server's key fingerprint from the list in this file, you will be prompted for approval the next time you try to connect to it using `ssh`.

While most modern SSH servers and clients come with arguably decent defaults, you can make choices about which cryptographic ciphers and algorithms you'd like to use. So far, we've been seeing "ECDSA" host keys because that's what our SSH programs use by default. Unfortunately, if you have any reason to distrust The Powers That Be (like, say, your government), you shouldn't rely on the defaults distributed in most SSH server and client software. Let's take a closer look at why that is. At the same time, we'll take the opportunity to learn a little more about how you can control the behavior of your SSH servers and clients.

## Choosing safer host keys and host key algorithms

Now that you understand what a host key is and have some familiarity with its utility for making SSH connections to the endpoint you intend to reach, let's examine how the server actually chooses a host key for a given connection, and why you might need to audit that choice more deeply. There is a long story and a short story to this. For the purposes of this lab, we'll only need the short story but, if you're deeply curious, check out the "[What are NIST curves and why can't they be trusted?](#what-are-nist-curves-and-why-cant-they-be-trusted)" section of the discussion, below, after reading through this section.

We've already seen that the SSH server has several different host keys. These were stored in files with names like `ssh_host_ecdsa_key`, `ssh_host_ed25519_key`, `ssh_host_rsa_key`, and so on. For a given connection, however, only one of these is actually used. Exactly which key is used depends on two things that are, once you think about it, pretty obvious. They are:

* Which type of key will the connecting client accept?
* Which type of key does the server have available?

Only the intersection of keys that the client accepts and that the server actually has can be used for the connection between that client and that server at that time. After all, if the client refuses to accept keys of a given type, then the server cannot use its host key of that type to assure the client it's connecting to the right endpoint. Similarly, if a client requests a key type that the server simply does not have or refuses to use, then the server cannot or will not present that host key to the client, either.

The process of figuring out which host key the client will accept, which the server can provide, and then agreeing to actually use a given option from the resulting set available is called *host key negotiation*.

> :beginner: Host key negotiation is, itself, part of a larger process (that we are about to see, but not yet discuss in much detail), called *parameter negotiation*. Each of the parameters used to successfully complete an SSH-TRANS connection can be chosen by you, just like the host key algorithm can be. For the sake of simplicity, we only deal with host keys for now. Later on in this lab, however, we will revisit SSH-TRANS parameter negotiation to focus on the other session parameters.

We can watch this process take place in real time by starting an SSH connection to a server with the `-v` option specified twice, like `ssh -vv` or `ssh -v -v`. Invoking `ssh` this way turns on "level 2 debugging output," which means your SSH client will tell you some of what it's doing as it's doing it.

**Do this:**

1. Start an SSH connection to your CentOS server with the client's verbosity turned up to level 2:
    ```sh
    ssh -vv 172.16.1.111
    ```
    > :beginner: There's going to be a *lot* of output from this command. This is all intended to help you troubleshoot problems, although here we're using it to show you some of how SSH works "under the hood." If you ever do run into a problem, though, you can use this technique to get a lot more information about what might be going wrong with the connection you're trying to make.
    >
    > You can also tweak exactly how much output you'll get by specifying the `-v` option a different number of times. The less times you pass `-v`, the less information will be printed when you run `ssh`. We're using `-vv` because the specific thing we're looking for is only printed at level `debug2` and greater, so passing `-v` just one time would not have shown it to us.
    >
    > When started this way, most lines of output will be labelled with the debugging level that the message on the remainder of the line is associated with. In other words, lines that begin with `debug1: ` will be printed when you run `ssh -v`, whereas lines that begin with `debug2: ` will only be printed when you run `ssh -vv` (or `ssh -vvv` and so on).
    >
    > If you're comfortable on a command line, you can use this fact to quickly filter the output to show you just what you're interested in. For example, [`ssh -vv 172.16.1.111 2>&1 | grep debug2`](https://explainshell.com/explain?cmd=ssh+-vv+172.16.1.111+2%3E%261+%7C+grep+debug2) will only show you the level 2 debugging output.

Rather than dissect this output line by line, let's focus on just a few of the more important messages. The very first line will look like something like this:

```
OpenSSH_7.2p2 Ubuntu-4ubuntu2.4, OpenSSL 1.0.2g  1 Mar 2016
```

This is the same output you'll see if you invoke `ssh` asking for its version information with the `-V` option:

```sh
vagrant@ssh-client:~$ ssh -V
OpenSSH_7.2p2 Ubuntu-4ubuntu2.4, OpenSSL 1.0.2g  1 Mar 2016
```

> :beginner: The version of a program is important to know because the same program might have been updated with new features that are only available in certain versions of it. In this case, we see that the version of our SSH suite is `OpenSSH_7.2p2` ("OpenSSH version 7.2 patch level 2"). This output also shows us the operating system on which we are running SSH ("Ubuntu"), along with the versions of one of the most important components of the SSH suite itself, OpenSSL ("`OpenSSL 1.0.2g`"). OpenSSL is the program that provides many other programs with their cryptographic capabilities, and could be the topic of a whole other guide. It also has a command line interface, which you can learn some more about from its manual page (`man openssl`). Finally, we see the date on which this specific SSH suite was built: March 1, 2016.
>
> :beginner: :bulb: :warning: In the verbose debugging output, you will see several messages about choosing a version of the SSH protocol, 2.0 in this case. As you can infer, this means there are other versions of SSH (or, more technically, the SSH-TRANS protocol). However, all prior versions (the most common of which are 1.3 and 1.5) are unfixably broken and have been obsoleted by the modern 2.0 version for decades. You should therefore always use SSH-2.0, which has long been the default protocol version in the overwhelming majority of SSH software distributed today. Therefore, in this lab, we all but ignore  the existence of SSH protocols prior to 2.0.


Immediately after this, we see `ssh` telling us it is loading its configuration files:

```
debug1: Reading configuration data /home/vagrant/.ssh/config
debug1: Reading configuration data /etc/ssh/ssh_config
```

Not unlike the SSH server program (`sshd`), the SSH client program (`ssh`) loads configuration files from specific, pre-defined places. The first of these is the invoking user's own configuration file, typically simply called `config` and located within that user's `.ssh` hidden folder in their home folder. We don't have such a file, so `ssh` simply continues checking for configuration files in the remainder of the places it expects to find them. In this case, that's `/etc/ssh/ssh_config` (remember, not to be confused with the SSH daemon's configuration file, `sshd_config`). Since this file exists and there are configuration directives that apply to the current invocation, `ssh` tells us it will set these options. It helpfully points us to exactly where in the file these directives are written:

```
debug1: /etc/ssh/ssh_config line 19: Applying options for *
```

We could open the `/etc/ssh/ssh_config` file and sure enough, on line 19, we would find some configuration directives. Let's skip this for now, though, as we'll have plenty of time to examine the configuration file soon enough.

Just a few lines later, we can see that `ssh` reports it is connecting to the server at the address we gave it, and that the connection succeeds ("`Connection established.`"). Right after that, `ssh` tries loading its own identity files, its *client [host] keys*, but finds that none exist ("`No such file or directory`"). This isn't an error, exactly, since none exist because we haven't created any yet. Finally, we see the beginning of an authentication attempt as `ssh` reports it is `Authenticating to 172.16.1.111:22 as 'vagrant'`. Here's that chunk of the output in full:

```
debug1: Connecting to 172.16.1.111 [172.16.1.111] port 22.
debug1: Connection established.
debug1: key_load_public: No such file or directory
debug1: identity file /home/vagrant/.ssh/id_rsa type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/vagrant/.ssh/id_rsa-cert type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/vagrant/.ssh/id_dsa type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/vagrant/.ssh/id_dsa-cert type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/vagrant/.ssh/id_ecdsa type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/vagrant/.ssh/id_ecdsa-cert type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/vagrant/.ssh/id_ed25519 type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/vagrant/.ssh/id_ed25519-cert type -1
debug1: Enabling compatibility mode for protocol 2.0
debug1: Local version string SSH-2.0-OpenSSH_7.2p2 Ubuntu-4ubuntu2.4
debug1: Remote protocol version 2.0, remote software version OpenSSH_7.4
debug1: match: OpenSSH_7.4 pat OpenSSH* compat 0x04000000
debug2: fd 3 setting O_NONBLOCK
debug1: Authenticating to 172.16.1.111:22 as 'vagrant'
debug1: SSH2_MSG_KEXINIT sent
debug1: SSH2_MSG_KEXINIT received
```

Immediately following this is the beginning of what we are looking for: the client's *key exchange initialization proposal* ("`local client KEXINIT proposal`"). This is the portion of the SSH connection start up process where the client program, after loading its configurations, tells the server what it's able and willing to use for various aspects of the remainder of the conversation, called *session parameters*. The first session parameter described is the key exchange algorithm ("`KEX algorithms`"), and the next one is which host key algorithms are acceptable ("`host key algorithms`"):

```
debug2: local client KEXINIT proposal
debug2: KEX algorithms: curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha1,ext-info-c
debug2: host key algorithms: ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp521-cert-v01@openssh.com,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256,ssh-rsa
```

The possible values for each of the connection's session parameters are listed here in a comma-separated list. The list is sorted by order of preference: the first value listed is the one the client preferrs most. This output tells us that the `ssh` client program prefers to use the `ecdsa-sha2-nistp256-cert-v01@openssh.com` host key algorithm. If the server is willing and able to use this as well, then that is the host key algorithm that will be agreed upon and ultimately used. If the server does not support this specific host key type, then the client will accept any of the other ones listed here.

As you can see, this isn't a small list. There are 12 items in the acceptable host key algorithm list that the client sends to the server. They are, in order of preference:

* `ecdsa-sha2-nistp256-cert-v01@openssh.com`
* `ecdsa-sha2-nistp384-cert-v01@openssh.com`
* `ecdsa-sha2-nistp521-cert-v01@openssh.com`
* `ecdsa-sha2-nistp256`
* `ecdsa-sha2-nistp384`
* `ecdsa-sha2-nistp521`
* `ssh-ed25519-cert-v01@openssh.com`
* `ssh-rsa-cert-v01@openssh.com`
* `ssh-ed25519`
* `rsa-sha2-512`
* `rsa-sha2-256`
* `ssh-rsa`

Put simply, some of these are better than others. What we'd like to do is have `ssh` only offer to use the better ones. To do this, we need to remove the ones that we don't trust (for, y'know, whatever reason).

> :beginner: SSH can be installed with support for different algorithms. To find out which specific algorithms are supported by your copy of SSH, you can query the SSH client directly. Use the `-Q` option for this. For example, to ask your SSH client what host key algorithms it supports, use `-Q key`:
>
> ```sh
> vagrant@ssh-client:~$ ssh -Q key
> ssh-ed25519
> ssh-ed25519-cert-v01@openssh.com
> ssh-rsa
> ssh-dss
> ecdsa-sha2-nistp256
> ecdsa-sha2-nistp384
> ecdsa-sha2-nistp521
> ssh-rsa-cert-v01@openssh.com
> ssh-dss-cert-v01@openssh.com
> ecdsa-sha2-nistp256-cert-v01@openssh.com
> ecdsa-sha2-nistp384-cert-v01@openssh.com
> ecdsa-sha2-nistp521-cert-v01@openssh.com
> ```
>
> You can use `-Q` to ask `ssh` for a list of the supported values for any of the various session parameters of your SSH connection. For example, to see a list of the key exchange algorithms (which we'll talk about later) available for your use with this specific `ssh` client, use `-Q kex`:
>
> ```sh
> vagrant@ssh-client:~$ ssh -Q kex
> diffie-hellman-group1-sha1
> diffie-hellman-group14-sha1
> diffie-hellman-group-exchange-sha1
> diffie-hellman-group-exchange-sha256
> ecdh-sha2-nistp256
> ecdh-sha2-nistp384
> ecdh-sha2-nistp521
> curve25519-sha256@libssh.org
> ```
>
> Remember that these are simply lists of *supported* values, not the actual values being used for a given connection. Always use `ssh -vv` to see the `local client KEXINIT proposal` that is actually being sent to the server for a given connection.

Sure enough, later on in the debugging output we can see that the server sends its own proposal, and it overlaps with the host key algorithms proposed by the client. Here's the relevant snippet:

```
debug2: peer server KEXINIT proposal
debug2: KEX algorithms: curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha256,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
debug2: host key algorithms: ssh-rsa,rsa-sha2-512,rsa-sha2-256,ecdsa-sha2-nistp256,ssh-ed25519
```

In this case, the server is telling the client that it prefers to use the `ssh-rsa` host key algorithm, but will also use numerous others. This is the server reporting to the client what options it has to choose from. A bit later on, we can then see the client printing the choices it ultimately made. Given the list of available options it received from the server and its own preferences, the host key algorithm that the client most strongly preferred that is also acceptable to this specific server is `ecdsa-sha2-nistp256`:

```
debug1: kex: host key algorithm: ecdsa-sha2-nistp256
```

This specific algorithm, "ECDSA using the NIST P-256 curve and the SHA2 hash family," is generally considered very strong at the time of this writing, with one extremely notable problem: it's designed to be vulnerable to the NSA's code-breaking efforts. Exactly why that's true is part of "the long story" that you can read more about in the "[What are NIST curves and why can't they be trusted?](#what-are-nist-curves-and-why-cant-they-be-trusted)" discussion section, below. For now, suffice it to say that the academic community widely believes nation state actors such as the United States's National Security Agency (NSA), the United Kingdom's Government Communications Headquarters (GCHQ), and other similar agencies have the ability to decrypt (break, or "crack") certain algorithms, including this one.

> :beginner: :bulb: :black_flag: Specifically, leaked documents provided by Edward Snowden in 2013 revealed, among other disturbing but hardly surprising things, that the NSA advocated for the National Institute of Standards and Technology (NIST) to publish recommendations that are now understood to be intentionally vulnerable to their supercomputers. This isn't a theory. It's a [well](https://blog.cr.yp.to/20140323-ecdsa.html)-[researched](https://projectbullrun.org/dual-ec/vulnerability.html), [widely published](https://www.wired.com/2013/09/nsa-backdoor/), proven series of events whose bottom line amounts to the NSA intentionally undermining the efficacy of certain cryptographic protocols, and then [bribing prominent security companies to use those weakened algorithms by default](https://www.reuters.com/article/us-usa-security-rsa/exclusive-secret-contract-tied-nsa-and-security-industry-pioneer-idUSBRE9BJ1C220131220). In practice, it means that NIST's recommendations to use certain encryption schemes cannot be trusted. In SSH, those encryption schemes are the ones with `nistp` in their name. Even if you can't be convinced that these facts are facts (we get it, it's emotionally difficult for people who are not psychopaths—like you!—to believe that psychopaths in positions of power are intentionally working to ensure their domination at the scale they are doing so today), why take the risk? There are stronger and even faster algorithms available.

Instructing `ssh` to use a different host key algorithm when connecting to an SSH server is easy. Choosing a better algorithm, however, can be trickier if you aren't a cryptographer yourself. The best most of us can do is think critically about the situation we find ourselves in, review the academic literature in as much detail as we are able, or find a more knowledgable person whom we find trustworthy to ask for advice. For the purpose of this guide, the author assumes you find them trustworthy enough to make decent recommendations. That being said, you are once again encouraged to peruse the "[What are NIST curves and why can't they be trusted?](#what-are-nist-curves-and-why-cant-they-be-trusted)" discussion section for additional details.

Operationally speaking, choosing safer cryptographic algorithms can be broken down into two major considerations:

* How widely vetted, and publicly disclosed, is the cryptographic scheme? The more skilled cryptographers have audited a given algorithm, and the more they have published about it and its details, the better.
* How widely implemented in the tools you need to use is the cryptographic scheme? Obviously, if the tool you're trying to use does not support the use of a given cryptographic algorithm, well, you can't use it.

The author's favorite cryptosystem is [the Ed25519 public-key signature system](https://ed25519.cr.yp.to/). It is very similar to NIST's ECDSA scheme, except for the fact that it did not originate with the NSA, uses different mathematical constants ("curves") than the P-256 curve recommended by NIST, and is even faster. Fortunately, many modern SSH suites available today support this algorithm for numerous parts of the SSH connection and encryption process. This can be verified using the `-Q` option to query your `ssh` installation.

> :beginner: :bulb: Ed25519 is so named because it is a variant on the [Edwards-curve Digital Signature Algorithm (EdDSA)](https://en.wikipedia.org/wiki/EdDSA), which uses [Curve25519](https://en.wikipedia.org/wiki/Curve25519). What matters for our purposes is that you can recognize these names in SSH's output. You don't need to be a cryptographer to use these cryptographic systems, much like you don't need to be a computer scientist in order to use a computer. That said, it certainly helps to gain a little bit of familiarity with the terminology of the technology you're using, just as it would help to know English when driving in the United States so that you can read the road signs you encounter during your journey.

Let's try using the Ed25519 algorithm for exchanging host keys with our SSH server. To do this, we'll configure our SSH client to propose only this one host key algorithm to the server. SSH configuration directives can be passed directly to the `ssh` client using the `-o` option in the invocation of `ssh` itself, making custom configurations very easy to experiment with. The configuration directive we need to use to change the list of preferred host key algorithms is called `HostKeyAlgorithms`.

> :beginner: Remember that the available configuration directives you can use to change the behavior of the `ssh` client program are listed in the `ssh_config(5)` manual page. This is typically available to you using the `man ssh_config` command. Once again, don't confuse this with the `sshd_config` file or its corresponding manual page, `sshd_config(5)`! Even though many of the same configuration directives are available to both the `sshd` (server) and `ssh` (client) programs, you'll save yourself quite a bit of trouble by reading the correct manual page. :)

**Do this:**

1. First, remove the SSH client's knowledge of any previous connections by deleting the SSH server's host key from your `known_hosts` file:
    ```sh
    ssh-keygen -R 172.16.1.111
    ```
1. Next, list the host key algorithms available to you: 
    ```sh
    ssh -Q key
    ```
    Several of the available options should now be at least cursorily familiar. We see the `ecdsa-sha2-nistp256` algorithm that we'd like to avoid from now on, along with the `ssh-ed25519` and `ssh-ed25519-cert-v01@openssh.com` algorithms that use the Ed25519 cryptosystem, which we like.
    > :beginner: The differences between the `ssh-ed25519` and `ssh-ed25519-cert-v01@openssh.com` values relate to the use of SSH certificates instead of plain SSH keys. In this introductory lab, we won't be using SSH certificates at all, but you can learn more about the distinction between plain SSH keys and SSH certificates in the [SSH certificates versus SSH keys](#ssh-certificates-versus-ssh-keys) discussion section.
1. Finally, make a connection to your SSH server using the `ssh-ed25519` host key algorithm by specifying `-o "HostKeyAlgorithms ssh-ed25519"` as part of the `ssh` client invocation:
    ```sh
    ssh -o "HostKeyAlgorithms ssh-ed25519" 172.16.1.111
    ```

    > :beginner: SSH configuration options can include an equals sign (`=`) between the configuration directive's name and its value. For example, `-o HostKeyAlgorithms=ssh-ed25519` is equivalent to `-o "HostKeyAlgorithms ssh-ed25519"`. In this guide, the latter (space-separated) style is used as it matches exactly the syntax used in the SSH configuration files themselves.

    Having erased any existing host keys for this servers, you will once again be prompted to continue connecting to the server or not. This time, however, notice that the server's Ed25519 public host key fingerprint is presented to you, not its ECDSA public host key fingerprint.
1. Abort the connection by typing `no` and pressing the `Return` or `Enter` key.
1. Connect to the SSH server again, but this time ask for level 2 debugging output:
    ```sh
    ssh -o "HostKeyAlgorithms ssh-ed25519" -vv 172.16.1.111 
    ```
1. Find the client's `KEXINIT proposal` again, and notice that this time the `host key algorithms` line contains one and only one option. The output will include a snippet like this:
    ```
    debug2: local client KEXINIT proposal
    debug2: KEX algorithms: curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha1,ext-info-c
    debug2: host key algorithms: ssh-ed25519
    ```
    The `ssh` client has given the server only one option for the host key algorithm. Since this is a host key algorithm that the server is willing and able to use, this is the algorithm ultimately agreed upon during the host key negotiation process. The server thus loads its `ssh_host_ed25519_key.pub` file and uses that, not its `ssh_host_ecdsa_key.pub` file, to present to the client. The client computes the fingerprint of this file, and presents it to you, the human user, asking for your approval to continue connecting.

By specifying a different host key algorithm (using the `HostKeyAlgorithms` configuration directive), we have changed the behavior of our `ssh` client. We have thus hardened this specific SSH connection by choosing a better host key algorithm than the default, and rejecting all other (and weaker) options proposed by the server. This illustrates the basic principle of SSH connection hardening, and we'll be doing a lot more of this throughout the remainder of this lab.

Before we continue to harden our SSH configurations, let's have a close look at some operational security ("OpSec") considerations of host key changes or mismatches, along with a very important implication that such an event might mean: SSH Machine-in-the-Middle (MITM) attacks.

## Host key verification failures

Checking the public host key fingerprint belonging to an SSH server against a fingerprint for an SSH server at the same address that we previously connected to is called *host key verification*. Whenever a new connection is established, the `ssh` client program verifies that the public key it received from the server is the one it expected to receive, based on its past experience. (If no host key for the address is listed in its `known_hosts` file, the `ssh` client program will prompt you to approve the connection, as we've seen numerous times, now.)

When the public key does not match the expected fingerprint, we experience a *host key verification failure*. Let's intentionally trigger such an event to see how it might happen and how it should affect our use of SSH.

**Do this:**

1. Remove any prior host key fingerprints saved in your `known_hosts` file for the SSH server:
    ```sh
    ssh-keygen -R 172.16.1.111
    ```
1. Make a connection to the SSH server as normal, and approve the connection to save the server's ECDSA fingerprint in your `known_hosts` file:
    ```sh
    ssh 172.16.1.111
    ```
    Answer `yes` at the SSH connection prompt.
1. Make a second connection to the SSH server, but this time use the `ssh-ed25519` host key algorithm to induce the SSH server to provide a different key than it did the last time you connected:
    ```sh
    ssh -o "HostKeyAlgorithms ssh-ed25519" 172.16.1.111
    ```
    > :beginner: This is going to produce a scary-looking warning message. Don't panic! We did this intentionally, and the warning is designed to sound alarms.

What we've just done is save the fingerprint for the SSH server's ECDSA host key, but then asked the server to send us its Ed25519 host key instead. Since these are different keys, their fingerprints will be different, too. Since their fingerprints are different, when `ssh` performs its host key verification procedure, the verification will fail, and `ssh` will issue a very loud warning about it:

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ED25519 key sent by the remote host is
SHA256:Z37eirjlSE7EdRi5NFCDp5aPMvpY9d6wRA5J0GnMpmk.
Please contact your system administrator.
Add correct host key in /home/vagrant/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in /home/vagrant/.ssh/known_hosts:1
  remove with:
  ssh-keygen -f "/home/vagrant/.ssh/known_hosts" -R 172.16.1.111
ED25519 host key for 172.16.1.111 has changed and you have requested strict checking.
Host key verification failed.
```

This warning message is clearly designed to make you stop what you're doing and take notice. SSH is outright telling you that "it is possible that someone is doing something nasty" and that "someone could be eavesdropping on you right now." This can happen because, again, addreses (like `172.16.1.111`) are not identities: when you connect to an SSH server at a given address, the address itself provides no guarantee that you're actually connecting to the same machine you connected to when trying to reach that address before.

One thing that could be happening is that a machine you expect to be politely delivering your messages to their ultimate destination is actually opening those messages itself. This "machine-in-the-middle" situation is how all networks function. However, when one of these machines in between you and your ultimate destination starts snooping on your messages, a *machine-in-the-middle (MitM) attack*, there isn't anything inherent in the way most networks are built that can alert you to this. Only the fact that this machine in the middle does not have access to your specific SSH server's private host key file offers any meaningful ability to detect that this interception is happening.

> :beginner: :black_flag: Historically, and in SSH's output today, this kind of active interception is termed a "man-in-the-middle attack." While the author concedes it is undisputably true at the time of this writing that most such malicious behavior is conducted by men, this term carries sexist implications and is also technically inaccurate. We therefore use the gender-neutral and more accurate term "machine-in-the-middle" instead.

More worrisome is the fact that machine-in-the-middle attacks are easy to mount. What's more difficult for an attacker to do is copy the private host key file on a well-secured server. This means that even if a MitM is intercepting your SSH connections, the attacker's SSH server will not look like yours; it will have its own fingerprint, will present that fingerprint to your `ssh` client (as it's the only fingerprint the attacker's server has), and thus cause `ssh`'s host key verification procedure to fail.

Such a failure in this situation is a good thing. It means `ssh` has successfully alerted you to the attack in progress. However, it is still up to you to resolve the situation. Usually, this means a careful audit of your surroundings, choosing an alternative route to your destination (such as via the Tor network, a personal VPN, or simply moving to a different Wi-Fi hotspot if you happen to be using a public network), or escalating the issue to one of your trusted comrades or, in SSH's own words, "`Please contact your system administrator.`" The one thing you should not do is ignore the warning and connect anyway.

By default, most SSH distributions today will not even permit you the luxury of ignoring the warning until you take some action. That is, `ssh` will simply refuse to continue with the connection. You can, of course, remove `ssh`'s prior knowledge of the SSH server's fingerprint by removing the appropriate line from the `known_hosts` file, and `ssh`'s warning even includes the exact command line you need to invoke to do this. Again, only do this if you know why you're being warned: it is possible that the administrator of your SSH server has told you ahead of time that they will be changing the server's host keys. In such a situation, a competent administrator should also have informed you of the new host key's fingerprint, so that you can verify it yourself. But in any situation wherein you don't understand the reason you are being warned, ask for help from those you trust.

In this lab, of course, we do know why we're being warned: we deliberately asked for a different key the second time than the key we asked for the first time. Different keys have different fingerprints (because they are different keys!) and so the fingerprints won't match. Given that we triggered this situation ourselves, it's safe for us to move forward with the connection.

Rather than delete the server's ECDSA host key fingerprint from our `known_hosts` file, though, let's use the opportunity to learn about the `StrictHostKeyChecking` SSH client configuration directive. The value of this directive determines `ssh`'s behavior after it has performed its host key verification procedure. Possible values you can set for this configuration directive are `yes`, `accept-new`, `no` (or its synonym, `off`), and `ask`. You're already familiar with the behavior of `ask` because that's the default we've been using all along: it tells `ssh` to ask you whether or not you want to add newly encountered host key fingerprints to your `known_hosts` list, and won't allow connections to SSH servers that fail its host key verification procedure to proceed.

Let's take a look at how `ssh`'s behavior changes if we turn `StrictHostKeyChecking` off.

> :beginner: :warning: Turning `StrictHostKeyChecking` off is something you should probably never actually do in a real-world ("production") environment. We're doing it here as an educational exercise, but turning this off can seriously undermine your security and the security of your systems. Friends don't let friends SSH insecurely.
>
> :beginner: Since you won't generally need to change the `StrictHostKeyChecking` directive away from the default, we won't discuss its other values here. That said, feel free to dive deeper into this topic by reading through the [additional host key verification options](#additional-host-key-verification-options) section in the extended discussion portion of this guide.

**Do this:**

1. Make a connection to your SSH server asking for its Ed25519 key while also telling `ssh` not to perform "strict" host key checking. We need to set two configuration directives to do this, so we'll include the `-o` option two times, once for each configuration directive:
    ```sh
    ssh -o "HostKeyAlgorithms ssh-ed25519" -o "StrictHostKeyChecking no" 172.16.1.111
    ```

We'll see similar output as before, with a few differences at the end of the warning that read as follows:

```
Password authentication is disabled to avoid man-in-the-middle attacks.
Keyboard-interactive authentication is disabled to avoid man-in-the-middle attacks.
Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

With `StrictHostKeyChecking` set to `no`, `ssh` flat-out refuses to allow you to use a password to log in to the SSH server. It just isn't safe to send your password to an SSH server that may be impersonating the one you intended to reach. This is why `ssh` reports that "`Password authentication is disabled`[…]." Likewise, a similar authentication method, `keyboard-interactive`, which allows the server to challenge the user with arbitrary questions beyond simply asking for a single password (e.g., two-factor authentication with a smartphone), is disabled for the same reason.

The last line of output is the same as our earlier failed log in attempt: "`Permission denied (publickkey,gssapi-keyex,gssapi-with-mic).`" Even though the log in failed, it was nevertheless attempted, despite failing to verify the server's host key fingerprint. If this had been a real scenario rather than a practice lab, unknowingly attempting to log in to an attacker's machine could pose a serious security risk.

Finally, the comma-separated list shown in parentheses on this last line are the remaining SSH authentication methods that are still enabled. Now that we understand how to positively identify remote SSH servers using their public host key fingerprints, that is to say we know how the server authenticates itself to the client, let's see how clients (like us) authenticate to an SSH server.

## Basic SSH authentication methods

> :beginner: :bulb: Up until this point, our exploration has focused on authenticating an SSH server so that you can be confident that your connections are being routed to the endpoint you intend to communicate with. *Server authentication* is the responsibility of the SSH-TRANS protocol. When completed successfully, we now have a bidirectional ("full-duplex"), secured connection to an authenticated server. From here on out, we will be utilizing features provided by the other three SSH protocols.
>
> The next step in the process, *client authentication* (also known as *user authentication*), is the responsibility of the SSH-AUTH protcol. This means that, technically speaking, we are about to "use SSH-AUTH over our SSH-TRANS connection." This distinction is largely academic; most SSH implementations you're likely to encounter expect that SSH-AUTH requests immediately follow the success of an SSH-TRANS connection, but this is a matter of convention. Custom SSH implementations may behave differently.
>
> It is useful to understand when a particular action you take is handled by one protocol or another, especially when troubleshooting problems or if you encounter a system that makes use of the SSH protocols differently.

As we've just seen, there are numerous ways for clients to authenticate to SSH servers. Some authentication methods are provided by the SSH software suite itself. You can also add new ones to a particular SSH server by way of various interfaces, such as the [pluggable authentication module (PAM)](https://en.wikipedia.org/wiki/Pluggable_authentication_module) system or the [Generic Security Services Application Program Interface (GSSAPI)](https://en.wikipedia.org/wiki/Generic_Security_Services_Application_Program_Interface). In this lab, we'll only be concerning ourselves with the two most common authentication methods, `password` and `publickey`, but see the [PAM and GSSAPI SSH authentication methods](#pam-and-gssapi-ssh-authentication-methods) discussion section if you're curious about using additional or creating custom authentication methods yourself. Moreover, the "[Additional SSH authentication methods](#additional-ssh-authentication-methods)" discussion provides details about other ways to authenticate to an SSH server.

The `password` authentication method is probably already familiar to you. It is basically equivalent to most login screens you've encountered when, for example, signing in to your webmail provider (like GMail) or using Facebook. With `password` authentication, you tell the `ssh` client program what user account on the SSH server you'd like to log in to. When the connection to the server is established, it asks you to supply that user account's password and the `ssh` client, in turn, presents you with a prompt asking you to enter that user account's password. The password you type is then sent from the client to the server and, if you supplied the correct password, the server proceeds to log you in. Otherwise, you're asked to try again, and eventually you get disconnected if you cannot supply the correct password within a time limit or configurable number of attempts. This is the same way that traditional website login systems work.

What's nice about password-based authentication is that it's so simple. On the other hand, it has some serious drawbacks. The most obvious of these is that the correct password is a secret that the server must protect. If the server fails to do this, the security of the account and, possibly, of the server itself is immediately compromised. Moreover, the whole secret (the password) must be transmitted from client to server, which means any failure of the SSH-TRANS protocol's connection security compromises the security of the user account and, possibly, of the server itself in much the same way. While we can harden the connection itself by [choosing safer host key algorithms](#choosing-safer-host-keys-and-host-key-algorithms) and other session parameters, we would ideally prefer not to send a secret at all. That is one of the main benefits of using public-key based user authentication over per-user passwords.

Another issue with passwords is that you can typically only have one per user account. In contrast, a single user account may authorize any number of public keys for its use. In many situations where some user accounts may be shared amongst multiple system operators (such as with the superuser or `root` account), the limitation of one password per account means each human must know and use the same password. Not only does this represent an increase in operational security risk, it also necessitates a coordination overhead whenever that password needs to be changed.

Further, if multiple humans are each using the same username and password combination, they become indistinguishable to the server (since computers cannot know who is typing at a keyboard, at least not yet), making auditing and access control that much harder, if not impossible, to implement. In contrast, a given public key can be used as an identifier to enforce restrictions on what a given SSH session is permitted to do. Put another way, you can limit which commands are available for use during the SSH session based on which public key was used to log in to the system. The flexibility and potential precision multiple public keys provide are thus clear benefits over passwords.

Despite these drawbacks, the `password` authentication method is still widely used in many situations, so let's have a look at how we might configure it. We'll also take a look at how we can limit the various risks password use implies. Then, we'll learn how to completely disable password-based authentication and replace it with the far more secure `publickey` authentication method.

### SSH `password` authentication

Although password-based authentication is common, many modern Operating System distributions do not enable it by default because of all the drawbacks discussed earlier. Nevertheless, it is the simplest way to begin using SSH and provides an illustrative example for understanding how SSH authentication mechanisms work in general.

> :construction: TK-TODO
>
> Basic outline is:
>
> 1. Create a user account on the server. Talk about choosing a password, show the `passwd` and `shadow` files, etc. Mention that password auth can be done through other systems like PAM or Kerberos but don't stress about it. That can be a discussion section.
> 1. Re-enable password authentication in the SSH server. Explain the `sshd_config` file, precedence of configuration directives, etc.
> 1. Re-HUP the server gracefully using `systemctl kill`. Explain WTF that means.
> 1. Log in from the client. Note: you can log in to the server to a different account than the one you're logged in with on the client (`ssh user@server.com` or `ssh -l user server.com`, otherwise `$USER` is assumed)
> 1. Re-configure password auth to be "more secure," insofar as that's possible:
>     * Password restrictions with `PermitEmptyPassword`
>     * User restrictions with `PermitRootLogin`, `AllowUsers` or, better, `AllowGroups` (and its blacklist inverse, `DenyUsers` and `DenyGroups`, but talk about why whitelists are more secure than blacklists)
>     * Limit login grace time with `LoginGraceTime`; this is also a resource depletion mitigation
>     * Limit retry attempts with `MaxAuthTries`

### SSH `publickey` authentication

> :beginner: :construction: TK-TODO: Super-brief primer on keypairs and public key cryptography.

> :construction: TK-TODO: Some things to talk about will be:
>
> 1. `StrictModes`
> 1. `PubkeyAcceptedKeyTypes`
> 1. Using more than one public key, i.e., `AuthenticationMethods publickey,publickey`
> 1. `RevokedKeys`

# Discussion

## What are NIST curves and why can't they be trusted?

> :construction: TK-TODO: See https://blog.cr.yp.to/20140323-ecdsa.html and https://projectbullrun.org/dual-ec/vulnerability.html for now.

## SSH certificates versus SSH keys

In addition to *plain SSH keys*, OpenSSH and most other SSH server and client software can use *SSH certificates* to authenticate both servers (SSH hosts) and users (SSH clients). Although SSH certificates are not implemented in exactly the same way as TLS certificates (used for making HTTPS connections to Web sites), both SSH certificates and TLS certificates use the same architectural principles. In essence, an SSH certificate relies on a pre-existing SSH Public Key Infrastructure (PKI) to be useful, much as a Web site's TLS certificate relies on a pre-existing TLS PKI that your Web browser makes use of.

There are many advantages to using SSH certificates instead of plain SSH keys for authenticating SSH connections, but because of the extra steps required to create and centrally manage certificates, few small SSH server deployments make use of them. As a result, SSH certificates are mostly used only by larger organizations with many dozens, hundreds, or thousands of SSH servers in their fleets. Nevertheless, the benefits that SSH certificates bring are orthogonal to the size of the organization using them.

For system administrators (server-side), using SSH certificates enables you to more easily rotate SSH keys on some periodic schedule without triggering errors such as SSH host key verification failures in clients. Certificate-based authentication is also at the heart of many other authentication systems, such as VPNs and the ubiquitous SSL/TLS (HTTPS) technology that produces a padlock icon in Web browsers, so learning about their use in SSH will help you in understanding and setting up those other systems in your networks.

As an SSH user (client-side), using SSH certificates in an infrastructure with an SSH PKI set up ahead of time removes the need to manage SSH host key fingerprints manually. This means that instead of being presented with the server's host key fingerprint the first time you connect to it, your SSH client refers to a single public key contained in a certificate issued by your organization’s own Certificate Authority (CA) and checks to see whether the host key of the server you are connecting to was signed (approved) by that authority.

To create a trusted SSH certificate, at least two plain SSH keypairs are required. One pair of keys is used to sign the second keypair, which is used as an SSH identity. The act of signing a plain SSH key creates an SSH certificate that can then be used by other SSH software. The basic command for signing a key uses an `ssh-keygen` command that looks something like the following:

```sh
ssh-keygen -s $SIGNING_KEYPAIR_PRIVATE_KEY_FILE \
    [-h] [-z $CERTIFICATE_SERIAL_NUMBER] [-V $VALIDITY_PERIOD] \
    -n $ENTITY_NAME -I $ENTITY_ID \
    $IDENTITY_KEYPAIR_PUBLIC_KEY_FILE
```

Note that the two required keypairs, shown above as `$SIGNING_KEYPAIR_PRIVATE_KEY_FILE` and `$IDENTITY_KEYPAIR_PUBLIC_KEY_FILE`, always use the private portion of the authority's "signing" key to sign the public portion of the entity's plain SSH key (identity file). SSH certificates, like TLS certificates, can also carry optional attributes such as the time period for which they are valid, a serial number, or other extensions.

To learn more, [Tech Learning Collective provides an interactive sample SSH certificate primer](https://techlearningcollective.com/sample/scaling-ssh-authentication-with-certificates) on their Web site. For even more information about how to work with SSH certificates, refer to the `CERTIFICATES` section of the `ssh-keygen(1)` manual page.

## Additional host key verification options

> :construction: TK-TODO

* Other values for `StrictHostKeyChecking`:
    * `yes`
    * `accept-new`
* `CheckHostIP`
* `VerifyHostKeyDNS`
* `VisualHostKey`

## PAM and GSSAPI SSH authentication methods

> :construction: TK-TODO

## Additional SSH authentication methods

> :construction: TK-TODO

### SSH `hostbased` authentication

> :construction: TK-TODO
>
> For the majority of use cases we care about, this authentication method is not considered useful because it fundamentally relies on trust relationships between machines rather than user account identity verification. We'll touch on this mechanism but for the purposes of this lab, won't actually dive that deep into it. 

### SSH Kerberos authentication

> :construction: TK-TODO

### SSH `keyboard-interactive` authentication

> :construction: TK-TODO

## Requiring multiple SSH authentication methods

> :construction: TK-TODO
>
> Basically, set `AuthenticationMethods` to a comma-separated one or more lists of valid methods. See `sshd_config(5)`.

## Auditing your SSH configuration using `ssh-audit.py`

> :construction: See https://github.com/jtesta/ssh-audit
>
> ![Screenshot of ssh-audit.py audit results.](https://cloud.githubusercontent.com/assets/7356025/19233757/3e09b168-8ef0-11e6-91b4-e880bacd0b8a.png)

## Using SSH to create Virtual Private Networks (VPNs)

Since SSH provides for strong confidentiality and integrity guarantees, it can be used to create ad-hoc Virtual Private Networks when used in conjunction with other Operating System features such as `tap`/`tun` devices or a kernel's packet routing/filtering tables. This section offers a brief discussion of these use cases and capabilities.

### SSH-based Virtual Private Networks with OpenSSH

Since OpenSSH 4.3, released on February 1<sup>st</sup> 2006, you can use a UNIX-like Operating System's support for `tap` (OSI Layer 2) or `tun` (OSI Layer 3) pseudo-devices in conjunction with SSH to directly implement VPNs.

For example, to create a simple point-to-point VPN connection that forwards IP (OSI Layer 3) packets through the VPN tunnel, you need to first ensure this feature is enabled on the OpenSSH server itself, then create a `tun` device on the SSH server, and give that `tun` device an IP address:

```sh
# Ensure the `PermitTunnel` SSH configuration option is set to `yes`.
sudo $EDITOR /etc/ssh/sshd_config # Make the configuration change.
sudo systemctl reload sshd        # Reload the SSH daemon.

# Create a tun device named `tun0`.
sudo ip tuntap add mode tun name tun0

# Give the server's tunnel endpoint an IP address.
sudo ip address add 10.1.1.1/30 dev tun0
```

Then, on the client, create its `tun` device, give it an IP address, and then initiate an SSH connection while passing the `-w` option to link the two devices as a VPN tunnel:

```sh
sudo ip tuntap add mode tun name tun0
sudo ip address add 10.1.1.2/30 dev tun0

# The `-w` option requests that traffic sent to `tun` device `0` (i.e., `tun0`)
# on the client be forwarded to `tun` device `0` (i.e., `tun0`) on the server.
ssh -f -w 0:0 user@server true
```

After this `ssh` command is run on the client, `ssh` will background itself and your prompt will return. You can now access the server at its tunnel IP address of `10.1.1.1`, and any traffic sent to that IP will be transparently forwarded through the SSH-based VPN tunnel. For more information, see the "SSH-BASED VIRTUAL PRIVATE NETWORKS" section in the `ssh(1)` manual page and [the `README.tun` file in the OpenSSH source code](https://github.com/openssh/openssh-portable/blob/master/README.tun).  

### Transparent proxy VPN using SSH with `sshuttle`

> :construction: TK-TODO
>
> In brief, `sshuttle(1)` is a command that uses one of several methods to automatically redirect all outbound traffic over an established SSH session. This has the effect of turning an SSH connection into a lightweight Virtual Private Network (VPN) connection whereby your SSH server acts as your VPN endpoint. This obviates the need to do SSH port forwarding (using `ssh`'s `-L`/`-R` options).
>
> Since `sshuttle` uses an existing SSH configuration, all you have to do is make sure your SSH connection itself is working, and then invoke the `sshuttle` command (with a few optional arguments of its own), and it will do the rest to figure out how to forward your traffic.
>
> Under the hood, `sshuttle` typically uses an `iptables(8)` `PREROUTING` rule in the `nat` table (or an equivalent like `nftables` or `ipfw` when those systems are available instead) in order to alter the destination of outbound IP packets.

# Additional references

* [SSH, the Secure Shell: The Definitive Guide](https://www.worldcat.org/isbn/9780596008956) - Reference book thoroughly covering many aspects of SSH administration.
