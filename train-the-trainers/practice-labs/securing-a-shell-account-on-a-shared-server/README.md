# Securing a Shell Account on a Shared Server

Before the days of corporate social media and Web-based services, socializing online meant connecting to a single computer that your friends were also connecting to. In fact, "connecting" typically meant "dialing," because these shared computers were usually only reachable via phone lines. To make a connection from your computer to the shared computer, you would literally place a physical telephone receiver on a special piece of hardware, nowadays called a modem, and then dial the number of the shared computer on the phone.

As computers started connecting to the Internet, fewer and fewer computers remained addressable at dedicated phone numbers. Instead, they were typically addressable by their Internet Protocol (IP) addresses. "Calling" remote computers was replaced by simply "connecting" to them over the Internet. This necessitated purchasing Internet connectivity from an Internet Service Provider (ISP) and begot the Internet we all know and, well, have mixed feelings about today.

No matter how you connect to a shared computer, though, once you're connected, less than you might think has changed since the 1970's and 80's. You can still talk with fellow users who are logged on at the same time as you, send one another electronic mail ("e-mail"), play games together, post to and read forums, and more. In fact, we used to be able to do a whole lot more, and much of what used to be possible has been forgotten in favor of the strip mall style interactions engineered by the Facebooks and Twitters of today.

Of course, that increased potential (and power) of shared computers came with increased risks. If you weren't careful, or didn't really know how to be, you might leave your private files within reach of other users, accidentally deplete system resources from others, and generally make trouble for one another. It was, after all, a shared space, not unlike living with roomies.

While some of this is still true today—many people still don't understand how or what it even means to tweak the privacy settings on their Facebook posts—all of the day-to-day concepts of the Internet we're familiar with today such as social networking and file sharing, originated in this older context. In this workshop, we'll explore what it meant—and still means—to have a user account on a shared computer. We'll also look at what it takes to protect yourself from other users (whether malicious or not) who are using the same system as you are.

# Contents

1. [Objectives](#objectives)
1. [Bill of materials](#bill-of-materials)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
1. [Practice](#practice)
    1. [Introduction](#introduction)
1. [Discussion](#discussion)
1. [Additional references](#additional-references)

# Objectives

When you complete this lab, you will have acquired the following capabilities:

* The ability to set up and personalize a profile on a UNIX-style shared server.
* The ability to properly set and audit permissions for files and folders, both your own and your fellow users's.
* The ability to look around digital environments, such as examine running processes.
* The ability to socialize with other users through age-old utilities that predated the Web by decades.

# Bill of materials

This folder contains the following files and folders:

* `README.md` - This file.
* `Vagrantfile` - Configuration file describing the shared server environment used in the lab.
* `provision/` - Folder containing files that are used when automatically setting up the lab environment.

# Prerequisites

To perform this lab, you must have:

* A computer running any modern version of:
    * Windows,
    * macOS,
    * FreeBSD,
    * Solaris, or
    * any flavor of the GNU/Linux operating system.
* An active Internet connection (for downloading the required tools in the [set up](#set-up) step, as well as Vagrant base boxes, and the required software packages into the virtual machines; you do not need an Internet connection once you have completed the set up portion of this lab).

In addition, you will need a user account on a remote system. This practice lab includes an automatically-generated virtual machine that you can use to simulate a remote system. Alternatively, you can sign up for an account from a service provider, which can often be obtained free of charge. While most of the practice lab's sections can be accomplished on such an account, some are deliberately designed to cause problems for the server or other users and should only be attempted in the lab environment provided with this guide.

With that understood, if you choose to proceed with the practice lab's own virtualized server, you will also need:

* [VirtualBox](https://www.virtualbox.org/), for running the virtualized server. :beginner: See this [§ "VirtualBox installation"](../introduction-to-securing-virtualized-secure-shell-servers/README.md#virtualbox-installation) section for detailed instructions on installing VirtualBox.
* [Vagrant](https://www.vagrantup.com/), for automatically configuring the lab environment on the virtualized server. :beginner: See this [§ "Vagrant installation"](../introduction-to-securing-virtualized-secure-shell-servers/README.md#vagrant-installation) section for detailed instructions on installing Vagrant.

Alternatively, if you choose to get a user account on a publicly accessible shared server, you will need to acquire such an account yourself. The procedure for registering such an account varies from one provider to another. Generally, however, you fill out a Web form or send an email to an administrator who reviews your application and processes (or denies) your request. See [our list of free shell account providers](https://github.com/AnarchoTechNYC/meta/wiki/Free-shell-account-providers) for links to a variety of options.

> :beginner: :computer: This exercise requires the use of a command line, or "terminal." If you don't know what that means, or if you do but you feel intimidated by that, consider spending an hour at [Codecademy's interactive tutorial, "Learn the Command Line"](https://www.codecademy.com/learn/learn-the-command-line) (for macOS or GNU/Linux users) or reviewing [Computer Hope's article, "How to use the Windows command line (DOS)"](http://www.computerhope.com/issues/chusedos.htm) (for Windows users) if you want to get started quickly. You don't need to complete the whole tutorial or article to understand this exercise, but it will dramatically improve your comprehension of this exercise's mechanics. If you want a more thorough but equally gentle introduction to the same material, consider reading (and listening to) [Taming the Terminal](https://www.bartbusschots.ie/s/blog/taming-the-terminal/).

# Set up

> :construction: TK-TODO

## Creating your account

> :construction: TK-TODO
>
> * GECOS information using `chfn(1)`.
> * `.pgpkey`, `.project`, and `.plan`, files, for `finger(1)`, see http://www.catb.org/jargon/html/P/plan-file.html

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

> :construction: TK-TODO

# Discussion

> :construction: TK-TODO

# Additional references

> :construction: TK-TODO
