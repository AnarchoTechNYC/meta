# Introduction to Securing (Virtualized) Secure Shell Servers

[Secure Shell (SSH)](https://simple.wikipedia.org/wiki/Secure_Shell) is an encrypted network protocol originally developed in 1995. Since the 90’s, SSH has been a cornerstone of remote administration. It’s one of the first and still one of the most important tools any system administrator must learn to use. The most widely known use of SSH is its application as a remote login tool. The SSH protocol provides the operator of a computer system a secure channel over an unsecured network (like the Internet) to use to access the command line of a remote system, although any network-capable service can be secured using the SSH protocol.

To learn SSH, you need at least two computers talking to each other: one playing client (the administrator's workstation or laptop), and one playing server (the remote system that the admin wants to log in to from afar). These days, multi-machine setups like this are easy to create using the magic of [Virtual Machine (VM)](https://simple.wikipedia.org/wiki/Virtual_machine) hypervisors, which can create many (virtual) machines in just a few clicks. Sometimes referred to as a [“Virtual Private Cloud” (VPC)](https://en.wikipedia.org/wiki/Virtual_private_cloud), these lab environments offer completely free and astonishingly powerful educational and operational opportunities.

This workshop presents a brief crash course in configuring and hardening SSH. Along the way, we’ll also touch on some basics of spinning up a simple VPC using the free and open source [VirtualBox](https://en.wikipedia.org/wiki/VirtualBox) type-2 [hypervisor](https://en.wikipedia.org/wiki/Hypervisor) and the [Vagrant](https://en.wikipedia.org/wiki/Vagrant_%28software%29) hypervisor automation utility. We’ll have to create both the machines themselves and their virtualized network environment, so we'll cover some basic network engineering concepts as well. Finally, we’ll dig into the gritty of hardening (securing) your SSH server and client configurations so you can let your comrades in and keep [the CIA](https://www.ssh.com/ssh/cia-bothanspy-gyrfalcon) out.

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
    1. [Virtual machine startup](#virtual-machine-startup)
    1. [Virtual machine operation](#virtual-machine-operation)
    1. [Network connectivity checking](#network-connectivity-checking)
    1. [VirtualBox DHCP server configuration](#virtualbox-dhcp-server-configuration)
1. [Practice](#practice)
    1. [Introduction](#introduction)
    1. [SSH server host keys and fingerprints](#ssh-server-host-keys-and-fingerprints)
    1. [Choosing safer host keys and host key algorithms](#choosing-safer-host-keys-and-host-key-algorithms)
    1. [Host key verification failures](#host-key-verification-failures)
    1. [Basic SSH authentication methods](#basic-ssh-authentication-methods)
        1. [SSH `password` authentication](#ssh-password-authentication)
        1. [SSH `publickey` authentication](#ssh-publickey-authentication)
1. [Discussion](#discussion)
    1. [Vagrant multi-machine](#vagrant-multi-machine)
    1. [VirtualBox networking modes](#virtualbox-networking-modes)
    1. [Network interfaces in GNU/Linux](#network-interfaces-in-gnulinux)
    1. [IPv6 addressing](#ipv6-addressing)
    1. [DHCP options](#dhcp-options)
    1. [What are NIST curves and why can't they be trusted?](#what-are-nist-curves-and-why-cant-they-be-trusted)
    1. [SSH certificates versus SSH keys](#ssh-certificates-versus-ssh-keys)
    1. [Additional host key verification options](#additional-host-key-verification-options)
1. [Additional references](#additional-references)

# Objectives

When you complete this lab, you will have acquired the following capabilities:

* The ability to use Vagrant to create VirtualBox-backed virtual machines.
* The ability to perform basic configuration and troubleshooting of VirtualBox-backed virtual networks.
* The ability to audit SSH server and client configuration files to spot potential security weaknesses and prove that these hardened configurations are in effect on both server and client endpoints.
* The ability to log in to an SSH server using SSH's public key-based ("passwordless") authentication mechanism.

To successfully complete this lab, you will need to construct a virtualized network that matches the diagram shown below. We suggest that you refer to this diagram throughout this practice lab to check your understand of the material presented herein.

![Desired state of the virtualized network topology.](https://github.com/AnarchoTechNYC/meta/raw/master/train-the-trainers/practice-labs/introduction-to-securing-virtualized-secure-shell-servers/Virtualized%20Network%20Topology.svg?sanitize=true)

# Bill of materials

This folder contains the following files and folders:

* `README.md` - This file.
* `Screenshots/` - Contains images used to augment the lab's textual material; these are not directly related to the lab's practice steps.
* `Virtualized Network Topology.svg` - A Scalable Vector Graphics image file displaying the desired network topology for this lab.
* `Virtualized Network Topology.xml` - An editable [Draw.IO](https://draw.io/) diagram that can be exported as SVG to produce the `Virtualized Network Topology.svg` image file.
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
* For automatically configuring virtual machine settings: [Vagrant](https://vagrantup.com/) version 2.1 or newer.

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

```ruby
config.vm.box = "centos/7"
```

Meanwhile, the Ubuntu Xenial machine's `Vagrantfile` should have a similar line, but the `config.vm.box` variable should be assigned a different value:

```ruby
config.vm.box = "ubuntu/xenial64"
```

On the left side of the equals sign (`=`) is the full name of the variable (`config.vm.box`). The equals sign is Ruby's assignment operator, which takes the value to the right of the equals sign and saves it to the variable named on the left. After Vagrant reads this line in your `Vagrantfile`, Vagrant will know which box you want to use in your project.

Every virtual machine that Vagrant configures always has at least one network adapter. [For VirtualBox, this first network adapter and its configuration is hard-coded and cannot be changed](https://www.vagrantup.com/docs/virtualbox/boxes.html#virtual-machine). (Well, not without changing the source code for Vagrant itself, anyway). Vagrant always configures this adapter to use [VirtualBox's `NAT` networking mode](https://www.virtualbox.org/manual/ch06.html#network_nat). In this mode, the virtual machine is able to access the Internet through the physical (host) machine's own network connection, but no other machines can access it because it is placed behind a virtual [Network Address Translation (NAT)](https://simple.wikipedia.org/wiki/Network_address_translation) router of its own.

> :beginner: In addition to virtualizing "machine" hardware, VirtualBox (and most other hypervisors) can also virtualize *network* devices, including routers, switches, and even some network services, in order to create a network environment in which the virtual machine can operate. A full discussion of network engineering is beyond the scope of this lab, but see the [VirtualBox networking modes](#virtualbox-networking-modes) discussion section, below, for additional information. For now, suffice it to say that without correctly configuring a second network adapter to your VirtualBox-backed and Vagrant-configured virtual machine, no other virtual machine will be able to communicate directly with it.

In order for our two virtual machines to be able to hear one another when they speak, they need to be connected to the same network. To accomplish this, we can instruct Vagrant to instruct VirtualBox to add a second virtualized [network interface card (NIC)](https://en.wikipedia.org/wiki/Network_interface_controller) to each machine and to connect both machines's second NIC to the same virtualized network. To have Vagrant add subsequent NICs to a virtual machine, we use [the `config.vm.network` method](https://www.vagrantup.com/docs/networking/basic_usage.html) call.

> :beginner: A *method*, in programmer-speak, is a function that an object can perform. In Ruby, everything is an object, so all functions are technically methods. In our case, the `config.vm` object is, as stated, an object, and `network` is the name of one of the `vm` object's functions. This is the method Vagrant uses to configure virtualized NIC hardware on the virtual machine. What a method or function actually does depends on the *arguments* given (or "passed") to it.

Each time we call the `config.vm.network` method, Vagrant tries adding another NIC to the virtual machine it's building for us. We'll want to ensure that our second NIC is not accessible by the outside world, so we'll pass [`"private_network"`](https://www.vagrantup.com/docs/networking/private_network.html) as the first [(positional) argument](https://ruby-doc.org/core-2.0.0/doc/syntax/calling_methods_rdoc.html#label-Positional+Arguments) to the method. Further, we want to have Vagrant configure the virtual machine's operating system to automatically configure an IP address for that network interface, so we'll also pass `type: "dhcp"` as a [keyword argument](https://ruby-doc.org/core-2.0.0/doc/syntax/calling_methods_rdoc.html#label-Keyword+Arguments). Finally, we don't just want to attach the network interface card to any random network, but a specific network, so we'll give this network a name, say `sshtestnet`, by passing `virtualbox__intnet: "sshtestnet"` as another keyword argument. The full method call will look like this:

```ruby
config.vm.network "private_network", type: "dhcp", virtualbox__intnet: "sshtestnet"
```

> :beginner: While the `sshtestnet` (part of the `virtualbox__intnet` keyword argument) is arbitrary—it merely needs to be the same for both `Vagrantfile`s—the `type: "dhcp"` keyword argument is not. It refers to the [Dynamic Host Configuration Protocol](https://simple.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol). DHCP is a way that network administrators can automatically inform machines joining their network what networking parameters they should use in order to have access to network services, not least of which is access to the Internet. You may not have heard about it before, but you probably use DHCP every time you connect to a Wi-Fi network. We describe the use and purpose of DHCP in the [VirtualBox DHCP server configuration](#virtualbox-dhcp-server-configuration) section, a little further on in this lab set up guide.

Both of our `Vagrantfile`s will need this same line, and by including this same line in both projects, both virtual machines will be attached to the same virtual network.

**Do this**:

1. Open the `Vagrantfile` for your CentOS 7 Vagrant project in a text editor.
1. Add the `config.vm.network` method call as described above inside the configuration block (i.e., immediately following the `config.vm.box` line), then save the file.
1. Repeat the first two steps for your Ubuntu Xenial Vagrant project, as well.

Your Vagrant projects are now configured. :)

## Virtual machine startup

With your `Vagrantfile`s written, you're ready to start up the virtual machines they describe. A number of additional things happen the very first time you turn on the virtual machines in a Vagrant project. This may include downloading their Vagrant boxes from the Internet as well as performing Vagrant's own initial setup of the virtual machine's operating system and user accounts. This often means that the first time you boot a virtual machine with Vagrant it can take a bit more time to complete than it will on subsequent startups.

To power on a virtual machine described in a `Vagrantfile` for the first time, you must first be somewhere within the Vagrant project. Then, you invoke [the `vagrant up` command](https://www.vagrantup.com/docs/cli/up.html). This instructs Vagrant to look for a `Vagrantfile` in the current directory, or continue [searching up the filesystem hierarchy in subsequent directories](https://www.vagrantup.com/docs/vagrantfile/#lookup-path) if a `Vagrantfile` is not in the current directory. We'll do this twice; once to start up our CentOS 7 virtual machine, and a second time to start up our Ubuntu Xenial virtual machine. The order in which you boot the virtual machines doesn't particularly matter, but you will eventually need both virtual machines powered on to complete this practice lab.

**Do this**:

1. In your terminal, change to the directory of your CentOS 7 virtual machine:
    ```sh
    cd centos-7
    ```
1. Power on the virtual machine:
    ```sh
    vagrant up
    ```
1. Wait until the first virtual machine has finished booting. Vagrant will display quite a bit of output during this process. If this is your first time booting a Vagrant virtual machine, take a minute to read some (or all!) of this output.
1. When the first machine has finished booting, change to the directory of your Ubuntu Xenial virtual machine and power on that virtual machine as well:
    ```sh
    cd ../ubuntu-xenial64
    vagrant up
    ```

If successful, you should now have the two virtual machines running on the VirtualBox hypervisor. You can check that this is so by invoking [the `vagrant status` command](https://www.vagrantup.com/docs/cli/status.html) from within one of the Vagrant project directories. Alternatively, you can invoke [the `vagrant global-status` command](https://www.vagrantup.com/docs/cli/global-status.html) to see the current status of all your Vagrant projects in one list, regardless of your current working directory.

> :beginner: As you might expect, Vagrant can also shut down virtual machines, not just start them up. The command for this is [`vagrant halt`](https://www.vagrantup.com/docs/cli/halt.html). Additionally, Vagrant can also interface with numerous VirtualBox features such as [snapshots](https://www.virtualbox.org/manual/ch01.html#snapshots) (via [the `vagrant snapshot` command](https://www.vagrantup.com/docs/cli/snapshot.html)) and [saving or restoring the running state of the virtual machine](https://www.virtualbox.org/manual/ch01.html#idm485) (via [the `vagrant suspend`](https://www.vagrantup.com/docs/cli/suspend.html) and [`vagrant resume`](https://www.vagrantup.com/docs/cli/resume.html) commands, respectively). We strongly encourage you to peruse the excellent [Vagrant CLI documentation](https://www.vagrantup.com/docs/cli/) to learn more about what you can do using Vagrant's command-line interface.
>
> Importantly, when you're well and truly done with your Vagrant project or this practice lab, you'll want to use [the `vagrant destroy` command](https://www.vagrantup.com/docs/cli/destroy.html). This will delete the virtual machines defined in your `Vagrantfile` in their entirety, reclaiming your physical (host) machine's hard disk space and generally cleaning up after yourself.

Another way to check that your virtual machines are, in fact, powered on is simply to open the graphical VirtualBox Manager application. You should see that both virtual machines are now registered with VirtualBox and are shown to be in the "Running" state. Once both of the practice lab's virtual machines are up and running, you can continue to the next section.

## Virtual machine operation

> :beginner: A quick note on terminology: when discussing the relationship between a physical machine and a virtual machine, we say that the physical machine is the *host* machine and the virtualized machine is its *guest*. This is because the virtual machine (guest) is, ultimately, sharing resources with the underlying physical machine; it is at the mercy of its host. In this lab, we take care to make this distinction as clear as possible, though you will often hear the terms *host* and *guest* without much additional context.

In order to complete this lab, we must first be able to operate within the context of the virtual machine itself. Put another way, we need to leave our physical machine and enter the virtual machine. We can do this in one of two ways.

* Use VirtualBox to bring up a simulated video display and keyboard plugged directly into the VM's virtualized hardware.
* Use the SSH facility provided by Vagrant to access a command shell running in the VM's operating system.
    > :beginner: Yes, it's a little ironic that Vagrant already provides an SSH facility for us to use. This is in fact the same SSH facility that we will be hardening. Not to worry, though! All this means is that we won't need to *install* the SSH software ourselves, since all Vagrant boxes already package SSH as part of their base box. This, like the first network adapter, is a hard requirement of all Vagrant boxes since Vagrant itself uses SSH to remotely administer the virtual machine. In fact, commands like `vagrant halt` are simply shortcuts for opening an SSH connection to your virtual machine and issuing the `shutdown(1)` command (or an equivalent, if the virtual machine is not running an operating system for which `shutdown` is a recognized command).

It's useful to know about both of these methods because it's very possible that you will nullify your ability to use the second method (Vagrant's SSH facility) if you make certain errors during this practice lab. In case you do, you'll still be able to use the first method (the direct VirtualBox console) to recover. Your third option, of course, is to start over (discarding all your progress) by using [the `vagrant destroy` command](https://www.vagrantup.com/docs/cli/destroy.html).

Let's showcase the VirtualBox console first, and then try out Vagrant's (arguably more comfortable) SSH facility.

**Do this:**

1. Launch the graphical VirtualBox Manager application if it is not already opened as described in [§1.7, "Starting Virtual" of the VirtualBox Manual](https://www.virtualbox.org/manual/ch01.html#idm272).
1. Look for two virtual machines in the list on the left-hand sidebar of the main "Oracle VM VirtualBox Manager" window with names that begin with `centos-7_default` and `ubuntu-xenial64_default` and end in numbers. These are the virtual machines Vagrant created for you.
    > :beginner: The numbers in your Vagrant virtual machine names are timestamps that indicate when the virtual machine was created. You can customize the name that Vagrant gives to a VirtualBox virtual machine by adding [a special, VirtualBox-specific variable in your `Vagrantfile`](https://www.vagrantup.com/docs/virtualbox/configuration.html#virtual-machine-name). Without this special variable, Vagrant defaults to using the name of the folder containing the `Vagrantfile` with `_default_` and a timestamp appended to it as the name of the VirtualBox VM.
1. Double-click on one of the Vagrant virtual machines in the list. This will open a new window whose contents is the video output of the virtual machine's display.
1. Click once inside the window (which may be blank, or all black) to let VirtualBox *capture* your keyboard and mouse movements. VirtualBox will now route all your keyboard presses and mouse movements to the input of the virtual machine and away from your physical computer.
1. Press the `Enter` or `Return` key on your keyboard. Eventually, your virtual machine will notice the input and display a login prompt, as shown below:  
    ![Login prompt of the CentOS 7 virtual machine running in VirtualBox.](Screenshots/virtualbox-vm-centos-7-gui-login.png)
1. At either login prompt, type `vagrant` as the username, then press `Return`.
1. At the password prompt, type `vagrant` as the password, then press `Return`. Unlike the username prompt, the password you type will not be echoed back to your screen.

You should now be logged in to a command shell inside the virtual machine, as shown below:

![Screenshot showing successful login to a CentOS 7 virtual machine via VirtualBox console.](Screenshots/virtualbox-vm-centos-7-gui-login-command-prompt.png)

This method of accessing your virtual machine emulates having a physical keyboard, video monitor, and possibly also a mouse directly attached to the virtual machine. The window that VirtualBox presents to you is the output of the virtual machine's video card. Your keyboard and mouse or trackpad is routing its input directly to the virtual machine. It's as though you have physically sat down in front of the machine itself.

Using the VirtualBox Manager in this manner means no network connections are involved. In fact, your virtual machine doesn't even need to have a network adapter installed for this to function. If you are ever unable to access your virtual machine using a network connection (like SSH), you can still control it through this emulated physical connection. You might hear this method described as a *direct console*, *serial console*, or *physical console*.

> :beginner: In order to disconnect your physical keyboard and mouse from the virtual machine and return to using your host computer normally, VirtualBox watches for any press of a special key it calls the *host key*. On most computers, this is the right Control key. On macOS computers, it is the left Command key. Learn more about [capturing and releasing keyboard and mouse input in §1.9.2 of the VirtualBox Manual](https://www.virtualbox.org/manual/ch01.html#keyb_mouse_normal).

Now that you can reliably control your virtual machine regardless of network connectivity, let's try using Vagrant's SSH facility to do the same thing.

**Do this:**

1. Release your keyboard and mouse from the virtual machine by pressing the VirtualBox host key. On most host machines, this is the right Control key. On macOS hosts, it is the left Command key.
1. From the *Machine* menu, choose *Detach GUI*. This will close the window showing the virtual machine's monitor without shutting down the virtual machine itself.
1. Return to your host terminal.
1. Navigate to the `centos-7` folder.
1. Use Vagrant to make an SSH connection and remotely log in to the CentOS 7 virtual machine using [the `vagrant ssh` command](https://www.vagrantup.com/docs/cli/ssh.html). If successful, you should see output similar to the following snippet:
    ```sh
    you@your-host$ vagrant ssh
    Last login: Tue Aug 21 22:26:15 2018
    [vagrant@localhost ~]$
    ```
1. Confirm that you are now remotely logged in to the virtual machine and have assumed the `vagrant` user identity by issuing a command such as `whoami(1)` or `who(1)`. For example:
    ```sh
    [vagrant@localhost ~]$ whoami
    vagrant
    [vagrant@localhost ~]$ who
    vagrant  tty1         2018-08-21 22:26
    vagrant  pts/0        2018-08-21 22:56 (10.0.2.2)
    [vagrant@localhost ~]$
    ```

You are now at the command line of the CentOS 7 virtual machine. Using `vagrant ssh` from a Vagrant project directory, you can immediately access the command line of the virtual machine using the pre-provisioned SSH server that came as part of the Vagrant box and the first (NAT'ed) network adapter that Vagrant instructs VirtualBox to attach to the virtual machine. The next step is to ensure that your two virtual machines can communicate with one another through the second network interface card that you configured in their respective `Vagrantfile`.

## Network connectivity checking

Recall that the purpose of SSH is to securely access one computer from a second. This implies that the two computers must be able to send messages to and receive messages from one another, whether secured or not. If the two computers can't interact for any reason, then whether you have hardened your SSH session is a moot point, since you cannot make use of the SSH protocol in the first place. Therefor, before we even concern ourselves with SSH, we need to ensure that the one machine is able to contact the other, and vice versa.

Further, in order for one machine to send a message to another, it must have the name of the place at which the intended recipient can be found. This name is called an *address*. At this fundamental level, computer addresses work exactly the same way as postal addresses. If you've ever sent a postcard to a family member or friend while on vacation, you've written an address. Likewise, if you've ever sent an email to a coworker, chatted with a friend on Facebook, or placed a telephone call, you've used an address to direct the message towards your recipient. Postcards use *mailing addresses*, Facebook chats use Facebook *user names*, e-mails use *email addresses*, and telephone calls use *telephone numbers*. These are all examples of addresses.

In many modern digital networks (like the Internet), the "place" in the network at which a given machine can be found is an address called an *[Internet Protocol (IP)](https://simple.wikipedia.org/wiki/Internet_Protocol) address*. In order for our virtual machines to be able to communicate with one another, both of them need to have their own IP address. When one sends a message to the other, it will write its own IP address on the message's envelope in the *source IP* field and, unsurprisingly, it will write the IP address of its intended recipient on the message's envelope in the *destination IP* field. These message envelopes are called *packet headers*.

> :beginner: :bulb: If you think about it, of course, it's not enough merely to give two machines addresses. These addresses need to be *routable* between each other. That is, there needs to be an unbroken pathway from point A (the source) to point B (the destination), which further means each intermediary device handling their messages can forward them in the appropriate direction. Internetwork routing is beyond the scope of this lab, but have a look at [Henrik Frystyk's excellent (and superbly brief) *Introduction to the Internet*](https://www.w3.org/People/Frystyk/thesis/Internet.html), circa 1994, for more information. His article also lists references that, while old, are still profoundly relevant today.

In this lab, both virtual machines are connected to two different networks: the NAT network required by Vagrant connects the virtual machine to the Internet, and the VirtualBox internal network we named `sshtestnet` is intended to allow the virtual machines to communicate with one another. It is our connections to this second network that we will be examining more closely.

**Do this:**

1. Log in to the CentOS 7 virtual machine using `vagrant ssh` if you have not already done so.
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
1. Log in to the Ubuntu Xenial virtual machine and investigate its IP address configuration by using the `ip address` command again. You'll see similar but probably not identical output as you did on CentOS:
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
    > :beginner: Did you notice the difference in these device names? For example, it was `eth1` on CentOS 7 but is `enp0s8` on Ubuntu Xenial. The `eth` prefix is a historical abbreviation for *[ethernet](https://simple.wikipedia.org/wiki/Ethernet)*, the lower-level networking technology on which many IP networks still depend. In contrast, `enp` stands for *ethernet network peripheral*. See the [Predictable Network Interface Names page on the Freedesktop Project's wiki](https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/) for details about these naming choices.

Astute readers will no doubt have noticed that `eth0` on the CentOS machine and `enp0s3` on the Ubuntu machine both have the same IP address. This is because both devices are set to use VirtualBox's NAT [networking mode](#virtualbox-networking-modes). These devices are attached to completely separated networks and can therefore have the same IP address without conflicting with one another. This is like two people sharing the same name, but being in totally different conversations. No one will be confused about who is being referred to by the name "Alex" if there is only one Alex in the room.

If your IP address configurations look like the above, there is an obvious problem: the two virtual machines cannot yet communicate with one another. This is because VirtualBox has not given them IP addresses to use while on the `sshtestnet` internal network. To resolve this situation, we need to instruct VirtualBox to start doling out IP addresses to machines that are connected to this named internal network.

## VirtualBox DHCP server configuration

When a machine first joins a network, it doesn't necessarily have an IP address. Among other issues, this means it won't be able to receive messages from other machines, since no other machine knows how to address their messages to it. This is the dilemma that the [Dynamic Host Configuration Protocol (DHCP)](https://simple.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) was designed to solve.

A DHCP server, then, is typically a machine that has joined a network ahead of time and is ready to assign IP addresses to new machines as they join the network after it has. These late comers are called *DHCP clients*. DHCP services could be offered by an entirely separate, wholly dedicated machine attached to the network, or they could be offered by any other machine running DHCP server software. For example, in a small home network, the Wi-Fi router probably has a DHCP server running on it. By using DHCP, you can avoid the need to manually configure the IP network settings of each device that wants to use the network each time that device joins the network.

> :beginner: :bulb: DHCP is not limited to assigning IP addresses. It can be used to automatically configure all sorts of network settings, such as the address of upstream DNS servers, network boot images, and more. See the [DHCP options](#dhcp-options) discussion section for more information about the network settings that DHCP can automatically configure.

Much like your home Wi-Fi router, VirtualBox itself has the ability to offer DHCP services to any of the networks it virtualizes. We'll be using this VirtualBox feature to ensure that the virtual machines on the `sshtestnet` network have IP addresses. Using [the `VBoxManage list dhcpservers` command](https://www.virtualbox.org/manual/ch08.html#vboxmanage-list), you can see all the DHCP servers that VirtualBox has added to its virtualized networks.

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

* `NetworkName` displays the name of the VirtualBox network to which this DHCP server is attached. In the example above, `NatNetwork` refers to the `NAT` [VirtualBox networking mode](#virtualbox-networking-modes). This is the DHCP server from which your virtual machines received an IP address assignment when they started up the first time.
* `IP` is the IP address of the DHCP server itself. Like any other machine, the DHCP server needs an IP address so that it can communicate with other machines on the network. DHCP servers themselves typically get *static* IP addresses, which is to say, their IP addresses are assigned manually by network administrators. You'll be doing this yourself in just a moment.
* [`NetworkMask` is the other important part of an IP address](#network-masks-and-subnetting), and is displayed by VirtualBox in this output using the older dotted decimal notation, rather than the newer CIDR notation. A netmask of `255.255.255.0` in this older notation is equivalent to `/24` in CIDR notation.
* `lowerIPAddress` is the first IP address available for DHCP clients. This is the lower bound in the range of IP addresses you'd like to make available for new machines to use as they join.
* `upperIPAddress` is the last IP address available for DHCP clients. This is the upper bound in the range of IP addresses you'd like to make available for new machines to use as they join.
    > :beginner: Taken together, the lower and upper IP address range is called an *IP address pool*. So, for example, if your lower IP address is 1.1.1.1 and your upper IP address is 1.1.1.2, you have an IP address pool consisting of two IP addresses. This means only two machines at a time will be given an IP address. If a third machine joins the same network, it must wait until one of the first two machines are done using their addresses before it will get an IP address of its own. This may take some time, hours or even days, depending on how the DHCP server is configured and how promptly the DHCP clients notify the server that they no longer need to use the IP address assigned to them.
    >
    > :construction: TK-TODO: Discuss the concept of a DHCP lease, reservation, and lease time. Describe `release`ing a DHCP lease (re-requesting a new DHCP lease), as well, which is a common command that Windows user will be familiar with: `ipconfig /renew`. GNU/Linux users will likely want to explore [the `dhclient(8)` command](https://linux.die.net/man/8/dhclient).
* `Enabled` shows whether or not the VirtualBox DHCP server is actually turned on or not. If the DHCP server is not enabled, it will of course not respond to requests for IP assignments. :)

In order to add DHCP services to our `sshtestnet` network, we merely need to instruct VirtualBox to enable a DHCP server on that named network. We do this using [the `VBoxManage dhcpserver` command](https://www.virtualbox.org/manual/ch08.html#vboxmanage-dhcpserver). If you didn't see a DHCP server listed for the `sshtestnet` network when you ran `VBoxManage list dhcpservers`, you'll need to use the `VBoxManage dhcpserver add` command to install a new DHCP server on the network. Otherwise, if you did see a DHCP server listed for the `sshtestnet` network, you can use `VBoxManage dhcpserver modify` with the exact same arguments as you would have used for the `add` invocation to edit the DHCP server's settings.

Let's configure the DHCP server for the `sshtestnet` network now.

**Do this:**

1. At a terminal on your host machine, add a new DHCP server for the `sshtestnet` network that will offer a small number of IP addresses for the virtual machines to use:
    ```sh
    VBoxManage dhcpserver add --netname sshtestnet --ip 172.16.1.1 --netmask 255.255.255.0 --lowerip 172.16.1.10 --upperip 172.16.1.20 --enable
    ```
1. If you receive an error like `VBoxManage: error: DHCP server already exists`, run the same command but replace `add` with `modify`:
    ```sh
    VBoxManage dhcpserver modify --netname sshtestnet --ip 172.16.1.1 --netmask 255.255.255.0 --lowerip 172.16.1.10 --upperip 172.16.1.20 --enable
    ```
    > :beginner: :construction: TK-TODO: Go over this command invocation in more detail.
1. Confirm that the VirtualBox hypervisor will provide DHCP services to the `sshtestnet` network by invoking `VBoxManage list dhcpservers` again. You should see a DHCP server listed in the output whose configuration matches this output:
    ```
    NetworkName:    sshtestnet
    IP:             172.16.1.1
    NetworkMask:    255.255.255.0
    lowerIPAddress: 172.16.1.10
    upperIPAddress: 172.16.1.20
    Enabled:        Yes
    ```

With the DHCP server in place and enabled, you can now instruct your virtual machines to request IP addresses from it. The easiest way to do this is simply to reboot them. Vagrant provides [the `vagrant reload` command](https://www.vagrantup.com/docs/cli/reload.html) as a shortcut for `vagrant halt` and a subsequent `vagrant up` to turn off a virtual machine and then immediately turn it back on.

**Do this:**

1. Reboot both your CentOS 7 and your Ubuntu Xenial virtual machines using Vagrant.
1. Log in to one of your virtual machines using `vagrant ssh` again.
1. Look up the IP address configuration of the virtual machine. If the VirtualBox DHCP server is configured and responding correctly, the network adapter attached to the `sshtestnet` network should now have an IP address associated with it. You can use the `ip address show dev eth1` command to show the IP address(es) assigned to the logical network interface device named `eth1`. (You'll want to replace `eth1` with the name of the device in your virtual machine; this is likely `enp0s8` in the Ubuntu Xenial guest.) Doing this on the CentOS 7 virtual machine should now show you output similar to the following:
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

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

Secure Shell (SSH) servers are more common than you might think. Although we've been focusing on creating a practice lab environment to experiment in, you should know that almost every computer has the capacity to function as an SSH server. The laptop you use every day can do it and, especially if you've been given a machine from your employer, it's possible that an SSH server is already running on it so that the IT department can administer it remotely. Many home routers have both a Web interface and a command line interface, and SSH is often what provides this command-line access.

> :beginner: There are many implementations of the SSH software suite in use today. In this lab, we use [OpenSSH](https://www.openssh.com/) because it is distributed with Apple's macOS, as well as most BSD and GNU/Linux operating systems by default. OpenSSH is also fully [Free Software](https://www.gnu.org/philosophy/free-sw.html). It was developed by building on the original, freely-distributed implementation of SSH as its base. A notable OpenSSH alternative is Tectia, the commercial implementation of the SSH suite productized by [SSH Communications Security (SCS), Inc.](https://ssh.com/). Another notable alternative is [Dropbear SSH](https://matt.ucc.asn.au/dropbear/dropbear.html), which is designed to run more efficiently on devices with low power. For the most part, all of these implementations are interopable with one another; you can use any suite's `ssh` client to log in to a machine running any other suite's `sshd` server.
>
> :beginner: SSH is not the only remote command-line login tool. [Telnet](https://simple.wikipedia.org/wiki/Telnet) is a longstanding alternative, which many computers such as home routers still offer today. However, Telnet is fundamentally insecure because it has no built-in encryption capabilities. This omission is both why SSH was created in the first place and why SSH is so often used to replace Telnet. The other notable ancestor to SSH was the suite of programs known as the [Berkeley r-commands](https://en.wikipedia.org/wiki/Berkeley_r-commands), such as `rsh` ("remote shell") and `rlogin` ("remote login"). Like Telnet, these programs and their protocol lack encryption, so have all been obsoleted by SSH.

Of course, if you can access a machine's command line over SSH, so too can anyone else. This is why securing SSH access is so critically important. An SSH server is something like the "front door" to your computer. An unsecured SSH server on a network is by far the first thing most intruders look for. These days, if you put an SSH server up on the Internet, you'll see login attempts within minutes.

Of course, whether or not someone can actually log in to your computer via its SSH server depends on a number of factors. Most obviously, they must possess the appropriate *access credentials*. For example, they need to know the username and password combination for a user account that has SSH access, or they must have a copy of that user's private SSH key, which is literally a key to the front door. In this lab, we'll explore both of these *authentication methods*, and we'll see why password-based authentication is much less secure than SSH key-based authentication. We'll also reconfigure the SSH server so that only the more secure options are available for use, a process often known as *hardening*.

Moreover, the name "Secure Shell" has, over time, become something of a misnomer. Although originally invented as a mechanism to provide secure command line access to a shell over an unsecured network (hence the name, "secure shell"), SSH is actually a suite of several applications, none of which is a shell and only one of which is actually called `ssh`. The name also refers to a [specific transport protocol, called `SSH-TRANS`, that was eventually standardized as RFC 4253](https://tools.ietf.org/html/rfc4253). Thanks to this generic communications protocol, SSH can be used to secure any kind of communication between two endpoints, a process often referred to as *SSH tunneling*. For example, you can route your Web browser through an "SSH tunnel," thus making it appear to the Web site you're browsing as though your computer is the SSH server itself, and not your laptop.

> :beginner: [SSH tunneling](https://en.wikipedia.org/wiki/Tunneling_protocol#Secure_Shell_tunneling) is so termed because the protection SSH provides is on-the-fly encryption by the sender and on-the-fly decryption by the receiver. While a message is travelling from the sender to the receiver, it is impenetrable to any eavesdroppers who happen to be somewhere along the same path the message takes to get to its destination. Metaphorically, the message has entered "an encrypted tunnel." In network engineering parlance, when you route one application's network traffic inside a tunnel provided by a second, we say that you have "encapsulated" the first application's traffic inside the second's; to use the Web browsing example from earlier, we might say you have "encapsulated HTTP within SSH." This same form of impenetrable tunnel is also how vanilla SSH connections work, although in that case we typically say that the connection is simply "using SSH" rather than "being tunnelled."

Finally, despite its name, the "Secure" Shell still has some security weaknesses. For example, putting aside legal implications, it makes little difference if you lock your front door with a lock that's easy to pick. Intruders will still be able to get in through that very same front door. This is also true with SSH: using a weak SSH key won't keep any committed intruders out. Similarly, it doesn't matter how good your front door's lock is if the patio window is wide open. Burglars will just enter through the open window. This, too, matters when securing a machine that has an SSH server on it: why bother trying to break in through the SSH server if there's an easier way in?

Security is always going to be a process in which you are trying to raise the bar to unauthorized entry. There is never just one thing to do that will magically "secure" your stuff. The more precautions you take, the less likely you'll be chosen as a target of opportunistic attackers, and the longer it will take a dedicated adversary to intrude. The task of securing something ("hardening" it) is to slow attackers down as much as possible for as long as possible.

Let's get started by taking a look around.

## SSH server host keys and fingerprints

SSH has two main parts: a client, invoked by the `ssh(1)` command, and a server, invoked by the `sshd(8)` command. In day-to-day use, you'll start with using an SSH client and will be making connections to (i.e., requests of) a listening SSH server. Once the server hears (receives) a request from a client, it will respond in some way, either allowing or denying the request. Every SSH connection involves these two parts. We call these parts *endpoints* because they are each one end of the connection. This request-and-response model, in which one program makes requests of another, is called a [*client-server architecture*](https://wiki.wikipedia.org/wiki/Client%E2%80%93server_model).

> :beginner: There isn't anything particularly magical about "servers." For the purposes of this lab, we will always be treating the CentOS 7 virtual machine as the SSH server. The Ubuntu Xenial virtual machine will therefore be our SSH client. However, it doesn't particularly matter which operating system or even which machine is the client and which the server. When talking about servers and clients (any servers and clients, not just SSH) all that matters is that the server application is running. Wherever the server application is running is called "the server." This same logic holds for the client: wherever the `ssh` client program is run is said to be "the client." A single machine can thus be both a server and a client at the same time simply by running both the server application and a corresponding client application on it. Even in this case, however, we still speak about "the server" and "the client" as distinct entities.

Let's have a look around our SSH server first.

**Do this:**

1. Access a command line of your CentOS 7 virtual machine. You can do this through the VirtualBox Manager graphical application or by navigating to the `centos-7` folder in this practice lab and invoking `vagrant ssh`.
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

We will explore each of these files in detail soon but, for now, it's enough to have a look and see that the files are there. When looking at this list, you'll see there are two configuration files (`sshd_config`) and (`ssh_config`), and most of the other ones are key pairs (e.g., `ssh_host_ecdsa_key` and `ssh_host_ecdsa_key.pub`).

> :beginner: [Configuration files](https://github.com/AnarchoTechNYC/meta/wiki/Configuration-file) are a common way that programs describe application preferences or allow a user to customize a program's options. There's no need to be intimidated when you encounter configuration files. They are a simply a textual analog to the "Preferences" or "Settings" or "Options" windows is graphical applications.

The `sshd_config` file in the `/etc/ssh` folder on the server is the SSH server's primary configuration file. That is to say it is the file read by the `sshd` (SSH daemon) program whenever it is launched. The `sshd` program is the program that starts and runs the SSH server process; it is *the* SSH server part of your "SSH server machine." Tweaking the values of the various configuration directives in this file will change the behavior of your SSH server. We will be spending a great deal of this lab modifying the values in this file and ensuring that our changes have been applied.

> :beginner: As you may know, when available on a given system, the `man` command can be used to look up details about command invocations. This same `man` command can also be used to look up information about configuration files. Section 5 of the manual is the typical place to store file format information, and so invoking `man sshd_config` or `man 5 sshd_config` will often show you a manual page that describes the format of the `sshd_config` file along with many, if not all, of its configuration directives. Unfortunately, [CentOS 7's Vagrant box does not include manual pages for SSH](https://bugs.centos.org/view.php?id=14633), but most other systems do. Try `man sshd_config` on the Ubuntu Xenial virtual machine, for example.
>
> :beginner: You may have noticed the `ssh_config` file. Not to be confused with the `sshd_config` file, this is the system-wide configuration file for the `ssh` client program. We will have a closer look at this file when we explore our SSH client's environment. So, for now, simply take care not to confuse the SSH daemon's configuration file (`sshd_config`) with the SSH client program's configuration file (`ssh_config`). Both files exist on the same machine since a single machine might be running both an SSH client and an SSH server at the same time.

The set of files that begin with `ssh_host_` are called, rather predictably, *host keys*. There are a number of them: `ssh_host_ecdsa_key`, `ssh_host_ed25519_key`, `ssh_host_rsa_key`, and so forth. Each of these files contains the server's own, private cryptographic identity, which uniquely identifies this SSH server distinct from any other SSH server. Therefore, these files are called *private host keys*. When the server receives a request from a client asking the server to identify itself using the [Elliptic Curve Digital Signature Algorithm (ECDSA)](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm), the server will respond with data partly derived from reading the `ssh_host_ecdsa_key` file. If the client makes a similar request but asks the server to use the [Rivest–Shamir–Adleman (RSA) algorithm](https://en.wikipedia.org/wiki/RSA_%28cryptosystem%29), the server will respond with data partly derived from its `ssh_host_rsa_key` file, and so on.

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

    > :beginner: :bulb: If you are trying to connect to an SSH server for the first time for which you don't already have some way of reading the public host key, you need to find some other way of checking the server's fingerprint before you continue connecting. Typically, this is done by simply asking the server's administrator for the SSH server's public key fingerprint over some other secure channel, such as an authenticated (signed) email, a Signal private message with a verified contact, or an equivalent. You could also simply trust that this first connection is not being intercepted, a paradigm cleverly termed TOFU (Trust On First Use), but this is obviously suboptimal for the appropriately paranoid among us.
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

1. From your host machine, access a command line of your Ubuntu Xenial virtual machine. You can do this through the VirtualBox Manager graphical application or by navigating to the `ubuntu-xenial` folder in this practice lab and invoking `vagrant ssh`.
1. Find the IP address of the CentOS 7 server. You can do this in a number of ways, such as:
    * invoking `ip address` at the command line of the CentOS 7 virtual machine, as discussed in [Network connectivity checking](#network-connectivity-checking), or, perhaps more fun,
    * emitting a network probe from the Ubuntu Xenial virtual machine using the `ping(1)` command to each of the IP addresses within [the DHCP address pool you configured earlier](#virtualbox-dhcp-server-configuration) and seeing which one responds:
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
        > vagrant@ubuntu-xenial:~$ ping 172.16.1.20
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
        > vagrant@ubuntu-xenial:~$ ping 172.16.1.11
        > PING 172.16.1.11 (172.16.1.11) 56(84) bytes of data.
        > 64 bytes from 172.16.1.11: icmp_seq=1 ttl=64 time=0.409 ms
        > ^C
        > --- 172.16.1.11 ping statistics ---
        > 1 packets transmitted, 1 received, 0% packet loss, time 0ms
        > rtt min/avg/max/mdev = 0.409/0.409/0.409/0.000 ms
        > ```
        >
        > Note that the specific IP addresses that respond to you may be different that those shown above because your DHCP server may have assigned your virtual machines different IP addresses than the author's. However, you should get a response from exactly two machines in the DHCP address pool: one is the Ubuntu Xenial virtual machine, and the other is the CentOS 7 virtual machine. Make sure you know which is which. Remember, you can always look up your current machine's IP address with the `ip address` command.
        >
        > :beginner: If only one machine within the DHCP address range responds, make sure that both your virtual machines are turned on and that you have correctly [configured the VirtualBox DHCP server](#virtualbox-dhcp-server-configuration), discussed earlier. In this lab, if you can't `ping` one machine from the other, then you also can't use `ssh` to connect to one from the other.
        >
        > :beginner: For the remainder of this guide, we assume that the CentOS 7 virtual machine has IP address `172.16.1.11` and that the Ubuntu Xenial virtual machine has the IP address `172.16.1.10`. If your machines are located at different addresses, adjust the commands in this guide accordingly.
1. Once you have the IP address of the CentOS 7 virtual machine, use `ssh` to start a connection to it:
    ```sh
    vagrant@ubuntu-xenial:~$ ssh 172.16.1.11 # Remember, your CentOS VM's IP address might be different.
    The authenticity of host '172.16.1.11 (172.16.1.11)' can't be established.
    ECDSA key fingerprint is SHA256:bC7KnOz29hPzOtCHTI5faWHfOh7Hw2LmS13UWuZQsO0.
    Are you sure you want to continue connecting (yes/no)?
    ```
    Before you do anything else, take a moment to read the output here carefully. You are once again confronted with the message, "`The authenticity of host '172.16.1.11 (172.16.1.11)' can't be established.`" Following that, you see the fingerprint of one of the server's host keys (the ECDSA one, in this case). This fingerprint uniquely identifies the machine to which you are connecting. Notice that even though the IP address of the host is different this time than last time (where it was `localhost (::1)`), the fingerprint is the same. Again, IP addresses are addresses, not server identities. Always use the server's key fingerprint to ensure you are connecting to the endpoint you intend.
1. Type `no` and then press the `Return` or `Enter` keys to abort your connection.

Don't worry, we'll connect again in just a moment. Before we do, though, we need to become familiar with a few important files that your SSH client uses regularly. These are all located in your user account's home folder, inside a hidden folder called `.ssh`. Let's have a look inside it.

> :beginner: A "hidden folder" is not exactly hidden per se, it's just not shown by default. You can tell it's a hidden folder because its name begins with a single dot (`.`). These so-called "dotfiles" are omitted from directory listings such as when you invoke the `ls(1)` command, unless you explicitly ask for them to be shown by using the `-a` ("show all files") option. Hidden folders or files typically store information that isn't usually relevant to someone's day-to-day use of their computer, or that the application they relate to doesn't want a novice user to be editing manually, but they aren't special in any other way. Don't mistake a "hidden" folder for a folder that has actual security controls placed on it; they are not the same.

**Do this:**

1. List the contents of your Ubuntu Xenial machine's `vagrant` home directory:
    ```sh
    cd    # Be sure you are starting from your home folder.
    ls    # This will return no output, even though the folder is *not* empty.
    ls -a # This will reveal the existence of "hidden" files and folders.
    ```
1. List the contents of `vagrant`'s `.ssh` directory. You will see only one file, for now:
    ```sh
    vagrant@ubuntu-xenial:~$ ls .ssh/
    authorized_keys
    ```
    Take note of the `authorized_keys` file, and that no other files are present.
    > :beginner: The `authorized_keys` file is discussed in [the "Basic SSH authentication methods" section](#basic-ssh-authentication-methods), so ignore it for now. This file exists because it was created by the creator of the Vagrant box. It's what allows you to use the `vagrant ssh` command successfully. In a brand-new machine that you build from scratch, you may need to make this file yourself. That's not difficult but, again, is discussed later.
1. Make another connection to the CentOS 7 SSH server. After double-checking that the fingerprint is correct, type `yes` when prompted to continue the connection. The complete output might look something like this:
    ```sh
    vagrant@ubuntu-xenial:~$ ssh 172.16.1.11
    The authenticity of host '172.16.1.11 (172.16.1.11)' can't be established.
    ECDSA key fingerprint is SHA256:bC7KnOz29hPzOtCHTI5faWHfOh7Hw2LmS13UWuZQsO0.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added '172.16.1.11' (ECDSA) to the list of known hosts.
    Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
    ```
    This was *not* a successful login (as shown by the line starting with "`Permission denied`"), but that's to be expected at this time. The important thing to note is the `Warning` informing you that the `ECDSA` key fingerprint for the server at `172.16.1.11` was added to the list of known hosts.
1. List the contents of your `.ssh` directory again. This time, you will see a second file, called `known_hosts`:
    ```sh
    vagrant@ubuntu-xenial:~$ ls .ssh/
    authorized_keys  known_hosts
    ```
1. Make another connection to the CentOS SSH server again. This time, notice that we are not presented with the key fingerprint as we have been before:
    ```sh
    vagrant@ubuntu-xenial:~$ ssh 172.16.1.11
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
    ssh-keygen -l -f ~/.ssh/known_hosts -F 172.16.1.11
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
    > # Remove host 172.16.1.11.
    > ssh-keygen -R 172.16.1.11 -f ~/.ssh/known_hosts
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

The process of figuring out which host key the client will accept, which the server can provide, and then agreeing to actually use a given option from the resulting set available is called *host key negotiation*. We can watch this process take place in real time by starting an SSH connection to a server with the `-v` option specified twice, like `ssh -vv` or `ssh -v -v`. Invoking `ssh` this way turns on "level 2 debugging output," which means your SSH client will tell you some of what it's doing as it's doing it.

**Do this:**

1. Start an SSH connection to your CentOS server with the client's verbosity turned up to level 2:
    ```sh
    ssh -vv 172.16.1.11
    ```
    > :beginner: There's going to be a *lot* of output from this command. This is all intended to help you troubleshoot problems, although here we're using it to show you some of how SSH works "under the hood." If you ever do run into a problem, though, you can use this technique to get a lot more information about what might be going wrong with the connection you're trying to make.
    >
    > You can also tweak exactly how much output you'll get by specifying the `-v` option a different number of times. The less times you pass `-v`, the less information will be printed when you run `ssh`. We're using `-vv` because the specific thing we're looking for is only printed at level `debug2` and greater, so passing `-v` just one time would not have shown it to us.
    >
    > When started this way, most lines of output will be labelled with the debugging level that the message on the remainder of the line is associated with. In other words, lines that begin with `debug1: ` will be printed when you run `ssh -v`, whereas lines that begin with `debug2: ` will only be printed when you run `ssh -vv` (or `ssh -vvv` and so on).
    >
    > If you're comfortable on a command line, you can use this fact to quickly filter the output to show you just what you're interested in. For example, [`ssh -vv 172.16.1.11 2>&1 | grep debug2`](https://explainshell.com/explain?cmd=ssh+-vv+172.16.1.11+2%3E%261+%7C+grep+debug2) will only show you the level 2 debugging output.

Rather than dissect this output line by line, let's focus on just a few of the more important messages. The very first line will look like something like this:

```
OpenSSH_7.2p2 Ubuntu-4ubuntu2.4, OpenSSL 1.0.2g  1 Mar 2016
```

This is the same output you'll see if you invoke `ssh` asking for its version information with the `-V` option:

```sh
vagrant@ubuntu-xenial:~$ ssh -V
OpenSSH_7.2p2 Ubuntu-4ubuntu2.4, OpenSSL 1.0.2g  1 Mar 2016
```

> :beginner: The version of a program is important to know because the same program might have been updated with new features that are only available in certain versions of it. In this case, we see that the version of our SSH suite is `OpenSSH_7.2p2` ("OpenSSH version 7.2 patch level 2"). This output also shows us the operating system on which we are running SSH ("Ubuntu"), along with the versions of one of the most important components of the SSH suite itself, OpenSSL ("`OpenSSL 1.0.2g`"). OpenSSL is the program that provides many other programs with their cryptographic capabilities, and could be the topic of a whole other guide. It also has a command line interface, which you can learn some more about from its manual page (`man openssl`). Finally, we see the date on which this specific SSH suite was built: March 1, 2016.

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

Just a few lines later, we can see that `ssh` reports it is connecting to the server at the address we gave it, and that the connection succeeds ("`Connection established.`"). Right after that, `ssh` tries loading its own identity files, its *client [host] keys*, but finds that none exist ("`No such file or directory`"). This isn't an error, exactly, since none exist because we haven't created any yet. Finally, we see the beginning of an authentication attempt as `ssh` reports it is `Authenticating to 172.16.1.11:22 as 'vagrant'`. Here's that chunk of the output in full:

```
debug1: Connecting to 172.16.1.11 [172.16.1.11] port 22.
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
debug1: Authenticating to 172.16.1.11:22 as 'vagrant'
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
> vagrant@ubuntu-xenial:~$ ssh -Q key
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
> vagrant@ubuntu-xenial:~$ ssh -Q kex
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

Instructing `ssh` to use a different host key algorithm when connecting to an SSH server is easy. Choosing a better algorithm, however, can be trickier if you aren't a cryptographer yourself. The best most of us can do is think critically about the situation we find ourselves in, review the academic literature in as much detail as we are able, or find a more knowledgable person whom we find trustworthy. For the purpose of this guide, the author assumes you find them trustworthy enough to make decent recommendations. That being said, you are once again encouraged to peruse the "[What are NIST curves and why can't they be trusted?](#what-are-nist-curves-and-why-cant-they-be-trusted)" discussion section for additional details.

Operationally speaking, choosing safer cryptographic algorithms can be broken down into two major considerations:

* How widely vetted, and publicly disclosed, is the cryptographic scheme? The more skilled cryptographers have audited a given algorithm, and the more they have published about it and its details, the better.
* How widely implemented in the tools you need to use is the cryptographic scheme? Obviously, if the tool you're trying to use does not support the use of a given cryptographic algorithm, well, you can't use it.

The author's favorite cryptosystem is [the Ed25519 public-key signature system](https://ed25519.cr.yp.to/). It is very similar to NIST's ECDSA scheme, except for the fact that it did not originate with the NSA, uses different mathematical constants ("curves") than the P-256 curve recommended by NIST, and is even faster. Fortunately, many modern SSH suites available today support this algorithm for numerous parts of the SSH connection and encryption process. This can be verified using the `-Q` option to query your `ssh` installation.

> :beginner: :bulb: Ed25519 is so named because it is a variant on the [Edwards-curve Digital Signature Algorithm (EdDSA)](https://en.wikipedia.org/wiki/EdDSA), which uses [Curve25519](https://en.wikipedia.org/wiki/Curve25519). What matters for our purposes is that you can recognize these names in SSH's output. You don't need to be a cryptographer to use these cryptographic systems, much like you don't need to be a computer scientist in order to use a computer. That said, it certainly helps to gain a little bit of familiarity with the terminology of the technology you're using, just as it would help to know English in order to read road signs written in that language.

Let's try using the Ed25519 algorithm for exchanging host keys with our SSH server. To do this, we'll configure our SSH client to propose only this one host key algorithm to the server. SSH configuration directives can be passed directly to the `ssh` client using the `-o` option in the invocation of `ssh` itself, making custom configurations very easy to experiment with. The configuration directive we need to use to change the list of preferred host key algorithms is called `HostKeyAlgorithms`.

> :beginner: Remember that the available configuration directives you can use to change the behavior of the `ssh` client program are listed in the `ssh_config(5)` manual page. This is typically available to you using the `man ssh_config` command. Once again, don't confuse this with the `sshd_config` file or its corresponding manual page, `sshd_config(5)`! Even though many of the same configuration directives are available to both the `sshd` (server) and `ssh` (client) programs, you'll save yourself quite a bit of trouble by reading the correct manual page. :)

**Do this:**

1. First, remove the SSH client's knowledge of any previous connections by deleting the SSH server's host key from your `known_hosts` file:
    ```sh
    ssh-keygen -R 172.16.1.11
    ```
1. Next, list the host key algorithms available to you: 
    ```sh
    ssh -Q key
    ```
    Several of the available options should now be at least cursorily familiar. We see the `ecdsa-sha2-nistp256` algorithm that we'd like to avoid from now on, along with the `ssh-ed25519` and `ssh-ed25519-cert-v01@openssh.com` algorithms that use the Ed25519 cryptosystem, which we like.
    > :beginner: The differences between the `ssh-ed25519` and `ssh-ed25519-cert-v01@openssh.com` values relate to the use of SSH certificates instead of plain SSH keys. In this introductory lab, we won't be using SSH certificates at all, but you can learn more about the distinction in the [SSH certificates versus SSH keys](#ssh-certificates-versus-ssh-keys) discussion.
1. Finally, make a connection to your SSH server using the `ssh-ed25519` host key algorithm by specifying `-o "HostKeyAlgorithms ssh-ed25519"` as part of the `ssh` client invocation:
    ```sh
    ssh -o "HostKeyAlgorithms ssh-ed25519" 172.16.1.11
    ```

    > :beginner: SSH configuration options can include an equals sign (`=`) between the configuration directive's name and its value. For example, `-o HostKeyAlgorithms=ssh-ed25519` is equivalent to `-o "HostKeyAlgorithms ssh-ed25519"`. In this guide, the latter (space-separated) style is used as it matches exactly the syntax used in the SSH configuration files themselves.

    Having erased any existing host keys for this servers, you will once again be prompted to continue connecting to the server or not. This time, however, notice that the server's Ed25519 public host key fingerprint is presented to you, not its ECDSA public host key fingerprint.
1. Abort the connection by typing `no` and pressing the `Return` or `Enter` key.
1. Connect to the SSH server again, but this time ask for level 2 debugging output:
    ```sh
    ssh -o "HostKeyAlgorithms ssh-ed25519" -vv 172.16.1.11 
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

But what happens when the public key doesn't match the expected fingerprint? This situation is called a *host key verification failure*. Let's intentionally trigger such an event to see how it might happen and how it should affect our use of SSH.

**Do this:**

1. Remove any prior host key fingerprints saved in your `known_hosts` file for the SSH server:
    ```sh
    ssh-keygen -R 172.16.1.11
    ```
1. Make a connection to the SSH server as normal, and approve the connection to save the server's ECDSA fingerprint in your `known_hosts` file:
    ```sh
    ssh 172.16.1.11
    ```
    Answer `yes` at the SSH connection prompt.
1. Make a second connection to the SSH server, but this time use the `ssh-ed25519` host key algorithm to induce the SSH server to provide a different key than it did the last time you connected:
    ```sh
    ssh -o "HostKeyAlgorithms ssh-ed25519" 172.16.1.11
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
  ssh-keygen -f "/home/vagrant/.ssh/known_hosts" -R 172.16.1.11
ED25519 host key for 172.16.1.11 has changed and you have requested strict checking.
Host key verification failed.
```

This warning message is clearly designed to make you stop what you're doing and take notice. SSH is outright telling you that "it is possible that someone is doing something nasty" and that "someone could be eavesdropping on you right now." This can happen because, again, addreses (like `172.16.1.11`) are not identities: when you connect to an SSH server at a given address, the address itself provides no guarantee that you're actually connecting to the same machine you connected to when trying to reach that address before.

One thing that could be happening is that a machine you expect to be politely delivering your messages to their ultimate destination is actually opening those messages itself. This "machine-in-the-middle" situation is how all networks function. However, when one of these machines in between you and your ultimate destination starts snooping on your messages, a *machine-in-the-middle (MitM) attack*, there isn't anything inherent in the way most networks are built that can alert you to this. Only the fact that this machine in the middle does not have access to your specific SSH server's private host key file offers any meaningful ability to detect that this interception is happening.

> :beginner: :black_flag: Historically, and in SSH's output today, this kind of active interception is termed a "man-in-the-middle attack." While the author concedes it is undisputably true at the time of this writing that most such malicious behavior is conducted by men, this term carries sexist implications and is also technically inaccurate. We therefore use the gender-neutral and more accurate term "machine-in-the-middle" instead.

More worrisome is the fact that machine-in-the-middle attacks are easy to mount. What's more difficult for an attacker to do is copy the private host key file on a well-secured server. This means that even if a MitM is intercepting your SSH connections, the attacker's SSH server will not look like yours; it will have its own fingerprint, will present that fingerprint to your `ssh` client (as it's the only fingerprint the attacker's server has), and thus cause `ssh`'s host key verification procedure to fail.

Such a failure in this situation is a good thing. It means `ssh` has successfully alerted you to the attack in progress. However, it is still up to you to resolve the situation. Usually, this means a careful audit of your surroundings, choosing an alternative route to your destination (such as via the Tor network, a personal VPN, or simply moving to a different Wi-Fi hotspot if you happen to be using a public network), or escalating the issue to one of your trusted comrades or, in SSH's own words, "`Please contact your system administrator.`" The one thing you should not do is ignore the warning and connect anyway.

By default, most SSH distributions today will not even permit you the luxury of ignoring the warning until you take some action. That is, `ssh` will simply refuse to continue with the connection. You can, of course, remove `ssh`'s prior knowledge of the SSH server's fingerprint by removing the appropriate line from the `known_hosts` file, and `ssh`'s warning even includes the exact command line you need to invoke to do this. Again, only do this if you know why you're being warned: it is possible that the administrator of your SSH server has told you ahead of time that they will be changing the server's host keys. In such a situation, a competent administrator should also have informed you of the new host key's fingerprint, so that you can verify it yourself. But in any situation wherein you don't understand the reason you are being warned, ask for help from those you trust.

In this lab, of course, we do know why we're being warned: we deliberately asked for a different key the second time than the key we asked for the first time. Different keys have different fingerprints (because they are different keys!) and so the fingerprints won't match. Given that we triggered this situation ourselves, it's safe for us to move forward with the connection.

Rather than delete the server's ECDSA host key fingerprint from our `known_hosts` file, though, let's use the opportunity to learn about the `StrictHostKeyChecking` SSH client configuration directive. The value of this directive determines `ssh`'s behavior after it is has performed its host key verification procedure. Possible values you can set for this configuration directive are `yes`, `accept-new`, `no` (or its synonym, `off`), and `ask`. You're already familiar with the behavior of `ask` because that's the default we've been using all along: it tells `ssh` to ask you whether or not you want to add newly encountered host key fingerprints to your `known_hosts` list, and won't allow connections to SSH servers that fail its host key verification procedure to proceed.

Let's take a look at how `ssh`'s behavior changes if we turn `StrictHostKeyChecking` off.

> :beginner: :warning: Turning `StrictHostKeyChecking` off is something you should probably never actually do in a real-world ("production") environment. We're doing it here as an educational exercise, but turning this off can seriously undermine your security and the security of your systems. Friends don't let friends SSH insecurely.
>
> :beginner: Since you won't generally need to change the `StrictHostKeyChecking` directive away from the default, we won't discuss its other values here. That said, feel free to dive deeper into this topic by reading through the [additional host key verification options](#additional-host-key-verification-options) section in the extended discussion portion of this guide.

**Do this:**

1. Make a connection to your SSH server asking for its Ed25519 key while also telling `ssh` not to perform "strict" host key checking. We need to set two configuration directives to do this, so we'll include the `-o` option two times, once for each configuration directive:
    ```sh
    ssh -o "HostKeyAlgorithms ssh-ed25519" -o "StrictHostKeyChecking no" 172.16.1.11
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

As we've just seen, there are numerous ways for clients to authenticate to SSH servers. Some authentication methods are provided by the SSH software suite itself. You can also add new ones to a particular SSH server by way of various interfaces, such as the [pluggable authentication module (PAM)](https://en.wikipedia.org/wiki/Pluggable_authentication_module) system or the [Generic Security Services Application Program Interface (GSSAPI)](https://en.wikipedia.org/wiki/Generic_Security_Services_Application_Program_Interface). In this lab, we'll only be concerning ourselves with the two most common authentication methods, `password` and `publickey`, but see the [PAM and GSSAPI SSH authentication methods](#pam-and-gssapi-ssh-authentication-methods) discussion section if you're curious about using additional or creating custom authentication methods yourself. Moreover, the "[Additional SSH authentication methods](#additional-ssh-authentication-methods)" discussion provides details about other ways to authenticate to an SSH server.

The `password` authentication method is probably already familiar to you. It is basically equivalent to most login screens you've encountered when, for example, signing in to your webmail provider (like GMail) or using Facebook. With `password` authentication, you tell the `ssh` client program what user account on the SSH server you'd like to log in to. When the connection to the server is established, it asks you to supply that user account's password and the `ssh` client, in turn, presents you with a prompt asking you to enter that password. The password you type is then sent from the client to the server and, if you supplied the correct password, the server proceeds to log you in. Otherwise, you're asked to try again, and eventually you get disconnected if you cannot supply the correct passwords within a time limit or configurable number of attempts. This is the same way that traditional website login systems work.

What's nice about password-based authentication is that it's so simple. On the other hand, it has some serious drawbacks. The most obvious of these is that the correct password is a secret that the server must protect. If the server fails to do this, the security of the account and, possibly, of the server itself is immediately compromised.

Another issue with passwords is that you can typically only have one per user account. In many situations where some user accounts may be shared amongst multiple system operators (such as with the superuser or `root` account), this means each human must know and use the same password. Not only does this represent an increase in operational security risk, it also necessitates a coordination overhead whenever that password needs to be changed. Moreover, if multiple humans are each using the same username and password combination, they become indistinguishable to the server (since computers cannot know who is typing at a keyboard, at least not yet), making auditing and access control that much harder, if not impossible, to implement.

Despite these drawbacks, the `password` authentication method is still widely used in many situations, so let's have a look at how we might configure it. We'll also take a look at how we can limit the various risks password use implies. Then, we'll learn how to completely disable password-based authentication and replace it with the far more secure `publickey` authentication method.

### SSH `password` authentication

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

## Vagrant multi-machine

> :construction: Discuss the utility of [Vagrant's multi-machine features](https://www.vagrantup.com/docs/multi-machine/). This is a great "exercise left to the reader," since it is a relatively advanced Vagrant-specific construct and slightly tangential to SSH hardening.

## VirtualBox networking modes

Much like any other good hypervisor, in addition to virtualizing "machine" hardware such as a computer's processor, peripheral devices like a keyboard, video monitor, and graphical pointing device ("mouse"), and disk drives, VirtualBox can also virtualize *network* devices, including routers, switches, and even some network services (i.e., [DHCP](https://simple.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) servers). VM hypervisors need this capability if they are to create a network environment in which the virtual machine can operate. Without this ability, your virtual machine would never be able to make a network connection, and wouldn't be able to do things like browse the Web or run servers for other machines to use.

Virtual networks, just like physical networks, can be constructed in a number of different ways, or configurations. These configurations are referred to as *network topologies*, because they define the way in which the various network devices and the machines on that network are interconnected. For example, one device, let's call it Device A, may be connected to only one other device, let's call it Device B. In turn, Device B might also be connected to only one other device, perhaps called Device C. A network diagram of this topology might look like this:

```
┌----------┐      ┌----------┐      ┌----------┐
| Device A | <--> | Device B | <--> | Device C |
└----------┘      └----------┘      └----------┘
```

Network topologies therefore describe the shape of a given network and the *path* a given message (called a "packet" in network engineering lingo) must take to get from one device to another. This topology, in which all devices are connected in a straight line, is called a [*bus network*](https://simple.wikipedia.org/wiki/Bus_network), and it is one of the simplest possible networks you can create. You could think of network engineering a bit like a "connect the dots" game, where the devices are the dots (sometimes also called "nodes" or "hosts") and the physical (or, in our case, virtual) network cabling are the lines connecting them.

VirtualBox provides several facilities for designing a network topology in whatever shape you like. Of these, VirtualBox's *networking modes* is the feature you'll use to connect a virtual machine to the network. Each of a virtual machine's network adapters can be configured in one (and only one) of these networking modes at a time. You can use either the [VirtualBox Manager graphical application](https://www.virtualbox.org/manual/ch01.html#idm272) or [the `VBoxManage(1)` command line utility](https://www.virtualbox.org/manual/ch08.html), installed along with the main VirtualBox hypervisor itself, to set any of a given virtual machine's available network adapters to the desired VirtualBox networking mode, as shown in the screenshot below:

![Screenshot of VirtualBox Manager 5.2.x on macOS showing that a virtual machine's first network adapter is configured in VirtualBox's `NAT` networking mode.](Screenshots/virtualbox-networking-modes-nic1-nat.png)

For the purposes of this lab, the important networking modes you should be aware of are:

* `Not attached` - This networking mode means exactly what it says on the tin: the (virtual) network cable is unplugged!
* `NAT` - This is the networking mode required by Vagrant. The first network adapter of a VirtualBox-backed virtual machine must be set to this mode for Vagrant to be able to work with the virtual machine. This networking mode virtualizes both a network cable and also a [Network Address Translation (NAT)](https://simple.wikipedia.org/wiki/Network_address_translation) router to which the virtual machine is connected.
    > :beginner: A NAT router is a network device that isolates machines connected to one specific side of it (the "outside") from machines on the other (the "inside"). For example, a machine connected to the "outside" of the NAT router can receive messages from and send messages to the NAT router itself, but cannot send any unsolicited messages to the machines on the "inside" of the router. Put another way, the machines on the "inside" are hidden from the machines on the "outside." However, machines connected to the "inside" of the NAT router (like the virtual machine whose network adapter is configured in this VirtualBox networking mode) *can* send messages to machines on the "outside" *and* the machines on the outside can send *responses* back to the machines on the inside.
    >
    > In this way, a NAT router functions a little bit like a doorperson at the front door of an apartment complex, bouncing any unsolicited visitors away and preventing them from entering but allowing residents to exit and invite any desired visitors inside. This mechanism of hiding the inside machines from those on the outside is called *network masquerading*. It's also why two virtual machines configured to use VirtualBox's NAT networking mode cannot speak to each other, but can each access the Internet. That is, they are isolated apart from one another (because they live in different metaphorical apartment complexes) but not from the outside world so long as they, themselves, are the ones who initiated the connection to the outside world.
    >
    > In networking lingo, the "inside" of a NAT router is called the *local* or *private* side, and the "outside" of a NAT router is called the *wide* or *public* side. This is one of the situations where the terms *[local area network (LAN)](https://simple.wikipedia.org/wiki/Local_area_network)* and *[wide area network (WAN)](https://en.wikipedia.org/wiki/Wide_area_network)* are frequently used.
* `Internal Network` - This networking mode creates an entirely new network that is wholly separate from both the outside world and any other virtual network. VirtualBox's internal networks can be *named* so that more than one virtual machine can be connected to the same internal network. This is handy for creating networks that are completely disconnected from any other network (including disconnected from the Internet!) but that can nevertheless house more than one virtual machine at a time.

More complete information about VirtualBox's various networking modes, including additional networking modes not mentioned in this section, are detailed in [§6.2, "Introduction to networking modes," of the VirtualBox Manual](https://www.virtualbox.org/manual/ch06.html#networkingmodes).

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

## What are NIST curves and why can't they be trusted?

> :construction: TK-TODO: See https://blog.cr.yp.to/20140323-ecdsa.html and https://projectbullrun.org/dual-ec/vulnerability.html for now.

## SSH certificates versus SSH keys

> :construction: TK-TODO: See the `CERTIFICATES` section of the `ssh-keygen` manual page.

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
>
> Talk about `hostbased`, Kerberos, `keyboard-interactive`, etc.

## Using `ssh-audit.py`

> :construction: See https://github.com/arthepsy/ssh-audit
>
> ![Screenshot of ssh-audit.py audit results.](https://cloud.githubusercontent.com/assets/7356025/19233757/3e09b168-8ef0-11e6-91b4-e880bacd0b8a.png)

# Additional references

* [SSH, the Secure Shell: The Definitive Guide](https://www.worldcat.org/isbn/9780596008956) - Reference book thoroughly covering many aspects of SSH administration.
