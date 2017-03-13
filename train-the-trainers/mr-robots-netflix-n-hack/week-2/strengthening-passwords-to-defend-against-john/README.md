# Strengthening Passwords to Defend Against John

In this exercise we will obtain the password of an unsuspecting user by cracking the hashed copy of that user's password. Then we will use a password manager to strengthen our own passwords in order to protect against the same sorts of attacks in the future. Our goal is to understand why and how password management software makes having a digital life both safer and easier at the same time.

1. [Objectives](#objectives)
1. [Scenario](#scenario)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
1. [Practice](#practice)
1. [Discussion](#discussion)
1. [Additional references](#additional-references)

# Objectives

When you complete this exercise, you will have acquired the following capabilities:

* The ability to make and use passwords for your user accounts that are practically invincible against many attackers.
* The ability to replace old passwords with strong new passwords easily, on whatever schedule you want.
* The ability to determine other users's original passwords, if their's are weak, despite sophisticated attempts to protect them.
* The ability to guage the approximate relative strength of a password using only "the naked eye."

# Scenario

[![Hacking Tyrell Wellick scene, using the `john` password cracker.](https://web.archive.org/web/20161213025246/https://hackertarget.com/mrrobot/wget-shellshock-john.png)](Mr.%20Robot%20S01E02%20-%20Hacking%20Tyrell%20Wellick.mp4?raw=true)

> Hacking Tyrell Wellick, you'd think it'd be tricky but it wasn't. Evil Corp's corporate mail servers? They haven't patched anything since Shellshock. He doesn't even use two-step verification. His password was just his wife's maiden name and Sweden's independence date, `66`. One "six" away from the obvious, but still. This is bad noob practice.

You are Elliot Alderson, ordinary cybersecurity engineer by day, vigilante hacker by night. In order to uncover Evil Corp's next nefarious plot, you must hack into the corporate email account of their Senior Vice President of Technology, Tyrell Wellick. Fortunately for you, Evil Corp's mail servers run a webmail system vulnerable to an exploit called Shellshock, which has enabled you to obtain a file listing the usernames and passwords of everyone who uses the system. However, the passwords are obfuscated using a one-way mathematical function called a *hash* (or *digest*).

In order to recover the password, you must "crack" its hashed equivalent, revealing the original. Once cracked, you may impersonate Tyrell Wellick to the Evil Corp mail server by using his username and password to log in as him, thereby gaining access to his emails. Moreover, to make sure that Tyrell Wellick is unable to hack you back, you must set all your online accounts to use "uncrackable" passwords to protect yourself against the very same attack.

# Prerequisites

To participate in this exercise, you must have:

* A computer running any modern version of:
    * Windows,
    * macOS, or
    * any flavor of the GNU/Linux operating system.
* An active Internet connection (for downloading the required tools in the [set up](#set-up) step; you do not need an Internet connection once you have the tools installed).

> :beginner: :computer: This exerise requires the use of a command line (or terminal). If you don't know what that means, or if you do but you feel intimidated by that, consider spending an hour at [Codecademy's Learn the Command Line interactive tutorial](https://www.codecademy.com/learn/learn-the-command-line). You don't need to complete their tutorial to understand this exercise, but it will dramatically improve your comprehension of this exercise's mechanics.

# Set up

In addition to your laptop or desktop computer, you will need to acquire the following tool:

* [John the Ripper password cracker](http://www.openwall.com/john/)

A number of different installation procedures are available. If you're comfortable doing so, you can follow the above link, download, and install the software configuration of your choosing. (See [Beginner's Guide to Installing from Source](http://moi.vonos.net/linux/beginners-installing-from-source/) if you're not comfortable, but want to try that anyway.) The rest of this section will describe more common approaches to installing John the Ripper in a little more detail.

## Installation on Windows

Two pre-built Windows versions of John the Ripper are available. One is an "official" build, compiled by the tool's original developers, and the second is a "community-enhanced" build, which bundles (literally) hundreds of additional features written by volunteers into the application itself. For the purposes of this exercise, it does not matter which version you choose to get. To install John the Ripper, take the following steps:

**Do this:**

1. Go to [the John the Ripper homepage](http://www.openwall.com/john/).
1. Download the Windows version of your choice. At the time of this writing, these are:
    * [John the Ripper 1.8.0-jumbo-1 community-enhanced version for Windows](http://www.openwall.com/john/j/john180j1w.zip) (recommended)
    * [John the Ripper 1.7.9 official free version for Windows](http://www.openwall.com/john/h/john179w2.zip)
1. Unzip the file. Usually, this is as simple as right-clicking on it and selecting *Extract All* from the context-menu. (See [the Windows Help "Compress and uncompress files (zip files)" article](https://support.microsoft.com/en-us/help/14200/windows-compress-uncompress-zip-files).)
    * This will produce a folder, inside of which is another folder named `run`. Inside *that* folder is a file called `john` (or `john.exe` if your computer is [set to display file extensions](http://www.computerhope.com/issues/ch000573.htm)). That file is the main John the Ripper application. Unlike most Windows applications, this program must be run [using the Windows Command Prompt](http://www.computerhope.com/issues/chusedos.htm); you cannot simply double-click it. However, `john.exe` is now successfully "installed."

## Installation on macOS

A pre-built macOS version of John the Ripper is available for modern Apple Macintosh computers, that is, Macs with an Intel processor. (See [About System Information on your Mac](https://support.apple.com/en-us/HT203001) to learn how to find out what processor your Mac has.) If you have such a Mac, then to install John the Ripper, take the following steps.

**Do this:**

1. Go to [John the Ripper's macOS community-contributed builds page](http://download.openwall.net/pub/projects/john/contrib/macosx/).
1. Download the latest archive file available. (As of this writing, that is [`john-1.7.9-jumbo-7-macosx-Intel-2.zip`](http://download.openwall.net/pub/projects/john/contrib/macosx/john-1.7.9-jumbo-7-macosx-Intel-2.zip).)
1. Unzip the file. Usually, this is as simple as double-clicking on it.
    * This will produce a folder, inside of which is another folder named `run`. Inside *that* folder is a file called `john`. That file is the main John the Ripper application. Unlike a classic macOS application, this program must be run [using the Terminal](http://guides.macrumors.com/Terminal); you cannot simply double-click it. However, `john` is now successfully "installed."

## Installation on GNU/Linux

> :construction: TK-TODO: These instructions are currently missing. Please add them!

# Practice

# Discussion

# Additional references
