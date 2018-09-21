# Securing a Shell Account on a Shared Server

Before the days of corporate social media and Web-based services, socializing online meant connecting to a single computer that your friends were also connecting to. In fact, "connecting" typically meant "dialing," because these shared computers were usually only reachable via phone lines. To make a connection from your computer to the shared computer, you would literally place a physical telephone receiver on a special piece of hardware, nowadays called a modem, and then you would dial the number of the shared computer on your telephone.

When computers began getting connected to the Internet, fewer and fewer computers were addressable at dedicated phone numbers. Instead, they were typically addressable by their Internet Protocol (IP) addresses. Instead of using a physical telephone to call remote computers, you would purchase Internet connectivity from an Internet Service Provider (ISP). This is the Internet we all know and, well, have mixed feelings about today.

No matter how you connect to a shared computer, though, once you're connected, less than you might think has changed since the 1970's and 80's. You can still talk with fellow users who are logged on at the same time as you, send one another electronic mail ("e-mail"), play games, post on forums, and more. In fact, you used to be able to do a whole lot more, and much of what was possible has been forgotten in favor of the strip mall styles of Facebook and Twitter.

Of course, that increased potential and power of shared computers came with increased risks. If they weren't careful, users could reach other's files, hog system resources, and generally make trouble for one another. It was, after all, a shared space, not unlike living with roomies.

In this workshop, we'll explore what it meant—and still means—to have a user account on a shared computer, and what it takes to protect yourself from other users (whether malicious or not) who are using the same system.

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

* The ability to properly set and audit permissions for files and folders.
* The ability to… :construction: TK-TODO

# Bill of materials

This folder contains the following files and folders:

* `README.md` - This file.
* `provision/` - Folder containing files that are used when automatically setting up the lab environment.
* `Vagrantfile` - Configuration file describing the shared server environment used in the lab.

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

> :construction: TK-TODO
>
> Refer to [Introduction to Securing (Virtualized) Secure Shell Servers § Set up](../introduction-to-securing-virtualized-secure-shell-servers/README.md#set-up) section for "VirtualBox installation" and "Vagrant installation", as we'll need those. Alternatively, you can use a shell account that you have on any other service, such as your ISP's or a freebie from a provider such as Tilde.club, Tilde.town, and so on.

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
