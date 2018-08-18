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
1. [Practice](#practice)
    1. [Introduction](#introduction)
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

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

> :construction: TK-TODO

# Additional references

* [SSH, the Secure Shell: The Definitive Guide](https://www.worldcat.org/isbn/9780596008956) - Reference book thoroughly covering many aspects of SSH administration.
