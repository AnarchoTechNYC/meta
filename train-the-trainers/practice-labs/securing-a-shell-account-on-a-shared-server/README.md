# Securing a Shell Account on a Shared Server

Before the days of corporate social media and Web-based services, socializing online meant connecting to a single computer that your friends were also connecting to. In fact, "connecting" typically meant "dialing," because these shared computers were usually only reachable via phone lines. To make a connection from your computer to the shared computer, you would literally place a physical telephone receiver on a special piece of hardware, nowadays called a *modem*, and then dial the number of the shared computer on the phone.

As computers started connecting to the [Internet](https://github.com/AnarchoTechNYC/meta/wiki/Internet), fewer and fewer computers remained addressable by dedicated phone numbers. Instead, they were typically addressable by their [Internet Protocol (IP) addresses](https://github.com/AnarchoTechNYC/meta/wiki/IP-address). "Calling" remote computers was replaced by simply "connecting" to them over the Internet. This necessitated purchasing Internet connectivity from an [Internet Service Provider (ISP)](https://github.com/AnarchoTechNYC/meta/wiki/Internet-Service-Provider-%28ISP%29) and begot the Internet we all know and, well, have mixed feelings about today.

No matter how you connect to a shared computer, though, once you're connected, less than you might think has changed since the 1970's and 80's. You can still talk with fellow users who are logged on at the same time as you, send one another electronic mail ("e-mail"), play games together, post to and read forums, and more. In fact, we used to be able to do a whole lot more, but much of what used to be possible has been forgotten in favor of the strip mall style interactions engineered by the Facebooks and Twitters of today.

Of course, the increased potential (and power) of shared servers came with increased risks. If you weren't careful, or didn't really know how to be, you might leave files intended to be private within reach of other users, accidentally (or intentionally!) deplete system resources, and generally make trouble for other users or the *system operators* (or "*sysop*") administering the machine. After all, the shared computer, often called a *mainframe*, was a shared space, not unlike living with roomies.

While some of this is still true today—many people still don't understand how or what it even means to tweak the privacy settings on their Facebook posts—all of the contemporary concepts of Internet use we're familiar with, like social networking and file sharing, originated in this much older context. In this workshop, we'll explore what it meant and still means to have a user account on a shared computer. We'll also look at what it takes to protect yourself from other users (whether malicious or not) who are using the same system as you are.

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

* The ability to set up user accounts and personalize a profile on a UNIX-style shared server.
* The ability to properly set and audit permissions for files and folders, both your own and your fellow users's.
* The ability to look around digital environments, such as examine running processes or finding and connecting to network services.
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
* An active Internet connection.

> :beginner: :computer: This exercise requires the use of a command line, or "terminal." If you don't know what that means, or if you do but you feel intimidated by that, consider spending an hour at [Codecademy's interactive tutorial, "Learn the Command Line"](https://www.codecademy.com/learn/learn-the-command-line) (for macOS or GNU/Linux users) or reviewing [Computer Hope's article, "How to use the Windows command line (DOS)"](http://www.computerhope.com/issues/chusedos.htm) (for Windows users) if you want to get started quickly. You don't need to complete the whole tutorial or article to understand this exercise, but it will dramatically improve your comprehension of this exercise's mechanics. If you want a more thorough but equally gentle introduction to the same material, consider reading (and listening to) [Taming the Terminal](https://www.bartbusschots.ie/s/blog/taming-the-terminal/).

In addition, you will need a user account on a remote system. This practice lab includes a virtual machine that you can use to simulate a remote system. (Creating the virtual machine is explained in the [Virtual server startup](#virtual-server-startup) section, below.) Alternatively, you can sign up for an account from a service provider, which can often be obtained free of charge.

> :beginner: :warning: While, depending on certain aspects of the provider's service,  most of the practice lab's sections can be accomplished on an account obtained from such a service provider, some exercises in this lab are deliberately designed to showcase creating problems for the server or other users and should only be attempted in the lab environment provided with this guide. If this is either your first time interacting with a command line or the first time you are sharing a server with other users, we strongly recommend sticking to the lab's own virtualized server to avoid the possibility of causing trouble for real people really trying to get real work done. You can think of it a bit like learning to drive; the chances of causing a crash and potentially hurting someone are much higher if you choose to get on the highway the very first time you get behind the wheel of a car. Maybe don't?

With that understood, if you choose to proceed with the practice lab's own virtualized server, you will also need:

* [VirtualBox](https://www.virtualbox.org/), for running the virtualized server.
    * :beginner: See [§ "VirtualBox installation"](../introduction-to-securing-virtualized-secure-shell-servers/README.md#virtualbox-installation) for detailed instructions on installing VirtualBox.
* [Vagrant](https://www.vagrantup.com/), for automatically configuring the lab environment on the virtualized server.
    * :beginner: See [§ "Vagrant installation"](../introduction-to-securing-virtualized-secure-shell-servers/README.md#vagrant-installation) for detailed instructions on installing Vagrant.

Alternatively, if you choose to use an account on a publicly accessible shared server and do not already have one, you will need to acquire such an account yourself. The procedure for registering such accounts varies from one provider to another. Generally, however, you fill out a Web form or send an email to an administrator who reviews your application and processes (or denies) your request. See [our list of free shell account providers](https://github.com/AnarchoTechNYC/meta/wiki/Free-shell-account-providers) for links to a variety of options.

> :beginner: :computer: Different computers are, well, different. They have different programs installed on them, their underlying Operating Systems behave differently, and they are attached to different networks. Even computers that are more-or-less the same in most respects may be configured in different ways. This means that interacting with one computer does not guarantee that you can do exactly the same things or do them in the same way when interacting with another computer. This holds true for the public, free shell accounts you can get on different providers. Those accounts may not provide the same sort of resources as the ones configured in this practice lab, so you may need translate this lab's exercises a fair bit to get them working on those systems.
>
> This variation in computer systems is another reason why we suggest sticking to the virtualized server this lab set up for you, especially if you're new to all this. The virtual server we provide is guaranteed to work the way we expect. That said, once you do run through this lab on the virtual server, and start to feel more comfortable sharing digital space with others, getting a free account on a different system can be a great learning opportunity and, not for nothing, quite a bit of fun.

# Set up

It seems obvious but is perhaps worth noting anyway that before you can explore a shell account on a shared server, you must have access to (or create) a server and a user account. This section walks you through the process of starting up the virtual server that comes with this guide, as well as the process of how user accounts on shared servers are created from the perspectives of both the server administrator and a regular user. Finally, this section also provides instructions on how to access the virtual server using the newly created user account, as well as a number of accounts that have already been created for the purpose of simulating the experience of a "multi-user system" in the safe and isolated environment of the practice lab.

## Virtual server startup

In this lab's folder, you should see a file whose name is `Vagrantfile`. This file describes the exact configuration of the hardware and software needed by the virtual server that we'll pretend is a publicly accessible, shared server. (If you're actually using a publicly accessible server, you can skip to the TK-TODO section.) You will be able to log in to this shared server as both an administrator and as numerous regular users.

First, though, you must create the server itself. In keeping with the objectives of this lab, the server's creation has been automated ("scripted") using a tool called `vagrant`.

> :beginner: We are about to create the server, which requires that you have the software listed in the [Prerequisites](#prerequisites) section correctly installed. If you didn't install the VirtualBox and Vagrant software packages on your computer yet, do that now. Go back to the Prerequisites section and follow the instructions behind the installation links.

**Do this:**

1. Open a terminal application on your computer, such as `cmd.exe` (if you're using a Windows computer) or `Terminal.app` (if you're using a macOS computer).
1. Navigate to this lab's folder with the `cd` command.
1. Create and turn on the shared server in one fell swoop by invoking the `vagrant up` command.

> :beginner: You will see a lot of output from the above command. If this is your first time spinning up a virtual machine with Vagrant and want to know more about what just happened (because, yeah, it was a lot), consider reading [Introduction to Securing (Virtualized) Secure Shell Servers § Set up](../introduction-to-securing-virtualized-secure-shell-servers/README.md#set-up). That other practice lab includes a huge amount of detail about both virtual machines and their automation using the Vagrant utility. A lot of detail about virtual machines and Vagrant has been omitted in the interests of brevity and to focus on the objectives of this lab: using a regular ("unprivileged") user account on a shared server. That being said, do read the other practice lab; the detail omitted here was included there.

Depending on the speed of your computer and your Internet connection, the above command could take a while to complete. Once your command prompt returns, make sure the server is online by invoking `vagrant status`. Vagrant's output is often very helpful. For example, the `vagrant status` command provides a natural-language description of its output, along with descriptions of how to stop the virtual machine when you're done with it, and how to bring it back up:

```sh
Current machine states:

default                   running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.
```

With the virtualized server successfully started, let's create your practice account.

## Creating your account

> :construction: TK-TODO
>
> * `adduser`, etc. from the admin's perspective, then…
> * GECOS information using `chfn(1)`.
> * `.pgpkey`, `.project`, and `.plan`, files, for `finger(1)`, see http://www.catb.org/jargon/html/P/plan-file.html

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

Computers used to be extremely expensive. Back in the 1970's and 80's, computers were housed on entire floors of huge institutions, such as the campus of University of California, Berkeley or the branch offices of Industrial Businesss Machine, Inc. (IBM). These computers were the size of whole rooms and, often, you only had access to them while you were physically in the building they were housed. You might be on another floor of the building, but your keyboard and monitor had a very long cable that snaked through crawlspaces, making its way to the main chassis of the big computer room. The main frame of those large computers could be thought of something like the body of an octopus whose tentacles reached to the cubicles in other parts of the building.

Since they were so large, these mainframe computers needed to service the workloads of many different users who were all connected to it at the same time. These users might be employees of the same company working in the same office, students located on the same campus, or researchers conducting their work from the same facility. To support this requirement, the mainframes ran software that managed access to the computer's physical resources, such as hard disk space and its central processing unit (CPU) that associated each request for such a resource with a user account. The user accounts, in turn, were associated with specific humans, typically by employee or student number. These systems are called [*multi-user operating systems* (or *multi-user software*, or even more technically accurate, *multi-tasking operating system*)](https://en.wikipedia.org/wiki/Multi-user_software), and they had names like AT&T UNIX®, an operating system designed and developed at Bell Labs, or the Berkeley Standard Distribution (BSD), which was based on the commercial UNIX® systems.

Imagine, for a moment, that you are an employee at a company with a mainframe system, or a student at a prestigious university that had a computer department. You come in to work or school and sit down at your desk. On your desk is a machine with a monitor and a keyboard. There is no mouse. There is no tower with a blinking light. There are no hard disk drives, no compact discs (CD's), and no thumbdrives anywhere in your office. There is only a keyboard with a long cable coming out the back, and a monitor with a similar but thicker cable.

On the monitor is a power button. When you press it, the screen flickers. Slowly, a green phosphorescent light shines from the video monitor in the shape of text. The text reads:

```
Login:
```

This moment is arguably one of the early geneses from which all modern computing was born. This simple experience of digital access is both the promise and the power that we will be exploring during this lab. If you can understand, at a deep and philosophical level, exactly what happened when your imaginary alter-ego from the 1970's turned on that monitor, there is nothing that happens on a computer today that will remain unknown to you.

What you are seeing is the result of electrical charges sent from the mainframe, somewhere else on campus, over the cabling, and ultimately into a cathode ray tube that fired electrons onto the glass of the monitor. The glass is coated with phosphorescent dust, which shines when charged. The result is the invitation into Wonderland: `Login:`.

In the mid-1980's, the *personal computer* emerged as a much smaller computer that people with means could buy and put on a table in their living room or garage. These personal computers had names like the [Commodore 64](https://simple.wikipedia.org/wiki/Commodore_64), [Altair 8800](https://en.wikipedia.org/wiki/Altair_8800), [Apple Lisa](https://en.wikipedia.org/wiki/Apple_lisa), and of course, the [IBM PC](https://en.wikipedia.org/wiki/IBM_Personal_Computer), literally an initialism of the Industrial Business Machine, Inc. Personal Computer. Unlike a mainframe, whose input and output peripherals (the keyboard, for input, and video monitor, for some of its output) extended outside of the main frame of the device, personal computers had all the mainframe's components condensed into a single chassis. They were, in essence, one tiny main frame.

Also unlike the mainframes of the previous generation, which were by design intended to be used by multiple *end users* at once, the personal computer was, well, designed for personal use. Put another way, personal computers didn't need `Login:` prompts because they were only ever designed to be used by one person: their owner. Instead of a `Login` prompt, you were immediately presented with a *command line* or *command prompt*, the digital equivalent of an assistant who asks, "What would you like to do, today?"

The famous Disk Operating System (DOS), on which the earliest versions of Windows ran, presented a command line that looked like `C:\> `. You could then type commands, which are instructions for what you would like the computer to do, and view the results of the computer's work. To this day, all computing, including all graphical interaction such as browsing Web sites, sharing files on Dropbox, or interacting on social media such as sending tweets, is simply a variant on this command-and-process model.

I'm going to say that again, because it's really important: to this day, all computing, including all graphical interaction, is just a variant on this command-and-process model. Before Web sites existed, there were [bulletin board systems (BBSs)](https://en.wikipedia.org/wiki/Bulletin_board_system). Like today's websites, BBSs were places to socialize and chat. Before there were BBSs, there were mainframes. Like yesteryear's BBSs, mainframes were places to collaborate on getting work done or just to chat with your cohort.

In this lab, we turn back the cultural clock to the 1970's and 1980's to experience what the world of computing was like before the Internet as it exists today. Our virtual server will use a modern-day operating system inspired by the UNIX-like operating systems, [GNU/Linux](https://simple.wikipedia.org/wiki/Linux), with all the contemporary amenities and security features it provides, but we will explore this machine and meet the others using it through the tactile and sensory experience of a 1970's mainframe system.

## Taking your first look around

> :construction: TK-TODO

# Discussion

> :construction: TK-TODO

# Additional references

> :construction: TK-TODO
