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
    1. Components of a Web-based phishing attack
        1. Bait
            1. Email bait
            1. Text message bait
            1. Social media message bait
            1. Other types of phishing bait
        1. Look-alike Web site
        1. Command and Control server
    1. Distinguishing Web browser chrome from remote content
    1. Spoofable parts of Web browser chrome
        1. Title bar
        1. Address bar
        1. Lock icon
        1. TLS certificate subject information
    1. Checking TLS certificate fingerprints
    1. Crafting a look-alike Web site
        1. Coding from scratch
        1. Mirroring existing sites with `wget`
    1. Publishing phishing sites on the Web
    1. Receiving POST-backs from lured users
    1. Automating the attack
1. [Discussion](#discussion)
    1. Leveraging current events in phishing bait
    1. Web address (URL) obfuscation techniques
        1. Registering look-alike domain names
            1. Domain misspellings and pluralizations
            1. Using alternate character sets
            1. Using IRIs for IDN homograph attacks
        1. Using subdomains of look-alike domain names
        1. Using URL shorteners
        1. Spoofing DNS
    1. Obtaining TLS certificates for phishing attacks
        1. Generating your own TLS certificate
        1. Using the Automated Certificate Management Environment (ACME)
        1. Tricking a legitimiate Certificate Authority to issue you a new certificate
        1. Stealing authentic certificates from target sites
    1. Auditing your device's root certificate store
    1. Monitoring the Certificate Transparency Log (CTL) for phishing attacks
    1. Command and Control (C2) infrastructures for large-scale phishing campaigns
1. [Additional references](#additional-references)

# Objectives

When you complete this exercise, you will have acquired the following capabilities:

* The ability to preview where clicking a link will take you before you visit the link.
* The ability to verify the identity of the owner of a Web site by examining its security certificate in your Web browser.
* The ability to more reliably recognize differences between legitimate communications and scams.
* The ability to utilize the [Social Engineer's Toolkit](https://www.trustedsec.com/social-engineer-toolkit-set/) to launch a rudimentary phishing attack.

# Scenario

[![Clip from "Mr. Robot" Season 1, Episode 3, where Elliot phishes his neighbor, Shayla.](https://web.archive.org/web/20170317233813/https://i.imgur.com/5js8hxe.jpg)](Mr.%20Robot%20S01E03%20-%20Simple%20Phishing%20Scam.mp4?raw=true)

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

* For managing the virtual machines: [VirtualBox](https://www.virtualbox.org/) version 6.1 or newer, sometimes written as *VBox*.
* For automatically configuring virtual machine settings: [Vagrant](https://vagrantup.com/) version 2.2.7 or newer.

Complete the [Introduction to Virtual Machine Management with Vagrant](../introduction-to-virtual-machine-management-with-vagrant/README.md) practice lab before this one if you do not yet have VirtualBox and Vagrant installed or are unfamiliar with how to use them.

Then, bring the virtual machine(s) for the lab online.

**Do this:**

1. Boot the virtual machine needed for the lab:
    ```sh
    vagrant up
    ```

Once the virtual machine is running, you can continue to the next step.

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

