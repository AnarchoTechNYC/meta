# Container Construction and Management

> :construction: TK-TODO

# Contents

1. [Objectives](#objectives)
1. [Bill of materials](#bill-of-materials)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
1. [Practice](#practice)
    1. [Introduction](#introduction)
1. [Additional references](#additional-references)

# Objectives

When you complete this lab, you will have acquired the following capabilities:

> :construction: TK-TODO

# Bill of materials

This folder contains the following files and folders:

* `README.md` - This file.
* `Vagrantfile` - The Vagrant configuration for our virtual private cloud.
* `scripts/` - Folder containing some helper scripts for demo/educational purposes.

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

Then, bring the virtual machines for the lab online.

**Do this:**

1. Boot the virtual machines needed for the lab:
    ```sh
    vagrant up
    ```

Once the virtual machines are running, you can continue to the next step.

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

> :construction: TK-TODO

Some preliminary concepts listed in order of age and thus, portability:

1. Changed root directory, i.e., `chroot(8)` - notably, basically any \*nix system will support this.
1. [Linux kernel namespaces](https://en.wikipedia.org/wiki/Linux_namespaces#Namespace_kinds). This is Linux-specific, of course.
1. Linux kernel control groups (`cgroup`s), i.e., `cgroups(7)`. Technically optional, but used everywhere for many good reasons. This, too, is specific to Linux.

`chroot`'ing a process means giving that process a view of the filesystem hierarchy such that a chosen directory is its own root directory. Outside of that process, the filesystem still has its original, real root directory. To make a super basic `chroot` environment on either macOS or Linux, a helper script called [`makechroot.sh`](scripts/makechroot.sh) is provided.

These three concepts work together to create a so-called "container," but can be used independently as well. For instance, simply creating a `chroot` environment does not inherently isolate a process from the rest of the system. In this example, we run a chroot'ed Bash shell, but then are still able to mount `/proc`:

1. Log in to the Linux virtual machine, if you haven't already:
    ```sh
    vagrant ssh
    ```
1. Run the `makechroot.sh` helper script to create a new `chroot` environment:
    ```sh
    /vagrant/scripts/makechroot.sh
    ```
1. Enter the `chroot` environment as instructed by the helper script. The command will be something like:
    ```sh
    sudo chroot chroot-example* /bin/bash
    ```
1. Explore the `chroot` environment; note the "new root directory". The "isolation," however, is *only* related to the filesystem.
1. Try getting a process listing by using the `ps` command. The command will fail with an error like `Error, do this: mount -t proc proc /proc` because the Linux `ps` command expects to have access to the `[procfs](https://en.wikipedia.org/wiki/Procfs)` pseudo-filesystem mounted at `/proc`.
1. Create the `/proc` directory:
    ```sh
    mkdir /proc
    ```
1. Mount the `proc` filesystem:
    ```sh
    mount -t proc proc /proc
    ```
1. This causes the kernel to populate the `/proc` directory with information about the system's running processes
    * Browse the `/proc` filesystem hierarchy to see information about processes, including those that are outside of the `chroot`'ed environment.
    * The `ps` command now also works; notice, however, that the PID values are very high numbers. This is because we are still using the same `pid` Linux kernel namespace as is being used outside of the `chroot` environment.

# Additional references

> :construction: TK-TODO
