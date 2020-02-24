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
    1. [Virtual server startup](#virtual-server-startup)
    1. [Creating your shell account](#creating-your-shell-account)
1. [Practice](#practice)
    1. [Introduction](#introduction)
    1. [Logging in for the first time](#logging-in-for-the-first-time)
    1. [Welcome to Wonderland](#welcome-to-wonderland)
    1. [Hello, world](#hello-world)
    1. [Looking around in digital space](#looking-around-in-digital-space)
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

> :beginner: :computer: This exercise requires the use of a command line, or "terminal." If you don't know what that means, or if you do but you feel intimidated by that, consider going through [Tech Learning Collective&rsquo;s free, online and self-paced *Foundations: Command Line Basics* course](https://techlearningcollective.com/foundations/), spending an hour at [Apple's Terminal User Guide](https://support.apple.com/guide/terminal/) (for macOS users), [Ubuntu's Command Line for Beginners tutorial](https://ubuntu.com/tutorials/command-line-for-beginners) (for GNU/Linux users) or reviewing [Computer Hope's article, "How to use the Windows command line (DOS)"](http://www.computerhope.com/issues/chusedos.htm) (for Windows users) if you want to get started quickly. You don't need to complete the whole tutorial or article to understand this exercise, but it will dramatically improve your comprehension of this exercise's mechanics. If you want a more thorough but equally gentle introduction to the same material, consider reading (and listening to) [Taming the Terminal](https://www.bartbusschots.ie/s/blog/taming-the-terminal/).

In addition, you will need a user account on a remote system. This practice lab includes a virtual machine that you can use to simulate a remote system. (Creating the virtual machine is explained in the [Virtual server startup](#virtual-server-startup) section, below.) Alternatively, you can sign up for an account from a service provider, which can often be obtained free of charge.

> :beginner: :warning: Depending on certain aspects of the provider's service, most of the practice lab's sections can be accomplished on an account obtained from such a service provider. However, some exercises in this lab are deliberately designed to showcase creating problems for the server or other users and should only be attempted in the lab environment provided with this guide. If this is either your first time interacting with a command line or the first time you are sharing a server with other users, we strongly recommend sticking to the lab's own virtualized server to avoid the possibility of causing trouble for real people really trying to get real work done. You can think of it a bit like learning to drive; the chances of causing a crash and potentially hurting someone are much higher if you choose to get on the highway the very first time you get behind the wheel of a car. Maybe don't?

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

It seems obvious but is perhaps worth noting anyway that before you can explore a shell account on a shared server, you must have access to (or create) a server and a user account. This section walks you through the process of starting up the virtual server that comes with this guide, as well as the process of how user accounts on shared servers are created from the perspectives of both the server administrator and a regular user. Finally, this section also provides instructions on how to access the virtual server using the newly created user account, as well as a number of accounts that have already been created for the purpose of simulating the experience of a multi-user system in the safe and isolated environment of the practice lab.

## Virtual server startup

In this practice lab's folder, find a file whose name is `Vagrantfile`. This file describes the exact configuration of the hardware and software needed by the virtual server that we'll be pretending is a publicly accessible shared server. (If you're actually using a publicly accessible shared server, you can skip to the [Practice](#practice) section.) You will be able to log in to this shared server as both an administrator and as numerous regular users.

First, though, you must create the server itself. In keeping with the objectives of this lab, the server's creation has been automated ("scripted") using a tool called `vagrant`.

> :beginner: We are about to create the virtual server, which requires that you have the software listed in the [Prerequisites](#prerequisites) section correctly installed. If you didn't install the VirtualBox and Vagrant software packages on your computer yet go back to the Prerequisites section and follow the instructions behind the installation links to do that now.

**Do this:**

1. Open a terminal on your computer, such as `cmd.exe` (if you're using a Windows computer) or `Terminal.app` (if you're using a macOS computer).
1. Navigate to this lab's folder with the `cd` command. For example:
    ```sh
    cd Documents/shell-account-practice-lab
    ```
1. Create and turn on the shared server in one fell swoop by invoking the `vagrant up` command:
    ```sh
    vagrant up
    ```

> :beginner: You will see a lot of output from the above command. If this is your first time spinning up a virtual machine with Vagrant and want to know more about what just happened (because, yeah, it was a lot), consider reading [Introduction to Securing (Virtualized) Secure Shell Servers § Set up](../introduction-to-securing-virtualized-secure-shell-servers/README.md#set-up). That other practice lab includes a huge amount of detail about both virtual machines and their automation using the Vagrant utility. A lot of detail about virtual machines and Vagrant has been here omitted in the interests of brevity and to focus on the objectives of this lab: using a regular ("unprivileged") user account on a shared server. That being said, do read the other practice lab eventually, as the detail omitted here was included there.

Depending on the speed of your computer and your Internet connection, the above command could take a while to complete. Once your command prompt returns, make sure the server is online by invoking `vagrant status`. Vagrant's output is often very helpful. For example, the `vagrant status` command provides a natural-language description of its output, along with descriptions of how to stop the virtual machine when you're done with it, and how to bring it back up:

```
Current machine states:

default                   running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.
```

With the virtualized server successfully started, let's create your practice account.

## Creating your shell account

Having a server is only part of the equation. To use the server for our purposes, you must also have a user account, sometimes referred to as a *shell account*. A user account is needed so that you can login to the system, which means identifying yourself as a user who has permission to use the computer's resources.

> :beginner: A *shell* is simply another term for a user interface. The term is a metaphor that refers to the outer-most layer of an Operating System, the software that makes a computer interactive, that brings it to life. If the operating system is the guts of the computer, the shell is its skin or, well, its shell. That is, it's the part you actually touch when interacting with it. Shells are usually either textual, in which case they are often called *command-line interfaces* or CLIs, or graphical, which are the windows, menus, and icons you may be most familiar with. Graphical shells are also called *graphical user interfaces*, or GUIs (pronounced "goo-ees").

Only people who have administrative access to the computer system may create new accounts. Regular users cannot do this. For the moment, let's pretend that you are not a regular user, but rather the administrator of the shared server.

As the administrator, you would be responsible for maintaining the operation of the system. This is why administrators are also sometimes called *system operators* or *sysops* for short. This responsibility encompasses monitoring the system to ensure it is functioning within accepted parameters, reviewing and processing requests that require human interaction from the system's users, and performing any maintenance that requires special privileges, such as updating software or installing security fixes (called *patches*).

Creating new user accounts is often, but not always, something that most systems require a human to approve. This is because user accounts are rather powerful things. An active account grants its user the ability to, well, use the computer system's resources, and a computer can be made to do some serious damage on other computers (and the world!) if used improperly or maliciously.

> :beginner: This practice lab isn't really intended to introduce you to system administration, so this section is intentionally terse. :construction: TK-TODO: Do we have good resources for intros to sysadmin stuff?

You might receive a request for a new user account via email, or in a meeting where your boss says "We just hired so-and-so and they need accounts on such-and-such machine," or by way of some Web-based tool like a project management or help desk or ticketing system. Regardless, you will have collected some basic information about the new user account. At a minimum, such requests include a username, which is the name of the account the person requesting the user account would like to use when logging in. Typically, they will also include some additional details, such as the full legal name of the person to whom the account will belong, or maybe a pseudonym, a phone number or two, and maybe some free-form text. All of this except the need for a username varies from one system to another.

For our virtual server, there is also one other piece of information that we'll need from the person requesting a new account: an SSH public key. In our case, since you're going to play the role of both the administrator and the regular user, we'll just generate the information we need. If this were an actual publicly accessible shared server, you might be expected to provide the SSH public key along with your requested username as part of whatever application process you need to go through to acquire the shell account.

> :beginner: SSH is an abbreviation for Secure Shell. It's complex enough that we could write a whole lab about it. In fact, we did: [Introduction to Securing (Virtualized) Secure Shell Servers](../introduction-to-securing-virtualized-secure-shell-servers/README.md). While we'll offer a terse explanation of setting up a new user account with an SSH public key here, we omit a lot of detail in the interests of brevity. See the SSH practice lab for more information about administering and using SSH.

Let's quickly run through an example procedure that is similar to one an administrator might use to create your shell account on a shared server:

**Do this:**

1. Open a new command prompt (terminal) window.
1. Navigate to the folder containing the virtual server.
1. Log in to the shared server under an account with adminsitrative access. In our case, since the virtualized server was configured by the Vagrant automation utility touched on earlier, we can simply invoke the `vagrant ssh` command to do this:
    ```sh
    vagrant ssh
    ```
    This command uses the `vagrant` utility to automatically configure the various login parameters used to access the server, and perform the login. After a login greeting, you will be presented with a command prompt on the virtual machine. The command prompt will look like this:
    ```
    vagrant@secacct-practice-lab:~$
    ```
1. Choose a new user account name. This can be a pseudonym, or it can be a lowercased version of your first and last name. For example, if your name is Jane Doe, you might choose `janedoe` as your username. The username you pick must not contain spaces.
1. Create a new user account with your chosen username. In the commands below, substitute your chosen user name anywhere the string `$user` appears:
    ```sh
    sudo adduser --disabled-password --add_extra_groups --gecos '' $user
    ```
    If you chose to use `janedoe` as your user account name, you should see output that looks like the following:
    ```
    Adding user `janedoe' ...
    Adding new group `janedoe' (1007) ...
    Adding new user `janedoe' (1007) with group `janedoe' ...
    Creating home directory `/home/janedoe' ...
    Copying files from `/etc/skel' ...
    Adding new user `janedoe' to extra groups ...
    Adding user `janedoe' to group `dialout' ...
    Adding user `janedoe' to group `cdrom' ...
    Adding user `janedoe' to group `floppy' ...
    Adding user `janedoe' to group `audio' ...
    Adding user `janedoe' to group `video' ...
    Adding user `janedoe' to group `plugdev' ...
    Adding user `janedoe' to group `users' ...
    ```
1. Create the new user's `.ssh` directory, which will store the user's SSH login credentials:
    ```
    sudo mkdir ~janedoe/.ssh
    ```
1. Move to the special `/vagrant` directory, which is shared between your physical ("host") machine and the virtualized server running inside the ("guest") virtual machine:
    ```sh
    cd /vagrant
    ```
    > :beginner: :bulb: Virtual machines configured with Vagrant often come equipped with a [*synced folder*](https://www.vagrantup.com/docs/synced-folders/), which is accessible as `/vagrant` inside the guest (virtual machine). The contents of this folder are the same as the contents of the folder containing the `Vagrantfile` on the host (your physical machine), known as your *Vagrant project directory*. This makes use of a VirtualBox featured called [Shared folders](https://www.virtualbox.org/manual/ch04.html#sharedfolders). Whatever you put into this special `/vagrant` folder on the virtualized server will appear as a file on your physical laptop, and vice versa.
1. Generate an SSH keypair, which is a private key and its public key counterpart, for use with the new account:
    ```sh
    ssh-keygen -t rsa -b 2048 -N '' -C "Securing a Shell Account Practice Lab" -f shell-account_rsa
    ```
    > :beginner: :warning: Among other security issues, this command creates an unprotected private key. An unprotected private key file is an identity file that is not secured with a password. As long as you only ever use this identity file for this practice lab, this isn't a problem. In a real-world situation, however, this is considered extremely dangerous. For more information about the security of SSH keypairs, please consult the [Introduction to Securing (Virtualized) Secure Shell Servers](../introduction-to-securing-virtualized-secure-shell-servers/README.md) practice lab.

    This command created two files: `shell-account_rsa` and `shell-account_rsa.pub`. The first (`shell-account_rsa`) is your account's *SSH private key* file (also called your *identity file*). The second, (`shell-account_rsa.pub`) is your account's *SSH public key* file. Again, refer to the [Introduction to Securing (Virtualized) Secure Shell Servers](../introduction-to-securing-virtualized-secure-shell-servers/README.md) for more information about these files. Soon, we'll use the identity file to log in as the user you just created.
1. Inform the newly created user account that SSH login attempts using the private key we just generated should be allowed to log in to the user account we just created by copying the newly generated public key file to the new user's `~janedoe/.ssh/authorized_keys` file:
    ```sh
    sudo cp shell-account_rsa.pub ~janedoe/.ssh/authorized_keys
    ```
1. Secure the user's `.ssh` directory by making sure the directory is only readable by that user:
    ```sh
    sudo chown -R janedoe:janedoe ~janedoe/.ssh
    sudo chmod 700 ~janedoe/.ssh
    ```
1. Log out of the virtualized server by invoking the `exit` command:
    ```sh
    exit
    ```

You have just created a new user account and gave the user access to this account by use of SSH public key authentication. As the administrator, you can now inform the user who requested the new user account that their account is ready for their use. Meanwhile, as the regular user, you now have access to your shell account on the shared server.

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

Computers used to be extremely expensive. Back in the 1970's and 80's, computers were housed on entire floors of huge institutions, such as the campus of the University of California at Berkeley (UC Berkeley) or the branch offices of International Business Machine, Inc. (IBM). These computers were the size of whole rooms and, often, you only had access to them while you were physically in the building they were housed. You might be on another floor of the building, but your keyboard and monitor had a very long cable that snaked through crawlspaces, making its way to the main chassis of the big computer in its own room. The main frame of those large computers could be thought of something like the body of an octopus whose tentacles reached to the cubicles in other parts of the building.

Since they were so expensive, in order to justify their cost and use in the first place, these mainframe computers needed to service the workloads of many different users at the same time. These users might be employees of the same company working in the same office, students located on the same campus, or researchers conducting their work from the same facility. To support this requirement, the mainframes ran software that managed access to the computer's equally expensive physical resources, such as hard disk space and its central processing unit (CPU), that associated each request for such a resource with a user account. The user accounts, in turn, were associated with specific humans, typically by employee or student ID number. These systems are called [*multi-user operating systems* (or *multi-user software*, or even more technically accurate, *multi-tasking operating systems*)](https://en.wikipedia.org/wiki/Multi-user_software). The Operating System software had names like AT&T UNIX®, an operating system designed and developed at Bell Labs, or the Berkeley Standard Distribution (BSD), which was based on the commercial UNIX® systems.

Imagine, for a moment, that you are an employee at a company with a mainframe system, or a student at a prestigious university that had a computer department. You come in to work or school and sit down at your desk. On your desk is a machine with a monitor and a keyboard. There is no mouse. There is no tower with a blinking light. There are no hard disk drives, no compact discs (CD's), and no thumbdrives anywhere in your office. There is only a keyboard with a long cable coming out the back, and a monitor with a similar but thicker cable.

On the monitor is a power button. When you press it, the screen flickers. Slowly, a green phosphorescent light shines from the video monitor in the shape of text. The text reads:

```
Login:
```

This moment is arguably one of the early geneses from which all modern computing was born. This simple experience of digital access is both the promise and the power that we will be exploring during this lab. If you can understand at a deep and philosophical level exactly what happened when your imaginary alter-ego from the 1970's turned on that monitor, then there is nothing that happens on a computer today that will be a mystery to you.

What you are seeing is the result of electrical charges sent from the mainframe, located somewhere else on campus, over the cabling and ultimately into a cathode ray tube that fired electrons onto the glass of the video monitor. The glass is coated with phosphorescent dust, which shines when charged. The result is your invitation into Wonderland: `Login:`.

In the mid-1980's, the *personal computer* emerged as a much smaller version of this same technology. People with means could buy and put a fully functional computer on a table in their living room or garage. These personal computers had names like the [Commodore 64](https://simple.wikipedia.org/wiki/Commodore_64), [Altair 8800](https://en.wikipedia.org/wiki/Altair_8800), [Apple Lisa](https://en.wikipedia.org/wiki/Apple_lisa) and, of course, the [IBM PC](https://en.wikipedia.org/wiki/IBM_Personal_Computer), literally an initialism for the International Business Machine, Inc. Personal Computer. Unlike a mainframe, whose input and output peripherals (the keyboard for input, and video monitor for some of its output) extended outside of the main frame of the device, personal computers had all the mainframe's components condensed into a single chassis. They were, in essence, one tiny main frame.

Also unlike the mainframes of the previous generation, which were by design intended to be used by multiple *end users* at once, the personal computer was, well, designed for personal use. Put another way, personal computers didn't need `Login:` prompts because they were only ever designed to be used by one person: their owner. Instead of a `Login` prompt, you were immediately presented with a *command line* or *command prompt*, the digital equivalent of an assistant who asks, "What would you like to do, today?"

The famous Disk Operating System (DOS), on which the earliest versions of Windows ran, presented a command line that looked like `C:\> `. You could then type commands, which are instructions for what you would like the computer to do, and view the results of the computer's work. To this day, all computing, including all graphical interaction such as browsing Web sites, sharing files on Dropbox, or interacting on social media by sending tweets on Twitter, is simply a variant on this command-and-process model.

I'm going to say that again, because it's really important: to this very day, all computing—including all graphical interaction—is just a variant on this command-and-process model. Before Web sites existed, there were [bulletin board systems (BBSs)](https://en.wikipedia.org/wiki/Bulletin_board_system). Like today's websites, BBSs were places to socialize and chat. Before there were BBSs, there were mainframes. Like yesteryear's BBSs, mainframes were places to collaborate on getting work done or just to chat with your cohort.

In this lab, we turn back the cultural clock to the 1970's and 1980's to experience what the world of computing was like before the Internet as it exists today. Our virtual server uses a modern-day operating system inspired by the prevailing UNIX-like operating systems, [GNU/Linux](https://simple.wikipedia.org/wiki/Linux), and it comes equipped with all the contemporary amenities and security features that operating system provides. But we will be exploring this machine, and meeting the others using it, through the tactile and sensory experience of a 1970's mainframe system.

If you're ready, let's take our first steps down the rabbit hole.

## Logging in for the first time

You arrive at your desk one September morning a little drowsy due to a restless evening the night before. It is your first real day at university. The mandatory orientations of the previous week were not unwelcome, but they proved less than exciting. You think paperwork has always been a chore. You plop yourself into your seat. Several manilla folders, a couple of hiliters, and several half-bent sheets of hand-written notes are strewn on your desktop, evidence of your tendency for taking copious notes. You take a sip from the mug in your hand. You taste the bitterness of office coffee.

Then your eyes settle on the video monitor and keyboard in the far corner of your desk. Just as you've done every day this week, you turn it on. It glows green and greets you with a familiar message:

```
Login:
```

You sigh, remembering yesterday. You had entered your name last morning as well, but were unceremoniously rebuffed:

```
No passwd entry for user 'janedoe'
```

As you grumble something about overworked and underpaid system operators, you resolve to try again this morning. Placing your coffee carefully to one side of your desk, you pull the keyboard towards your seat and swivel your chair towards the monitor. Let's see if the sysop has finally created your shell account.

**Do this:**

1. Open a new command prompt (terminal) window.
1. Navigate to the folder containing the virtual server.
1. Log in to the shared server using the account you requested. For our virtual server, the command to do this is `vagrant ssh -- -l $user -i $identity_file`, where `$user` is the user account name you chose earlier and `$identity_file` is the name of the file containing your SSH private key. If you are using an actual publicly accessible shared server, your system administrator should have supplied you with the syntax of an example command that will log you in. For example, if the user account you created on the virtual server is `janedoe` and the SSH private keys were created as described in the [Creating your shell account](#creating-your-shell-account) section, above, you should be able to log in by invoking the following command:
    ```sh
    vagrant ssh -- -l janedoe -i shell-account_rsa
    ```

    If successful, your command prompt will change to the following:

    ```
    janedoe@secacct-practice-lab:~$
    ```

## Welcome to Wonderland

It takes you by surprise. For a moment, you're not sure what you're looking at. A bunch of text has just scrolled by your screen, way too fast for you to read it all. This is not at all like earlier attempts. At first blush, all you can recognize is your command prompt:

```
janedoe@secacct-practice-lab:~$
```

You're in! Your account has been created and you are now logged in to the system. You scroll up a bunch to read some of what you missed. Several things stand out to you. The first chunk of output is the system's log-on message. It begins with a literal "Welcome" message:

```
Welcome to Ubuntu 16.04.5 LTS (GNU/Linux 4.4.0-133-generic x86_64)
```

There is a huge amount of information packed into this one line.

[Ubuntu](https://www.ubuntu.com/) is the name of a free operating system distribution. This server purports to be [version 16.04.5](http://releases.ubuntu.com/16.04/) of that operating system. ["LTS" is Ubuntu's abbreviation for "long term support."](https://wiki.ubuntu.com/LTS) An LTS release of Ubuntu is a version of the operating system that the vendor promises to maintain for a longer period of time than other versions. System administrators tend to prefer LTS releases (or whatever equivalent terminology is used by their operating system of choice) because it makes their jobs easier as fewer incompatibilities are introduced between software version releases.

Ubuntu is a derivative of [Debian](https://www.debian.org/), another operating system in the same family. In this case, the system is using the GNU/Linux kernel, specifically version `4.4.0-133-generic`. Furthermore, the kernel is built to run on the `x86_64` hardware architecture.

> :beginner: A *kernel* is the most foundational piece of an operating system. It is ultimately responsible for everything else that happens in the operating system, or the installed applications. The kernel is so named because it is conceptually at the core of the computer. It intializes hardware components such as disk drives, manages volatile random-access memory segments (RAM), and controls the central processing unit (CPU) of the computer.
>
> If the shell is the outermost layer in a computer system (the part you interact with as an end user), the kernel is the innermost layer.
>
> :beginner: :bulb: An operating system and a kernel are often discussed as though they are one and the same, but this is not technically accurate. Different operating systems, such as Ubuntu or Debian, can sometimes use different kernels. For example, while the Debian operating system currently only officially supports the GNU/Linux kernel, it [can be built to run on the GNU/Hurd kernel instead, and even officially supported the FreeBSD kernel in the past](https://en.wikipedia.org/wiki/Debian#Kernels).
>
> :beginner: :bulb: Most of the time, regular users don't have to worry about GNU/Linux kernels, or their versions. That task is delegated to the system administrator. However, in the age of personal computers, owning a computer system at all means you are both a regular user and that computer's system administrator. If you're also running a GNU/Linux-based operating system, such as Ubuntu, it certainly helps to know a little bit about kernels!
>
> In the example output above, the Ubuntu kernel version string `4.4.0-133-generic` has a specific meaning, described by [the Ubuntu Kernel Team](https://wiki.ubuntu.com/KernelTeam) in [their documentation](https://wiki.ubuntu.com/KernelTeam/BuildSystem/ABI). For the curious, this version is specifically GNU/Linux kernel version 4, major revision 4, minor revision 0, [application binary interface (ABI)](https://en.wikipedia.org/wiki/Application_binary_interface) version 133, of the `generic` [flavor](https://wiki.ubuntu.com/Kernel/Dev/Flavours). This doesn't typically mean very much to an ordinary user, except for the fact that it's a number you'll want to include when reporting issues, should issues arise, or when asked to collect more information to help a developer debug any issues you might encounter.
>
> :beginner: :bulb: Just as there are different operating systems, there are different hardware architectures, too. The most ubiquitous hardware for servers and most of the personal computer industry is [Intel's x86 microprocessor](https://simple.wikipedia.org/wiki/X86). Contemporary Apple macOS devices (not the iPhone, but the line of desktop and laptop Macintosh computers), Windows-based computers, and a huge range of BSD and GNU/Linux operating systems are all often built to be hardware-compatible with Intel's x86 chips.
>
> The `x86_64` variant is Intel's 64-bit computing hardware. The hardware is "64-bit" because the CPU can ingest 64 bits of data in one instruction. You might also see the term `amd64`, which is for all intents and purposes equivalent to `x86_64`. The `amd` stands for [Advanced Micro Devices (AMD), Inc.](https://simple.wikipedia.org/wiki/Advanced_Micro_Devices), a competitor to Intel producing microprocessors that are compatible with Intel's x86 instruction set.
>
> As an end user, you need to know which hardware your computer (or shared server) is using so that you know which pre-compiled software packages will run on your system. If you try to run software compiled for, say, an [Advanced RISC Machine (ARM)](https://simple.wikipedia.org/wiki/ARM_architecture) architecture on a machine that uses an Intel x86-based CPU, it certainly won't work.

Following the operating system's "Welcome" line are some pointers in the form of Web addresses. There are pointers to [the official Ubuntu documentation](https://help.ubuntu.com), the [homepage for a management service called Landscape](https://landscape.canonical.com), and links to where you can find [paid support](https://ubuntu.com/advantage) or [business consulting](http://www.ubuntu.com/business/services/cloud). These are here because the maker of Ubuntu, a for-profit corporation by the name of [Canonical, Ltd.](https://www.canonical.com/), bases its paid offerings on their free offerings. All of these services are optional, but some organizations who use the Ubuntu operating system subscribe to these services, as well.

You have no need of any of these, so you scroll right past this block of text:

```
 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud
```

Next, the system shows you a brief summary of the state of the currently installed software on the shared server. The server reports that everything is up to date: no packages can be updated and, of these, none are security updates.

```
0 packages can be updated.
0 updates are security updates.
```

That sounds like good news to you. You pause for a moment to wonder if perhaps everything is up to date because the university's sysop took the opportunity to perform some basic system maintenance while they were creating your user account.

> :beginner: A *package* is exactly what it sounds like: a pre-packaged piece of software. "Pre-packaged" usually means that it has been *compiled* for you. Compilation is the process of turning files containing *source code*, which are a bit like the words of a magic spell in a spellbook, into *machine code*, which are the actual program instructions fed into the computer's CPU when it runs the software program.
>
> Whether you realize it or not, you're already very familiar with software packages. For example, you use packages every time you install an app from the Google Play Store or the Apple App Store on your phone. Android apps that you install from the Google Play Store are simply "Android package files," literally a file that ends in `.apk`, which stands for "Android package." The Google Play Store, and all app stores, are simply graphical *package managers*, programs that manage the installation, removal, updating, and reporting on packages.

Immediately following the package summary is an update announcement:

```
New release '18.04.1 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


*** System restart required ***
```

This is a message from the Ubuntu operating system informing you that a newer LTS release of Ubuntu is available. You smile inwardly as you realize this message is certainly not intended for you. It's intended for the system administrator. Only an administrator has the privileges required to restart (or "reboot") the computer system, because doing so would interrupt all the other users connected to it. Moreover, only an administrator can make changes to the operating system, which a major upgrade would certainly be.

Your eyes linger on this message for longer than they need to. If this message was not intended for you, how is it that you're seeing it? What else can you find here that may not be intended for you? How much more is already in here, anyway? You push your mug of coffee further across your desk, realizing that you are now energized despite your relatively decaffeinated state. You read on, eyes widened in anticipation of what you might encounter next.

The system's welcome message ends rather abruptly with a bit of legalese:

```
The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.
```

After that, the sysop's own welcome message is printed. You can tell it's the sysop's message and not the Operating System vendor because the tone and the subject suddenly shifts to the specifics of the system you've just logged in to. And then, once again, the expectant prompt:

```
janedoe@secacct-practice-lab:~$
```

The square cursor sits there, blinking at the end of the line, waiting for you. Its green light shines into your eyes, reminding you of all the turn signals toggling on and off at each leg of your commute. How many turns did you take to get here? How many choices did you make that brought you to this moment?

And where will you turn to go next?

## Hello, world

When you first encounter it, you sense an undeniable starkness to the digital space you've just entered. You lean forward in your chair, leaning towards the screen, as if moving your eyes closer to text it displays will help you see past them, into the space beyond. The edges of each glyph of text blur slightly, producing an almost invisible halo around each printed character. A soft hum enters your peripheral awareness, with an occasional barely-audible crackle. Suddenly, you realize the sound is the electricity powering the monitor. It sounds almost as if it's preparing to leap from the monitor out onto your desk, escaping the confines of cable and metal. Or, maybe, that it's pulling you in.

Is this really happening? You think you should pinch yourself, just to make sure you're not still sleeping. Instead, you simply press the `Return` or `Enter` key on your keyboard. Dutifully, the mainframe processes your input and returns another prompt:

```
janedoe@secacct-practice-lab:~$
janedoe@secacct-practice-lab:~$
```

The appearance of the second prompt confirms it: you really are logged on, and you really are interacting with the mainframe. Pressing the `Return` key sent a newline character to the computer. The newline character was processed, literally writing a new line onto the screen. The new line moves the terminal's output up by one line. Since the only character you entered on the command line was a newline, after the newline was written, the computer prompted you again. You imagine a voice speaking to you emerging from the glass of the video monitor, a voice that only you can hear. "I have written a new line. What would you like to do next?" it says.

> :beginner: :bulb: A *newline character* is just like a letter, such as the letter `A`, except that instead of representing a letter, it represents a new line. Even though you may not have thought about it before, you're already familiar with newline characters because you use them every time you write anything down, anywhere, including a pen and paper. When you end one paragraph and begin another, you start writing the second paragraph on a new line in your notebook. This act of lifting your pen and then moving it to a new line in your notebook feels implicit to you because you're so used to doing it, but it is an actual, real-world action that you must take. If you were dictating an essay to a friend (or employee) who was typing your words up for you, a *typist*, you would instruct the typist to do this explicitly by saying something like, "New paragraph." The typist then understands that you intend to start a new paragraph.
>
> In the 1960's, typing these sorts of correspondence and memos was the job of someone called a secretary. A businessperson's secretary didn't have access to a computer, so instead they used mechanical typewriters. These analog machines also needed to be explicitly told to start a new line of text when the typist reached the right hand edge of the page. To do this, the typist would press keys on a special row of their typewriter containing *control characters*. One of these control characters was called a *line feed*, and it instructed the machine to move the paper up by one line. Immediately following the line feed, the typist would then press the *carriage return* key, which returned the physical carriage holding the paper in place to the right side of the typewriter. This positioned the type hammer (literally, a metal hammer shaped like a letter) at the left-most column of text on the page. At the end of each and every line, the typist needed to perform this line feed and carriage return sequence to begin a new line at the correct place on the page.
>
> Early digital equipment that replaced mechanical typewriters simply copied this mechanism verbatim. To move the cursor to the left of the screen, you would send the carriage return control character, sometimes written as `\r` in computer code. However, to move the cursor down one line of text, you would need to send the line feed, nowadays more simply called "new line," control character. In computer code a line feed or new line character is often written as `\n`. Together, this sequence is sometimes abbreviated as `CRLF`, for "carriage return line feed." The `Return` key on keyboards today is an evolutionary artifact descended from their typewriter ancestors.
>
> These days, since there is no longer a physical carriage holding paper to return anywhere, different systems interpret carriage return control characters in different ways. On UNIX-like systems, such as our GNU/Linux virtualized server, a carriage return is often meaningless. To move the cursor down a line and move it to the left of the screen, a single new line character (`\n`) suffices, which is the input you're sending when you press the `Return` key on your keyboard at a command prompt.

You have read about people who can talk to machines. You imagined secret chambers, hidden away behind locked doors, with dark rooms basking in blue from electric fires. The books and TV shows you watched as a child showed you tantalizing visions of far-future utopias and dystopias full of wondrous and terrifying automatons. Some were friendly, some were deadly, but all of them were powerful. But not until now have you ever had the chance to talk to a machine yourself.

Now that you were finally here, you feel a small twinge of disappointment as you realize you don't actually know what to say. The computer answers so quickly, and yet here you sit, keeping it waiting…and waiting. Worse, you realize that even if you did know what you wanted to say or do here, you wouldn't really know *how* to say or do anything here in the first place. How is it that the people you read about, the ones who can talk to computers, actually learned to communicate with machines? They must have had help.

You look up from the video monitor at the clock above your desk. It's still early. You straighten, pulling your shoulders back. Glancing about the office, you can see that almost no one else has arrived yet. It is just you and the machine. The two of you are going to have to figure out how to communicate with one another by yourselves.

Your fingers find your keyboard once again. They float above the keys for a moment, and then find purchase on the following keys: `h`, `e`, `l`, `l`, `o`, `?`. The sound of loud clacks ring your ears, as though echoing through a dark chamber like the ones you used to imagine. Each letter you type appears on your screen as you type it. Your console now looks like this:

```sh
janedoe@secacct-practice-lab:~$ hello?
```

The cursor at the end of the line blinks a couple more time. Then you press the `Return` key, sending a newline control character to the mainframe. The computer replies in an instant:

```
No command 'hello?' found, did you mean:
 Command 'hello' from package 'hello-traditional' (universe)
 Command 'hello' from package 'hello' (main)
hello?: command not found
```

Your eyes scan the textual reply. This feels different than you expected. You are not really speaking, but rather issuing instructions. Whatever you say here is interepreted as a command to be performed. Apparently, the mainframe does not know what to do when you ask it `hello?`. You're not entirely sure what `hello-traditional (universe)` or `hello (main)` mean, either, but what is very clear is that `hello?` is confusing the computer. After all, it told you this twice. Reading "`No command 'hello?' found`" and "`hello?: command not found`" almost feels like the computer is trying to be understood as hard you as are trying to understand it.

This is all starting to remind you of something eerily familiar. The bar you drank at last night was one of your first times going out for drinks on campus. You've never been a heavy drinker and didn't know exactly what to order. Cocktails have fancy names that don't always make sense to you. Why is it even called a "martini," anyway? The name seemed to make perfect sense to everyone around you, and after you asked for help from your friend, the bartender knew exactly how to prepare what you ordered. But the name is still a mystery to you, despite being uncomfortably familiar with its physical effects. If only you could've asked the bartender for help, without feeling like a square.

Perhaps the computer isn't impatiently waiting for your input. Maybe, just maybe, it is just waiting, neither patiently nor impatiently. Perhaps it will not embarass you to ask it for help.

**Do this:**

1. Return to a command prompt of your shell account on your shared server, if you are not already there. Remember, for the virtualized server prepared with this lab:
    1. Invoke the `vagrant status` command from within the Vagrant project root, which is the folder containing the `Vagrantfile` for this lab to check if the virtual server is running.
    1. Invoke the `vagrant up` command to turn on the virtual server. If the server is already running, this command will do nothing, so it is safe to use regardless of whether the server is currently on or off.
    1. Log in to your shell account with the `vagrant ssh` command, your shell account's user name, and your SSH identity file. For example:
        ```sh
        vagrant ssh -- -l janedoe -i shell-account_rsa
        ```
1. Ask your shell for help by entering the `help` command:
    ```sh
    help
    ```

Your fingers return to the keyboard. This time, you type a little faster: `h`, `e`, `l`, `p`, followed by the newline character, using the `Return` key. Suddenly, pages of text flash across your screen. Much like when you logged in, you have to scroll back to read it all. You do, so that you can begin reading the computer's reply, well, from its beginning:

```
GNU bash, version 4.3.48(1)-release (x86_64-pc-linux-gnu)
These shell commands are defined internally.  Type `help' to see this list.
Type `help name' to find out more about the function `name'.
Use `info bash' to find out more about the shell in general.
Use `man -k' or `info' to find out more about commands not in this list.

A star (*) next to a name means that the command is disabled.

 job_spec [&]                                                                                                                    history [-c] [-d offset] [n] or history -anrw [filename] or history -ps arg [arg...]
 (( expression ))                                                                                                                if COMMANDS; then COMMANDS; [ elif COMMANDS; then COMMANDS; ]... [ else COMMANDS; ] fi
 . filename [arguments]                                                                                                          jobs [-lnprs] [jobspec ...] or jobs -x command [args]
 :                                                                                                                               kill [-s sigspec | -n signum | -sigspec] pid | jobspec ... or kill -l [sigspec]
 [ arg... ]                                                                                                                      let arg [arg ...]
 [[ expression ]]                                                                                                                local [option] name[=value] ...
 alias [-p] [name[=value] ... ]                                                                                                  logout [n]
 bg [job_spec ...]                                                                                                               mapfile [-n count] [-O origin] [-s count] [-t] [-u fd] [-C callback] [-c quantum] [array]
 bind [-lpsvPSVX] [-m keymap] [-f filename] [-q name] [-u name] [-r keyseq] [-x keyseq:shell-command] [keyseq:readline-functio>  popd [-n] [+N | -N]
 break [n]                                                                                                                       printf [-v var] format [arguments]
 builtin [shell-builtin [arg ...]]                                                                                               pushd [-n] [+N | -N | dir]
 caller [expr]                                                                                                                   pwd [-LP]
 case WORD in [PATTERN [| PATTERN]...) COMMANDS ;;]... esac                                                                      read [-ers] [-a array] [-d delim] [-i text] [-n nchars] [-N nchars] [-p prompt] [-t timeout] [-u fd] [name ...]
 cd [-L|[-P [-e]] [-@]] [dir]                                                                                                    readarray [-n count] [-O origin] [-s count] [-t] [-u fd] [-C callback] [-c quantum] [array]
 command [-pVv] command [arg ...]                                                                                                readonly [-aAf] [name[=value] ...] or readonly -p
 compgen [-abcdefgjksuv] [-o option]  [-A action] [-G globpat] [-W wordlist]  [-F function] [-C command] [-X filterpat] [-P pr>  return [n]
 complete [-abcdefgjksuv] [-pr] [-DE] [-o option] [-A action] [-G globpat] [-W wordlist]  [-F function] [-C command] [-X filte>  select NAME [in WORDS ... ;] do COMMANDS; done
 compopt [-o|+o option] [-DE] [name ...]                                                                                         set [-abefhkmnptuvxBCHP] [-o option-name] [--] [arg ...]
 continue [n]                                                                                                                    shift [n]
 coproc [NAME] command [redirections]                                                                                            shopt [-pqsu] [-o] [optname ...]
 declare [-aAfFgilnrtux] [-p] [name[=value] ...]                                                                                 source filename [arguments]
 dirs [-clpv] [+N] [-N]                                                                                                          suspend [-f]
 disown [-h] [-ar] [jobspec ...]                                                                                                 test [expr]
 echo [-neE] [arg ...]                                                                                                           time [-p] pipeline
 enable [-a] [-dnps] [-f filename] [name ...]                                                                                    times
 eval [arg ...]                                                                                                                  trap [-lp] [[arg] signal_spec ...]
 exec [-cl] [-a name] [command [arguments ...]] [redirection ...]                                                                true
 exit [n]                                                                                                                        type [-afptP] name [name ...]
 export [-fn] [name[=value] ...] or export -p                                                                                    typeset [-aAfFgilrtux] [-p] name[=value] ...
 false                                                                                                                           ulimit [-SHabcdefilmnpqrstuvxT] [limit]
 fc [-e ename] [-lnr] [first] [last] or fc -s [pat=rep] [command]                                                                umask [-p] [-S] [mode]
 fg [job_spec]                                                                                                                   unalias [-a] name [name ...]
 for NAME [in WORDS ... ] ; do COMMANDS; done                                                                                    unset [-f] [-v] [-n] [name ...]
 for (( exp1; exp2; exp3 )); do COMMANDS; done                                                                                   until COMMANDS; do COMMANDS; done
 function name { COMMANDS ; } or name () { COMMANDS ; }                                                                          variables - Names and meanings of some shell variables
 getopts optstring name [arg]                                                                                                    wait [-n] [id ...]
 hash [-lr] [-p pathname] [-dt] [name ...]                                                                                       while COMMANDS; do COMMANDS; done
 help [-dms] [pattern ...]                                                                                                       { COMMANDS ; }
```

The first few lines of the computer's reply to your request for help are similar to the system's log on message. It tells you a name, something called `GNU bash`, then the version of whatever `GNU bash` is (`version 4.3.48(1)-release`), followed by information regarding the hardware for which this `GNU bash` thing was built (`(x86_64-pc-linux-gnu)`). All this information was on the first line of the reply:

```
GNU bash, version 4.3.48(1)-release (x86_64-pc-linux-gnu)
```

Next came the most comprehensible part of the reply. It sounds just like someone in a chat room replying to you:

```
These shell commands are defined internally.  Type `help' to see this list.
Type `help name' to find out more about the function `name'.
Use `info bash' to find out more about the shell in general.
Use `man -k' or `info' to find out more about commands not in this list.
```

It dawns on you that you are not merely connected to a computer. Indeed, you are already running a program on the mainframe. The program you are running is a [shell](https://github.com/AnarchoTechNYC/meta/wiki/Shell) called `GNU bash`, or just `bash` for short. When you typed `help`, you asked the app you are currently using (`bash`) to show you the help information for itself. The remainder of the help page lists the various words that the `bash` program understands when you speak them to it. Curious, you try asking for more specific help. You type `help name` and then press `Enter`:

```
janedoe@secacct-practice-lab:~$ help name
-bash: help: no help topics match `name'.  Try `help help' or `man -k name' or `info name'.
```

A smile creeps along your lips. When `bash` told you to "`Type 'help name' to find out more about the function 'name'.`, it did not mean you should literally type `h`, `e`, `l`, `p`, then a space, then `n`, `a`, `m`, and `e`, but rather to substitute `name` for the name of one of the commands in the list of commands `bash` understands. Sure enough, `name` is not included. Helpfully, `bash` offers further information about how to use the `help` command itself. You give that a go, typing `help help` and pressing the `Return` key to send your words off to the computer for a reply. As before, the response is returned to you with astonishing speed:

```
janedoe@secacct-practice-lab:~$ help help
help: help [-dms] [pattern ...]
    Display information about builtin commands.

    Displays brief summaries of builtin commands.  If PATTERN is
    specified, gives detailed help on all commands matching PATTERN,
    otherwise the list of help topics is printed.

    Options:
      -d        output short description for each topic
      -m        display usage in pseudo-manpage format
      -s        output only a short usage synopsis for each topic matching
        PATTERN

    Arguments:
      PATTERN   Pattern specifiying a help topic

    Exit Status:
    Returns success unless PATTERN is not found or an invalid option is given.
```

Some of this is clear to you, but much of it isn't. What's an "exit status" and what is the difference between an "option" and an "argument?" You remember grade school and how frustrating your French classes were. This feels like that. It feels like learning a new language. You skim the long list of available commands from the output of the `help` command again, looking for something you can say to the computer that you might already more-or-less be able to understand without too much more reading and fumbling. The commands are words like "`alias`", "`shift`", "`break`", "`declare`", "`bind`", "`echo`", "`read`", "`logout`", "`set`", and "`unset`". All of these and, in fact, most of the commands in the list are verbs. So this feels like learning a new language because it *is* a language.

You are learning to speak before you know what you might like to say. For a moment, this feels hopeless. What is the point of learning to speak if you do not know why you would bother? Then again, you have done this before. It is how you learned to speak with other humans. This is no different. It is simply a return to an earlier, younger part of your life. As with your speech, you learned to take your first step before you knew where you might want to go. The more words you learned, and the better you learned to control your limbs, the more you could do in the world. You became wise and powerful, and now, today, you will learn to speak and walk all over again. This time, you will learn to speak and walk and become powerful inside of a computer, inside Wonderland.

Over and over again for the next half hour, you type `help` followed by another command in the list. Over and over again, you read pages of text that you don't fully understand. You don't even hear your name being called from the cubicle next to yours.

"Jane! JANE!"

You feel torn out of cyberspace and back into the physical world. You look up to see your coworker and friend, Alice, looking at you with a slightly worried expression on her face.

"Jane, are you all right?"

"What? Yeah, fine. I'm fine. Sorry, I was just…." You turn to the video monitor, still humming quietly.

"Oh," Alice smiles. "You got your shell account."

"Yeah. I was just…reading the help pages. I've never used a GNU/Linux system before." You try to swallow the tone of embarassment from your voice, half unsure why you even feel that way. Nevertheless, you don't want it known that this is all new to you. Maybe it was something in the way the sysops talked to each other, like they were part of some club that would never have you as a member. Maybe it was a reaction to experiences you had in school when you got more excited than was apparently permitted about the lesson plan. Whatever it was, you didn't want to start your first week here on the wrong foot. But Alice had been welcoming since the moment you met her, and this was no different.

"That's awesome!" she exclaimed. "Want to show me what you've done so far?"

"I…well, I haven't done very much, yet. I'm not exactly sure what to do."

"Anything you want!" came Alice's excited reply. "What do you want to do?"

"I don't know. Just look around, I guess."

"Well, how would you feel about looking around with me?"

"I think I'd like that very much."

## Looking around in digital space

Alice pulls up a chair next to yours. She falls into it with a twirl of excitement. "All right," she starts. "Let's look around!" Instinctively, you begin to roll your chair away from the keyboard. "No, no," Alice stops you. "You drive," she smiles. You pull yourself back to the keyboard.

"Okay," you say. "What do I do first?"

"Well, before we can know where to go, we have to know where we are," Alice says. "Have you learned about the filesystem?"

You shake your head.

"Let's start there, then."

"Okay."

Alice leans forward in her chair to point at the screen at the back of the desk. "See the last line there, on the bottom of your window? That's your prompt. It's not just asking you what command to run next. It's also full of information that tells you about where you are and what's currently going on."

You review the prompt on the screen:

```
janedoe@secacct-practice-lab:~$
```

Alice continues, "The symbols on the command prompt are meaningful. On the far left, of course, is your username or login name. Some of us also call this your *handle*. That's just slang for 'nickname.' After your username comes an at-sign (`@`), which separates your name from the name of the computer to which you have just logged in. There cannot be another `janedoe` on this computer, but there might be another user named `janedoe` on some *other* computer. If you log in to another computer, even if your username is `janedoe` on that other computer, your prompt will be different because the hostname portion will be different. That's how you can know which computer you're actually talking to when you see a command prompt. We call the computer's name a *hostname* because it 'hosts' you while you're logged in. I think that's kind of sweet."

Alice's pause causes you to look back at her and away from the screen. "I like the metaphor," you say.

"There are a *lot* of metaphors," Alice says. "In fact, the very next part of the command prompt is this colon (`:`), which separates the hostname from the *pathname*. In this case, the pathname is the special symbol tilde (`~`). That symbol is shorthand for 'your home folder.' It's basically like your own office inside the computer. You can put your digital files here, organized in whatever way you like. By keeping your personal stuff inside your 'home' folder, it will always be easy to find."

"Do you have a home folder?" you ask Alice.

"I sure do! I'll show it to you in a minute," Alice says. "But first, there's one last part of the command prompt that's super important."

"The dollar sign (`$`) at the end?" you ask.

"Yup," Alice answers. "That dollar sign is the conventional way of telling you that you are speaking to a command shell and have regular user privileges, and not any special powers or elevated privileges like the sysops and administrators have."

"Right." You nod, but think it best not to ask too much about how to elevate your privileges just yet.

"So, you're speaking to a command shell, and you're in your home folder. Enter the `pwd` command, then press the `return` key to run that command."

"Okay," you say as you type. An instant later, your prompt looks like this:

```sh
janedoe@secacct-practice-lab:~$ pwd
/home/janedoe
janedoe@secacct-practice-lab:~$
```

> :construction: TK-TODO
>
> Go over the very basics of files and directories, that directories are files which simply contain a list of their contents, etc. This means we need to cover `pwd`, `ls`, `mkdir`, `cd`, `touch`, and other basics.
>
> Then get into communicating with another user. The first tool for this should be `write(1)`, as it is the simplest. This is also the very first security issue: use `mesg n` to disable messages from other users. Put this in a startup script (such as `.profile` or `.bash_login`) in order to disable write access to your STDERR file descriptor upon login.
>
> After that, we can do `talk`/`talkd`, as well as `ntalk`, `utalk`, or probably best of all for now, `ytalk`.

## Creating your user profile

> * GECOS information using `chfn(1)`.
> * `.pgpkey`, `.project`, and `.plan`, files, for `finger(1)`, see http://www.catb.org/jargon/html/P/plan-file.html

# Discussion

> :construction: TK-TODO

# Additional references

> :construction: TK-TODO
