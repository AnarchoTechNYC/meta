# Recognizing fake websites and phishing scams

In this exercise we will create a fake version of a popular website's login page (a *[phishing](https://simple.wikipedia.org/wiki/Phishing) site*) in order to trick an unsuspecting user into giving us their username and password combination for that website. We will then be able to impersonate that user to the website, gaining access to their account. Our goal is to more quickly recognize the signs of a malicious website so that we sensitize ourselves to any red flags or warnings we experience while browsing the Web.

1. [Objectives](#objectives)
1. [Scenario](#scenario)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
    * [Exercise installation on Windows](#exercise-installation-on-windows)
    * [Exercise installation on macOS](#exercise-installation-on-macos)
    * [Exercise installation on GNU/Linux](#exercise-installation-on-gnulinux)
1. [Practice](#practice)
    1. [Introduction](#introduction)
1. [Discussion](#discussion)
1. [Additional references](#additional-references)

# Objectives

When you complete this exercise, you will have acquired the following capabilities:

* The ability to preview where clicking a link will take you before you visit the link.
* The ability to verify the identity of the owner of a Web site by examining its security certificate in your Web browser.
* The ability to more reliably recognize differences between legitimate communications and scams.
* The ability to utilize the [Social Engineer's Toolkit](https://www.trustedsec.com/social-engineer-toolkit-set/) to launch a rudimentary phishing attack.

# Scenario

[![Phishing Shayla scene.](https://web.archive.org/web/20170317233813/https://i.imgur.com/5js8hxe.jpg)](Mr.%20Robot%20S01E03%20-%20Simple%20Phishing%20Scam.mp4?raw=true)

> Of course I know Shayla. I hacked her email as soon as she moved in next door. With a simple phishing scam I owned her password pretty easily.

# Prerequisites

To participate in this exercise, you must have:

* A computer running any modern version of:
    * Windows,
    * macOS,
    * FreeBSD,
    * Solaris,
    * any flavor of the GNU/Linux operating system.
* An active Internet connection.

> :beginner: :computer: This exercise requires the use of a command line, or "terminal." If you don't know what that means, or if you do but you feel intimidated by that, consider going through [Tech Learning Collective&rsquo;s free, online and self-paced *Foundations: Command Line Basics* course](https://techlearningcollective.com/foundations/), spending an hour at [Apple's Terminal User Guide](https://support.apple.com/guide/terminal/) (for macOS users), [Ubuntu's Command Line for Beginners tutorial](https://ubuntu.com/tutorials/command-line-for-beginners) (for GNU/Linux users) or reviewing [Computer Hope's article, "How to use the Windows command line (DOS)"](http://www.computerhope.com/issues/chusedos.htm) (for Windows users) if you want to get started quickly. You don't need to complete the whole tutorial or article to understand this exercise, but it will dramatically improve your comprehension of this exercise's mechanics. If you want a more thorough but equally gentle introduction to the same material, consider reading (and listening to) [Taming the Terminal](https://www.bartbusschots.ie/s/blog/taming-the-terminal/).

# Set up

In addition to your laptop or desktop computer, you will need to acquire the following tools:

* For creating your phishing website: [Social Engineer's Toolkit (SET)](https://www.trustedsec.com/social-engineer-toolkit-set/), version 8 or newer.
    * While you can install SET on any computer, it is officially supported only on GNU/Linux systems, while macOS and Windows support is experimental. In order to provide a more reliable and consistent experience through this exercise, we will be installing SET into a GNU/Linux virtual machine.
* For managing the virtual machines: [VirtualBox](https://www.virtualbox.org/) version 5.0 or newer, sometimes written as *VBox*.
* For automatically configuring virtual machine settings: [Vagrant](https://vagrantup.com/) version 2.1 or newer.

There are pre-built versions of the VirtualBox hypervisor software for Windows, macOS, GNU/Linux, and Solaris available for download from the [VirtualBox downloads page](https://www.virtualbox.org/wiki/Downloads). Your operating system's package repositories may also include a copy of VirtualBox, but be certain to double-check the version available there before installing it to ensure you are using a new-enough version of the software. For [FreeBSD users, VirtualBox is provided as a package or a source port and can be installed by following the instructions in the FreeBSD Handbook, §21.6](https://www.freebsd.org/doc/handbook/virtualization-host-virtualbox.html).

Similarly, there are pre-built versions of Vagrant for Windows, macOS, and numerous different GNU/Linux flavors available from the [Vagrant downloads page](https://www.vagrantup.com/downloads.html). [Vagrant is also provided as a FreeBSD port](https://svnweb.freebsd.org/ports/head/sysutils/vagrant/). Solaris users can [install Vagrant by installing from source](https://www.vagrantup.com/docs/installation/source.html).

## Exercise installation on Windows

**Do this** to prepare your Windows computer for this exercise:

1. Install [VirtualBox](https://virtualbox.org/). The installation process for VirtualBox on Windows is straightforward, as it is the same as any other standard application. For details, see [§2.1 of the VirtualBox User Manual](https://www.virtualbox.org/manual/UserManual.html#installation_windows).
1. Install [Vagrant](https://vagrantup.com/). The installation process for Vagrant on Windows is straightforward, as it is the same as any other standard application. For details, see the [Vagrant installation documentation](https://www.vagrantup.com/docs/installation/).
1. [Download the exercise files as a ZIP archive](https://github.com/AnarchoTechNYC/meta/archive/master.zip) if you have not done so already.
1. [Extract (uncompress) the files from the archive](https://support.microsoft.com/en-us/help/14200/windows-compress-uncompress-zip-files).
1. Using the File Explorer, find the `recognizing-fake-websites-and-phishing-scams` folder inside the extracted archive. You can find this folder in the following way:
    1. Open the `train-the-trainers` folder.
    1. Open the `mr-robots-netlix-n-hack` folder.
    1. Open the `week-3` folder.
    1. Open the `recognizing-fake-websites-and-phishing-scams` folder.
1. Open a PowerShell (or Command Prompt) window in the exercise folder by right-clicking inside the File Explorer window and selecting the "`Open PowerShell window here`" or "`Open command window`" option from the contextual menu.
1. Type `vagrant up` at the command prompt and press the `Enter` or `Return` key on your keyboard to begin the remainder of the installation process.
1. You may be asked to select a network interface to bridge, choose the interface you want or if you are unsure, respond `1` and press the `Enter` or `Return` key to complete the remainder of the installation process.

Alternatively, you may attempt a manual installation of SET directly to your Windows computer, but this is left as an exercise for the reader.

## Exercise installation on macOS

**Do this** to prepare your macOS computer for this exercise:

1. Install [VirtualBox](https://virtualbox.org/). The installation process for VirtualBox on macOS is straightforward, as it is the same as any other standard application. For details, see [§2.2 of the VirtualBox User Manual](https://www.virtualbox.org/manual/UserManual.html#installation-mac).
1. Install [Vagrant](https://vagrantup.com/). The installation process for Vagrant on macOS is straightforward, as it is the same as any other standard application. For details, see the [Vagrant installation documentation](https://www.vagrantup.com/docs/installation/).
1. [Download the exercise files as a ZIP archive](https://github.com/AnarchoTechNYC/meta/archive/master.zip) if you have not done so already.
1. [Extract (uncompress) the files from the archive](https://support.apple.com/guide/mac-help/compress-uncompress-files-folders-mac-mchlp2528/mac).
1. Using the [Finder](https://support.apple.com/en-us/HT201732), find the `recognizing-fake-websites-and-phishing-scams` folder inside the uncompressed archive. You can find this folder in the following way:
    1. Open the `train-the-trainers` folder.
    1. Open the `mr-robots-netlix-n-hack` folder.
    1. Open the `week-3` folder.
    1. Open the `recognizing-fake-websites-and-phishing-scams` folder.
1. Open [the Terminal application](https://support.apple.com/guide/terminal/welcome/mac). A new macOS window with a command shell will open.
1. Navigate to the exercise folder by typing `cd ` (the letters `c`, `d`, and then a literal space) into the command shell, then dragging-and-dropping the `recognizing-fake-websites-and-phishing-scams` folder's icon onto the command shell. This will autocomplete the filesystem path to the exercise folder in the command shell window. Finally, press the `return` key on your keyboard. 
1. Type `vagrant up` at the Terminal prompt and press the `Enter` or `Return` key on your keyboard to begin the remainder of the installation process.
1. You may be asked to select a network interface to bridge, choose the interface you want or if you are unsure, respond `1` and press the `Enter` or `Return` key to complete the remainder of the installation process.

Alternatively, you may attempt a manual installation of SET directly to your macOS computer, but this is left as an exercise for the reader.

## Exercise installation on GNU/Linux

> :construction: TK-TODo

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

> :construction: TK-TODO

Site cloning is a form of credential harvesting:

1. Launch the Social Engineer's Toolkit:
    ```sh
    setoolkit
    ```
1. Choose the "Social-Engineering Attacks" item from the main menu, option number `1`.
1. Choose the "Website Attack Vectors" item from the submenu, option number `2`.
1. Choose the "Credential Harvester Attack Method" item from the submenu, option number `3`.
1. Choose the "Site Cloner" method, option number `2`.
1. Enter the IP address of the cloned Web form's HTTP POST location (the form's `action` attribute value). This should be the public IP address of your server. (Choose the automatically detected IP address by pressing `Enter`.)
1. Enter the URL of the site to clone. For example, `https://www.facebook.com/`

# Discussion

> :construction: TK-TODO

# Additional references

> :construction: TK-TODO

According to [Phishing.org](https://phishing.org), the term "phishing" been in use since approximately 1996:

> "According to Internet records, the first time that the term 'phishing' was used and recorded was on January 2, 1996. The mention occurred in a Usenet newsgroup called AOHell. It is fitting that it was made there too; America Online is where the first rumblings of what would become a major criminal issue would take place."

Since then, it has quickly become one of, if not the single most popular kind of cyber attack. In part, this is because it has become so easy to do over the last two decades. Plus, phishing works primarily on a security vulnerability that is notoriously difficult to patch: human fallibility.

In 2019, according to [Software-As-A-Service provider Retrust](https://retruster.com/blog/2019-phishing-and-email-fraud-statistics.html), phishing attempts have grown 65% in the last year, and account for a whopping 90% of all reported data breaches, while 76% of businesses reported being a victim of a phishing attack in the last year.

Business Email Compromise (BEC) scams cost over $12 billion dollars in business losses [according to the FBI](https://www.pymnts.com/news/b2b-payments/2018/fbi-business-email-scam-fraud-phishing/). As for phishing websites, Webroot reports that [nearly 1.5m new phishing sites are created each month](https://www.webroot.com/us/en/about/press-room/releases/nearly-15-million-new-phishing-sites).

