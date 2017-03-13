# Strengthening Passwords to Defend Against John

In this exercise we will obtain the password of an unsuspecting user by cracking the hashed copy of that user's password. Then we will use a password manager to strengthen the password in order to protect against the same sorts of attacks in the future. Our goal is to understand why and how password management software makes having a digital life both safer and easier at the same time.

1. [Objectives](#objectives)
1. [Scenario](#scenario)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
1. [Practice](#practice)
1. [Discussion](#discussion)
1. [Additional references](#additional-references)

# Objectives

When you complete this exercise, you will have acquired the following capabilities:

* The ability to make and use passwords for your personal accounts that are practically invincible against many attackers.
* The ability to retire old passwords and replace them with strong, new passwords with ease, on whatever schedule you want.
* The ability to determine other users's original passwords, if they are weak, despite very sophisticated attempts to protect them.
* The ability to guage the approximate, relative strength of a password using only "the naked eye."

# Scenario

[![Hacking Tyrell Wellick scene, using the `john` password cracker.](https://web.archive.org/web/20161213025246/https://hackertarget.com/mrrobot/wget-shellshock-john.png)](Mr.%20Robot%20S01E02%20-%20Hacking%20Tyrell%20Wellick.mp4%20README.md)

> Hacking Tyrell Wellick, you'd think it'd be tricky but it wasn't. Evil Corp's corporate mail servers? They haven't patched anything since Shellshock. He doesn't even use two-step verification. His password was just his wife's maiden name and Sweden's independence date, `66`. One "six" away from the obvious, but still. This is bad noob practice.

You are Elliot Alderson, ordinary cybersecurity engineer by day, vigilante hacker by night. In order to uncover Evil Corp's next nefarious plot, you must hack into the corporate email account of their Vice President of Technology, Tyrell Wellick. Fortunately for you, Evil Corp's mail servers run a webmail system vulnerable to an exploit called Shellshock, allowing you to obtain a file listing the usernames and passwords of everyone who uses the system. However, the passwords are obfuscated using a one-way mathematical function called a *hash* (or *digest*).

In order to recover the password, you must "crack" its hashed equivalent, revealing the plaintext original, so that you may impersonate Tyrell Wellick to the Evil Corp mail server and read his emails. Moreover, you must make sure that Tyrell Wellick is unable to hack you back, by setting all your online accounts to use "uncrackable" passwords and thereby protecting yourself against the very same attack.

# Prerequisites

To participate in this exercise, you must have:

* A computer running any modern version of:
    * Windows,
    * macOS, or
    * any flavor of the GNU/Linux operating system.
* An active Internet connection (for downloading the required tools in the [set up](#set-up) step; you do not need an Internet connection once you have the tools installed).

# Set up

In addition to your laptop or desktop computer, you will need to acquire the following tool:

* [John the Ripper password cracker](http://www.openwall.com/john/)

The rest of this section will describe how to install John the Ripper.

# Practice

# Discussion

# Additional references
