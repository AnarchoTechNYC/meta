# Introduction to Securing (Virtualized) Secure Shell Servers

[Secure Shell (SSH)](https://simple.wikipedia.org/wiki/Secure_Shell) is an encrypted network protocol originally developed in 1995. Since the 90’s, SSH has been a cornerstone of remote administration. It’s one of the first and still one of the most important tools any system administrator must learn to use. The most widely known use of SSH is its application as a remote login tool. The SSH protocol provides the operator of a computer system a secure channel over an unsecured network (like the Internet) to use to access the command line of a remote system, although any network-capable service can be secured using the SSH protocol.

To learn SSH, you need at least two computers talking to each other: one playing client (the administrator's workstation or laptop), and one playing server (the remote system that the admin wants to log in to from afar). These days, multi-machine setups like this are easy to create using the magic of [Virtual Machine (VM)](https://simple.wikipedia.org/wiki/Virtual_machine) hypervisors, which can create many (virtual) machines in just a few clicks. Sometimes referred to as a [“Virtual Private Cloud” (VPC)](https://en.wikipedia.org/wiki/Virtual_private_cloud), these lab environments offer completely free and astonishingly powerful educational and operational opportunities.

This workshop presents a brief crash course in configuring and hardening SSH. Along the way, we’ll also touch on some basics of spinning up a simple VPC using the free and open source [VirtualBox](https://en.wikipedia.org/wiki/VirtualBox) type-2 [hypervisor](https://en.wikipedia.org/wiki/Hypervisor) and the [Vagrant](https://en.wikipedia.org/wiki/Vagrant_%28software%29) hypervisor automation utility. We’ll have to create both the machines themselves and their virtualized network environment, so we'll cover some basic network engineering concepts as well. Finally, we’ll dig into the gritty of hardening (securing) your SSH server and client configurations so you can let your comrades in and keep [the CIA](https://www.ssh.com/ssh/cia-bothanspy-gyrfalcon) out.

![Desired state of the virtualized network topology.](https://github.com/AnarchoTechNYC/meta/raw/master/train-the-trainers/practice-labs/introduction-to-securing-virtualized-secure-shell-servers/Virtualized%20Network%20Topology.svg?sanitize=true)

# Contents

1. [Objectives](#objectives)
1. [Bill of materials](#bill-of-materials)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
    1. [VirtualBox installation](#virutalbox-installation)
        1. [VirtualBox installation on Windows](#virtualbox-installation-on-windows)
        1. [VirtualBox installation on macOS](#virtualbox-installation-on-macos)
        1. [VirtualBox installation on GNU/Linux](#virtualbox-installation-on-gnulinux)
        1. [VirtualBox installation on FreeBSD](#virtualbox-installation-on-freebsd)
        1. [VirtualBox installation on Solaris](#virtualbox-installation-on-solaris)
    1. [Vagrant installation](#vagrant-installation)
        1. [Vagrant installation on Windows](#vagrant-installation-on-windows)
        1. [Vagrant installation on macOS](#vagrant-installation-on-macos)
        1. [Vagrant installation on GNU/Linux](#vagrant-installation-on-gnulinux)
        1. [Vagrant installation on FreeBSD](#vagrant-installation-on-freebsd)
        1. [Vagrant installation on Solaris](#vagrant-installation-on-solaris)
    1. [Vagrantfile creation](#vagrantfile-creation)
1. [Practice](#practice)
    1. [Introduction](#introduction)
1. [Discussion](#discussion)
    1. [Vagrant multi-machine](#vagrant-multi-machine)
    1. [VirtualBox networking modes](#virtualbox-networking-modes)
1. [Additional references](#additional-references)

# Objectives

When you complete this lab, you will have acquired the following capabilities:

* The ability to use Vagrant to create VirtualBox-backed virtual machines.
* The ability to perform basic configuration and troubleshooting of VirtualBox-backed virtual networks.
* The ability to audit an SSH server and client configuration file to spot potential security weaknesses.
* The ability to log in to an SSH server using SSH's built-in public key-based ("passwordless") authentication mechanism.

# Bill of materials

This folder contains the following files and folders:

* `README.md` - This file.
* `Virtualized Network Topology.svg` - A Scalable Vector Graphics image file displaying the desired network topology for this lab.
* `Virtualized Network Topology.xml` - An editable [Draw.IO](https://draw.io/) diagram that can be exported as SVG to produce the `Virtualized Network Topology.svg` image file.
* `Screenshots/` - Contains images used to augment the lab's textual material; these are not related to the lab's practice steps directly.
* `centos-7/` - Used for the CentOS 7 Vagrant VM.
    * `Vagrantfile` - The Vagrant configuration for the CentOS 7 virtual machine.
* `ubuntu-xenial64/` - Used for the Ubuntu Xenial 64  Vagrant VM.
    * `Vagrantfile` - The Vagrant configuration for the Ubuntu Xenial64 virtual machine.

# Prerequisites

To perform this lab, you must have:

* A computer running any modern version of:
    * Windows,
    * macOS,
    * FreeBSD,
    * Solaris, or
    * any flavor of the GNU/Linux operating system.
* An active Internet connection (for downloading the required tools in the [set up](#set-up) step, as well as Vagrant base boxes, and the required software packages into the virtual machines; you do not need an Internet connection once you have completed the set up portion of this lab).

> :beginner: :computer: This exercise requires the use of a command line, or "terminal." If you don't know what that means, or if you do but you feel intimidated by that, consider spending an hour at [Codecademy's interactive tutorial, "Learn the Command Line"](https://www.codecademy.com/learn/learn-the-command-line) (for macOS or GNU/Linux users) or reviewing [Computer Hope's article, "How to use the Windows command line (DOS)"](http://www.computerhope.com/issues/chusedos.htm) (for Windows users) if you want to get started quickly. You don't need to complete the whole tutorial or article to understand this exercise, but it will dramatically improve your comprehension of this exercise's mechanics. If you want a more thorough but equally gentle introduction to the same material, consider reading (and listening to) [Taming the Terminal](https://www.bartbusschots.ie/s/blog/taming-the-terminal/).

# Set up

In addition to your laptop or desktop computer, you will need to acquire the following tools.

* For managing the virtual machines: [VirtualBox](https://www.virtualbox.org/) version 5.0 or newer, sometimes written as *VBox*.
* For automatically configuring virtual machine settings: [Vagrant](https://vagrantup.com/), version 2.1 or newer.
    * [Ruby](https://www.ruby-lang.org/), which is requried by Vagrant.

There are pre-built versions of the VirtualBox hypervisor software for Windows, macOS, GNU/Linux, and Solaris available for download from the [VirtualBox downloads page](https://www.virtualbox.org/wiki/Downloads). Your operating system's package repositories may also include a copy of VirtualBox, but be certain to double-check the version available there before installing it to ensure you are using a new-enough version of the software. For [FreeBSD users, VirtualBox is provided as a package or a source port and can be installed by following the instructions in the FreeBSD Handbook, §21.6](https://www.freebsd.org/doc/handbook/virtualization-host-virtualbox.html).

Similarly, there are pre-built versions of Vagrant for Windows, macOS, and numerous different GNU/Linux flavors available from the [Vagrant downloads page](https://www.vagrantup.com/downloads.html). [Vagrant is also provided as a FreeBSD port](https://svnweb.freebsd.org/ports/head/sysutils/vagrant/). Solaris users can [install Vagrant by installing from source](https://www.vagrantup.com/docs/installation/source.html).

## VirtualBox installation

In most cases, VirtualBox can be easily installed by [downloading the appropriate pre-built package](https://www.virtualbox.org/wiki/Downloads) for your operating system and hardware architecture and following the standard installation procedure as you would any other software. This section provides additional guidance for installing VirtualBox, and offers advice to troubleshoot installation problems.

### VirtualBox installation on Windows

> :construction: TK-TODO

### VirtualBox installation on macOS

> :construction: TK-TODO

### VirtualBox installation on GNU/Linux

> :construction: TK-TODO

### VirtualBox installation on FreeBSD

> :construction: TK-TODO

### VirtualBox installation on Solaris

> :construction: TK-TODO

## Vagrant installation

In most cases, Vagrant can be easily installed by [downloading the appropriate pre-built package](https://vagrantup.com/downloads.html) for your operating system and hardware architecture and following the standard installation procedure as you would any other software. This section provides additional guidance for installing Vagrant, and offers advice to troubleshoot installation problems.

### Vagrant installation on Windows

> :construction: TK-TODO

### Vagrant installation on macOS

> :construction: TK-TODO

### Vagrant installation on GNU/Linux

> :construction: TK-TODO

### Vagrant installation on FreeBSD

> :construction: TK-TODO

### Vagrant installation on Solaris

> :construction: TK-TODO

## Vagrantfile creation

Once VirtualBox is installed and running, you can manually create a new virtual machine by using the VirtualBox Manager graphical user interface (GUI) application, described in [the VirtualBox Manual §1.7](https://www.virtualbox.org/manual/ch01.html#idm272). Setting up a new virtual machine through the graphical interface typically requires many clicks, and can take a considerable amount of time. Vagrant is used to automate this process so that a virtual machine with a given configuration is accessible to you in mere moments.

To accomplish this, Vagrant reads files that describe various aspects of a virtual machine. These aspects range from what hardware to virtualize (e.g., how many network adapters the virtual machine should have, or how much memory should be installed into it), to what commands should be run when the virtual machine boots up for the first time (e.g., which software packages to install to prepare it for a given use). All of this information is contained within [a file literally named `Vagrantfile`](https://www.vagrantup.com/docs/vagrantfile/).

> :beginner: The `Vagrantfile`s for both the server and client virtual machines have already been created for you. If you are not interested in learning some Vagrant basics right now, you can download these files, place them inside two sibling folders manually, and then continue to the [Practice](#practice) section of this lab. The two files you'll need are [`centos-7/Vagrantfile`](centos-7/Vagrantfile) and [`ubuntu-xenial64/Vagrantfile`](ubuntu-xenial64/Vagrantfile). Read this section to learn how we created these files and what their contents describe.

A single `Vagrantfile` is intended to describe a complete Vagrant *project*. When Vagrant finds a `Vagrantfile`, the folder in which the `Vagrantfile` is found is considered the Vagrant *project root*. For the purposes of this lab, we will be using separate Vagrant projects for each virtual machine. This means we will be creating two `Vagrantfile`s, one for the SSH server and the other for our SSH client.

> :bulb: A single `Vagrantfile` can actually describe the configuration of multiple virtual machines. See the [Vagrant multi-machine](#vagrant-multi-machine) discussion for more information on this Vagrant feature. If you are already comfortable with Vagrant, consider re-writing our multiple `Vagrantfile`s as a single multi-machine `Vagrantfile`, instead.

Since a Vagrant project must contain a `Vagrantfile`, we will need to make a folder to house that file. Inside that new folder, we must write a `Vagrantfile` that describes the configuration of the first of our two machines. Then we'll repeat the process to describe our desire for the second of our two machines. This lab is written to use GNU/Linux [CentOS](https://centos.org/) 7 for the server and GNU/Linux [Ubuntu](https://ubuntu.com/) 16 (codenamed "Xenial") as the client. In theory, you could use any operating systems you want, and we encourage you to try out other operating systems after you complete this lab.

Vagrant's main command line utility (`vagrant`) offers a number of convenience functions to help us write these `Vagrantfile`s. We'll use [the `vagrant init` command](https://www.vagrantup.com/docs/cli/init.html) for this purpose. Let's create our Vagrant virtual machine configurations now.

**Do this:**

1. Create a new folder named `centos-7`.
1. In the `centos-7` folder, create a new file named `Vagrantfile` that contains a Vagrant configuration for a CentOS 7 virtual machine:
    ```sh
    vagrant init --minimal --output centos-7/Vagrantfile centos/7
    ```
1. Alongside the first folder, create a second folder named `ubuntu-xenial64`.
1. In the `ubuntu-xenial64` folder, create a new file named `Vagrantfile` that contains a Vagrant configuration for an Ubuntu Xenial virtual machine:
    ```sh
    vagrant init --minimal --output ubuntu-xenial64/Vagrantfile ubuntu/xenial64
    ```

The final argument to both commands (`centos/7` in the first case and `ubuntu/xenial64` in the second) map to Web addresses of pre-packaged virtual machine settings and hard disk images containing pre-installed copies of the named operating system at the specified version. These pre-packaged virtual machine environments are called [*Vagrant boxes*](https://www.vagrantup.com/docs/boxes.html). A public catalog of Vagrant boxes is available at [VagrantCloud.com](https://vagrantcloud.com/), and both [the `centos/7` Vagrant box](https://app.vagrantup.com/centos/boxes/7) as well as [the `ubuntu/xenial64` Vagrant box](https://app.vagrantup.com/ubuntu/boxes/xenial64) are listed there.

In these commands, the `--minimal` flag is optional. It merely instructs the `vagrant init` command not to include instructional comments in the written `Vagrantfile`. These comments are useful for new projects but unnecesary for this lab.

The `--output` flag is how you can tell `vagrant init` to write the `Vagrantfile` at a particular filesystem location, rather than the default. The default is simply to place the written `Vagrantfile` in the current folder. Since we wanted to write the `Vagrantfile` into the folder we just created, we specified `--output` explicitly.

At this point it would behoove you to inspect the Vagrantfiles, so open each in a text editor. Find the line that begins with `config.vm.box`. This is a variable assignment. When Vagrant loads a `Vagrantfile`, it constructs a `config` object. The `config` object has a `vm` member variable, which is also an object. [In this `vm` object, Vagrant keeps the specific settings for the virtual machine](https://www.vagrantup.com/docs/vagrantfile/machine_settings.html). In this case, the `box` variable stores the name of the Vagrant box on which this Vagrant project is based.

> :beginner: This multi-level ("nested") object construction is typical of code written in the [Ruby](https://ruby-lang.org/) programming language. In fact, a `Vagrantfile` is just a Ruby script with numerous pre-defined variables that you are expected to set as you desire. Since a Vagrantfile is just a Ruby script, the more Ruby you learn, the more your Vagrantfiles can do. If Ruby is new (and interesting) to you, we encourage you to spend some time at [Codecademy's Learn Ruby tutorial](https://www.codecademy.com/learn/learn-ruby). If you have less time, you can also [visit TryRuby to get an interactive, whirlwind tour in your Web browser](https://ruby.github.io/TryRuby/). We also like [Ruby Monsters's Ruby for Beginners guide](https://ruby-for-beginners.rubymonstas.org/).

For instance, the CentOS 7 machine's `Vagrantfile` should have a line that looks like this:

```
config.vm.box = "centos/7"
```

Meanwhile, the Ubuntu Xenial machine's `Vagrantfile` should have a similar line, but the `config.vm.box` variable should be assigned a different value:

```
config.vm.box = "ubuntu/xenial64"
```

On the left side of the equals sign (`=`) is the full name of the variable (`config.vm.box`). The equals sign is Ruby's assignment operator, which takes the value to the right of the equals sign and saves it to the variable named on the left. After Vagrant reads this line in your `Vagrantfile`, Vagrant will know which box you want to use in your project.

Every virtual machine that Vagrant configures always has at least one network adapter. [For VirtualBox, this first network adapter and its configuration is hard-coded and cannot be changed](https://www.vagrantup.com/docs/virtualbox/boxes.html#virtual-machine). (Well, not without changing the source code for Vagrant itself, anyway). Vagrant always configures this adapter to use [VirtualBox's `NAT` networking mode](https://www.virtualbox.org/manual/ch06.html#network_nat). In this mode, the virtual machine is able to access the Internet through the physical (host) machine's own network connection, but no other machines can access it because it is placed behind a virtual [Network Address Translation (NAT)](https://simple.wikipedia.org/wiki/Network_address_translation) router of its own.

> :beginner: In addition to virtualizing "machine" hardware, VirtualBox (and most other hypervisors) can also virtualize *network* devices, including routers, switches, and even some network services (i.e., [DHCP](https://simple.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) servers), in order to create a network environment in which the virtual machine can operate. A full discussion of network engineering is beyond the scope of this lab, but see the [VirtualBox networking modes](#virtualbox-networking-modes) discussion section, below, for additional information. For now, suffice it to say that without correctly configuring a second network adapter to your VirtualBox-backed and Vagrant-configured virtual machine, no other virtual machine will be able to communicate directly with it.

In order for our two virtual machines to be able to hear one another when they speak, they need to be connected to the same network. To accomplish this, we can instruct Vagrant to instruct VirtualBox to add a second virtualized [network interface card (NIC)](https://en.wikipedia.org/wiki/Network_interface_controller) to each machine and to connect both machines's second NIC to the same virtualized network. To have Vagrant add subsequent NICs to a virtual machine, we use [the `config.vm.network` method](https://www.vagrantup.com/docs/networking/basic_usage.html) call.

> :beginner: A *method*, in programmer-speak, is a function that an object can perform. In Ruby, everything is an object, so all functions are technically methods. In our case, the `config.vm` object is, as stated, an object, and `network` is the name of one of the `vm` object's functions. This is the method Vagrant uses to configure virtualized NIC hardware on the virtual machine. What a method or function actually does depends on the *arguments* given (or "passed") to it.

Each time we call the `config.vm.network` method, Vagrant tries adding another NIC to the virtual machine it's building for us. We'll want to ensure that our second NIC is not accessible by the outside world, so we'll pass [`private_network`](https://www.vagrantup.com/docs/networking/private_network.html) as the first [(positional) argument](https://ruby-doc.org/core-2.0.0/doc/syntax/calling_methods_rdoc.html#label-Positional+Arguments) to the method. Further, we want to have Vagrant configure the virtual machine's operating system to automatically configure an IP address for that network interface, so we'll also pass `type: "dhcp"` as a [keyword argument](https://ruby-doc.org/core-2.0.0/doc/syntax/calling_methods_rdoc.html#label-Keyword+Arguments). Finally, we don't just want to attach the network interface card to any random network, but a specific network, so we'll give this network a name, say `sshtestnet`, by passing `virtualbox__intnet: "sshtestnet"` as a another keyword argument. The full method call will look like this:

```
config.vm.network "private_network", type: "dhcp", virtualbox__intnet: "sshtestnet"
```

Both of our `Vagrantfile`s will need this same line, and by including this same line in both projects, both virtual machines will be attached to the same virtual network.

**Do this**:

1. Open the `Vagrantfile` for your CentOS 7 Vagrant project in a text editor.
1. Add the `config.vm.network` method call as described above inside the configuration block (i.e., immediately following the `config.vm.box` line), then save the file.
1. Repeat the first two steps for your Ubuntu Xenial Vagrant project, as well.

Your Vagrant projects are now configured. :) You're ready to begin the practice lab.

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

> :construction: TK-TODO

# Discussion

## Vagrant multi-machine

> :construction: Discuss the utility of [Vagrant's multi-machine features](https://www.vagrantup.com/docs/multi-machine/). This is a great "exercise left to the reader," since it is a relatively advanced Vagrant-specific construct and slightly tangential to SSH hardening.

## VirtualBox networking modes

In addition to virtualizing "machine" hardware such as a computer's processor, peripheral devices like a keyboard, video monitor, and graphical pointing device ("mouse"), VirtualBox can also virtualize *network* devices, including routers, switches, and even some network services (i.e., [DHCP](https://simple.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) servers), much like any other good hypervisor. Hypervisors need this capability if they are to create a network environment in which the virtual machine can operate. Without this ability, your virtual machine would never be able to make a network connection, and wouldn't be able to do things like browse the Web, download files, or run servers for other machines to use.

Virtual networks, just like physical networks, can be constructed in a number of different ways. These configurations are referred to as *network topologies*, because they define the way in which the various network devices and the machines on that network are interconnected. For example, one device, let's call it Device A, may be connected to only one other device, let's call it Device B. In turn, Device B might also be connected to only one other device, unsurprisingly called Device C. A network diagram of this topology might look like this:

```
┌----------┐      ┌----------┐      ┌----------┐
| Device A | <--> | Device B | <--> | Device C |
└----------┘      └----------┘      └----------┘
```

Network topologies therefore describe the shape of a given network and the *path* a given message (called a "packet" in network engineering lingo) must take to get from one device to another. This topology, in which all devices are connected in a straight line, is called a [*bus network*](https://simple.wikipedia.org/wiki/Bus_network), and it is one of the simplest possible networks you can create. You could think of network engineering a bit like a "connect the dots" game, where the devices are the dots (sometimes also called "nodes" or "hosts") and the physical (or, in our case, virtual) network cabling are the lines connecting them.

VirtualBox provides several facilities for designing a network topology in whatever shape you like. Of these, VirtualBox's *networking modes* is the feature you'll use to connect a virtual machine to the network. Each virtual machine's network adapter can be configured in one (and only one) of these networking modes at a time. You can use either the [VirtualBox Manager graphical application](https://www.virtualbox.org/manual/ch01.html#idm272) or [the `VBoxManage(1)` command line utility](https://www.virtualbox.org/manual/ch08.html), installed along with the main VirtualBox hypervisor itself, to set any of a given virtual machine's available network adapters to the desired VirtualBox networking mode, as shown in the screenshot below:

![Screenshot of VirtualBox Manager 5.2.x on macOS showing that a virtual machine's first network adapter is configured in VirtualBox's `NAT` networking mode.](Screenshots/virtualbox-networking-modes-nic1-nat.png)

For the purposes of this lab, the important networking modes you should be aware of are:

* `Not attached` - This networking mode means exactly what it says on the tin: the (virtual) network cable is unplugged!
* `NAT` - This is the networking mode required by Vagrant. The first network adapter of a VirtualBox-backed virtual machine must be set to this mode for Vagrant to be able to work with the virtual machine. This networking mode virtualizes not just the network cable, but also a NAT router to which the virtual machine is connected.
    > :beginner: A NAT router is a network device that isolates machines connected to one specific side of it (the "outside") from machines on the other (the "inside"). For example, a machine connected to the "outside" of the NAT router can receive messages from and send messages to the NAT router itself, but cannot send any unsolicited messages to the machines on the "inside" of the router. Put another way, the machiens on the "inside" are hidden from the machines on the "outside." However, machines connected to the "inside" of the NAT router (like the virtual machine whose network adapter is configured in this VirtualBox networking mode) *can* send messages to machines on the "outside" *and* the machines on the outside can send *responses* back to the machines on the inside. In this way, a NAT router functions a little bit like a doorperson at the front door of an apartment complex, bouncing any unsolicited guests away and preventing them from entering but allowing guests to exit and invite any desired visitors inside. This mechanism of hiding the inside machines from those on the outside is called *network masquerading*. It's also why two virtual machines configured to use VirtualBox's NAT networking mode cannot speak to each other, but can each access the Internet. That is, they are isolated apart from one another (because they live in different metaphorical apartment complexes) but not from the outside world so long as they, themselves, are the ones who initiated the connection to the outside world. In networking lingo, the "inside" of a NAT router is called the *local* side, and the "outside" of a NAT router is called the *wide* side. This is one of the situations where the terms *[local area network (LAN)](https://simple.wikipedia.org/wiki/Local_area_network)* and *[wide area network (WAN)](https://en.wikipedia.org/wiki/Wide_area_network)* are frequently used.
* `Internal Network` - This networking mode creates an entirely new network that is wholly separate from both the outside world and any other virtual network. VirtualBox's internal networks can be *named*, so that more than one virtual machine can be connected to the same internal network. This is handy for creating networks that are completely disconnected from any other network (including disconnected from the Internet!) but that can nevertheless house more than one virtual machine at a time.

More complete information about VirtualBox's various networking modes, including additional networking modes not mentioned in this section, are detailed in [§6.2, "Introduction to networking modes," of the VirtualBox Manual](https://www.virtualbox.org/manual/ch06.html#networkingmodes).

# Additional references

* [SSH, the Secure Shell: The Definitive Guide](https://www.worldcat.org/isbn/9780596008956) - Reference book thoroughly covering many aspects of SSH administration.
