# Introduction to Anonymous Communications Using Tor

*Tor* is a free, state-of-the-art, privacy-enhancing digital communications tool that evolved from work originally performed at the United States's Naval Research Laboratory (NRL) in the mid 1990's. Today, its steward is the [Tor Project](https://torproject.org/), a registered US-based 501(c)3 non-profit organization that coordinates ongoing work by the Free and Open Source Software (FOSS) community on Tor itself along with its related software components, such as the *Tor Browser*. Tor's core privacy-enhancing feature is its implementation of an encrypted [*onion routing*](https://en.wikipedia.org/wiki/Onion_routing) protocol that makes it possible to obscure the destination of a message from the message's intermediary handlers as well as simultaneously obscuring the source of the message from the recipient at the destination.

This ability to hide both the source and destination of messages makes Tor an invaluable tool in any privacy advocate's toolkit, since it enables both more anonymous online speech and far improved censorship circumvention efforts. After all, anonymity and censorship circumvention go hand-in-hand. If a censor does not know what information is being requested (because the destination is obscured), how can it know whether or not to perform any censorship? Similarly, if a server cannot determine who sent it a message (because the source is obscured), how can it make any discriminatory decisions based on that sender's identity?

While there are other privacy- and anonymity-enabling digital toolkits, the tools that the Tor Project is responsible for maintaining are arguably the most widely deployed and most rigorously tested by security researchers, academics, and cryptographers. This makes using Tor a good choice for many people who need or desire a safer, more private Internet, such as journalists, whistleblowers, activists, business people, and any privacy-conscious ordinary individual. In fact, Tor is famous both for [frustrating surveillance efforts](https://www.theguardian.com/world/interactive/2013/oct/04/tor-stinks-nsa-presentation-document) (even of very powerful entities such as the National Security Agency) and for its role in facilitating anonymous online interactions on the so-called "[*Dark Web*](https://en.wikipedia.org/wiki/Dark_web)."

In this practice lab, you will learn how Tor can maximize your privacy while using the Internet. In the process, we will demystify frequently misrepresented terms (such as "Dark Web"!) and debunk numerous myths and misconceptions about what Tor is, how it works, and why it can be valuable for you even if you are not hunted by your government or other law enforcement agency. Although familiarity with some basic computer networking concepts will be helpful, we try to present the material herein in a way that people new to digital privacy can still benefit, such as by illuminating the fact that *how one uses Tor* is just as important as the technical underpinnings of *how Tor works*.

# Contents

1. [Objectives](#objectives)
1. [Bill of materials](#bill-of-materials)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
    1. [Tor Browser installation](#tor-browser-installation)
        1. [Tor Browser installation on Windows](#tor-browser-installation-on-windows)
        1. [Tor Browser installation on macOS](#tor-browser-installation-on-macos)
        1. [Tor Browser installation on GNU/Linux](#tor-browser-installation-on-gnulinux)
1. [Practice](#practice)
    1. [Introduction](#introduction)
    1. [Your first Tor connection](#your-first-tor-connection)
    1. [Understanding the difference between Tor and Tor Browser](#understanding-the-difference-between-tor-and-tor-browser)
    1. [Understanding Tor circuits and relays](#understanding-tor-circuits-and-relays)
        1. [Guard relays](#guard-relays)
        1. [Middle relays](#middle-relays)
        1. [Exit relays](#exit-relays)
    1. [Using the New Identity button to isolate risky activities](#using-the-new-identity-button-to-isolate-risky-activities)
    1. [Internet censorship and circumvention basics](#internet-censorship-and-circumvention-basics)
        1. [Detecting a censored Internet connection](#detecting-a-censored-internet-connection)
        1. [Circumventing DNS-based censorship without Tor](#circumventing-dns-bsed-censorship-without-tor)
        1. [Circumventing application-layer censorship](#circumventing-application-layer-censorship)
        1. [Connecting to the Tor network via a Tor Bridge when Tor itself is censored](#conecting-to-the-tor-network-via-a-tor-bridge-when-tor-itself-is-censored)
    1. [Connecting to an authenticated Onion service](#connecting-to-an-authenticated-onion-service)
    1. [Torifying arbitrary applications](#torifying-arbitrary-applications)
        1. [Using proxy settings](#using-proxy-settings)
        1. [Torifying SSH](#torifying-ssh)
    1. [Your first Onion service](#your-first-onion-service)
    1. [Adding Tor authentication to your Onion service](#adding-tor-authentication-to-your-onion-service)
1. [Discussion](#discussion)
    1. [Additional Tor infrastructure: Directory Authorities](#additional-tor-infrastructure-directory-authorities)
1. [Additional references](#additional-references)

# Objectives

When you complete this lab, you will have acquired the following capabilities:

* The ability to proficiently use the Tor Browser to safely perform otherwise risky activites on the Web.
* The ability to detect, diagnose, and circumvent basic censorship activity blocking your access to the Internet.
* The ability to connect to online services that require Tor authentication credentials ("authenticated Onion services").
* The ability to "Torify" arbitrary applications, i.e., to proxy arbitrary applications's network requests through the Tor network.
* The ability to operate a basic Onion service ("Dark Web site") in both unauthenticated (publicly-accessible) and authenticated (more private) modes.

# Bill of materials

This folder contains the following files and folders:

* `README.md` - This file.

# Prerequisites

To perform this lab, you must have:

* A computer running any modern version of:
    * Windows,
    * macOS, or
    * any flavor of the GNU/Linux operating system.
* An active Internet connection.

# Set up

In addition to your laptop or desktop computer, you will need to acquire the following tools.

* [Tor Browser](https://www.torproject.org/download/)

Follow the above links. Then download and install the appropriate software package for your operating system. The installation processes should be familiar, since they are performed in the same way as for any other software application that runs on your operating system.

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

Although not officially an acronym, *Tor* is a state-of-the-art implementation of an *onion routing* system, so you could be forgiven for mistaking the name as an acronym for *The Onion Router*. Onion routing takes its name from the idea of wrapping something valuable up inside multiple layers of difficult-to-penetrate protection that must be unwrapped one at a time, "like the layers of an onion." On a computerized *onion network* (such as the *Tor network*), this protection is digital encryption. You might also hear the Tor network colloquially described as "*onionland*," so named both for the fact of its onion routing protocol and the [officially reserved top-level domain for servers on its network, whose names end in `.onion`](https://en.wikipedia.org/wiki/.onion).

Each message transmitted by your copy of the Tor software is (by default) *encapsulated* inside three layers of Tor's encrypted onion routing scheme, so that by the time your computer delivers your message to the Tor network itself, the content of your communication is already well-protected. The Tor network itself is made up of other computers very much like your own that are also running copies of the same Tor software in various configurations. This means that anyone who has a copy of the Tor software can use Tor both to provide privacy for their own communications&mdash;we call this *Tor client* behavior&mdash;as well as opt-in to donating a portion of their computer's own resources (its processing speed, network bandwidth, etcetera) to protect the privacy of other Tor users's communications&mdash;this is called *Tor relay* behavior.

By itself, Tor may seem to do very little because it merely provides an onion-routed transport channel for other applications. For example, the Tor Browser application uses the core Tor software to provide the ability to browse the Web through the Tor network. That is, Tor is proxying the Tor Browser's messages. We say that the Tor Browser is a "*torified* Web browser," meaning simply that it is a Web browser whose connections are going through the Tor network, i.e., they are "torified." Many applications beyond Web browsers can make use of Tor, of course, including instant message (IM) chat apps, digital calendaring services, contact books, e-mail, and much more. In each case, the application providing the specific functionality (such as IM chat) must be torified in order to gain the protections offered by Tor.

We'll soon see some examples of how to torify various applications but, first, let's go ahead and make our very first connection to Tor's onion routing network.

## Your first Tor connection

Connecting to the Tor network is deceptively simple, even anti-climactic. After hearing so much about the "Dark Web," you may be under the impression that accessing it takes superhero-like feats of technical acuity. In reality, accessing the Tor network in the simplest situation means launching the Tor Browser application and clicking the "Connect" button.

**Do this** to make your first connection to the Tor network via the Tor Browser:

1. Double-click on the Tor Browser icon that you downoaded earlier by following the [Set up](#set-up) steps. The Tor Network Settings wizard will open:  
   ![Screenshot of the Tor Browser's "Tor Network Settings" wizard interface on Windows.](screenshots/tor-browser-windows-network-settings-wizard.png)
1. Click the *Connect* button.
1. If all goes well, you will be connected to the Tor network. The Tor Browser will present you with a new window that may look very familiar, because it is based on a popular Web browser's interface. In the Web browser's viewport, you will see (something that looks similar to) the following screenshot:  
   ![Screenshot of Tor Browser's successful connection startup screen.](screenshots/tor-browser-about-tor.png) 

Believe it or not, you are now connected to the Tor network and, should you so desire, you can browse both regular Internet Web sites or *clearnet* sites as well as more anonymized *darknet* or *onionland* sites. All you need to know is what Web address (URL) to type into the Tor Browser's location bar, just as you would need to know for any other Web site using any other Web browser. But before we recklessly go gallivanting around the Dark Web, let's learn a little bit about what just happened and more about the tools we're using.

## Understanding the difference between Tor and Tor Browser

Often, Tor is discussed as though it is a single thing. Many trainers or friends may say things like, "I only use Facebook over Tor," or, "as a journalist, I often use Tor," or, "make sure you're using Tor," or, "this site is a dark web website only accessible through Tor," and so forth.

While it is half true that Tor is a single thing, this idea is slightly misleading. When talking about Tor colloquially, it behoves us to make a distinction between Tor itself and Tor *Browser*, because the truth is they are actually two distinct things.

To illustrate this, let's try simply opening Tor Browser before we move on to making and examining a connection elsewhere.

### A tale of two processes

It may be helpful for understanding the difference between Tor and Tor Browser by first opening a process monitor on your machine, so that you may see the difference between the Tor process and the Tor Browser process (which, again, is really just a Firefox process).

1. Open your computer's process monitor, and keep an eye on it throughout the following steps.
    1. On Linux, this is probably called "System Monitor."
    1. On macOS, this is called "Activity Monitor."
    1. On Windows, this is probably called "Process Manager" or possibly "Process Explorer."
1. If you have Firefox open already, make sure Firefox is closed before continuing to avoid confusion.
1. Open Tor Browser.
1. Note that two new processes are created -- one for Firefox (Tor Browser), and one for Tor (system Tor). The Tor process itself will likely be called simply `tor`, if you are on a Linux-based system, or `tor.real` if you're on a MacOS system.

As we can see, there are separate processes for both Tor and Tor Browser. What to make of this?

Let's revisit the objective of Tor in the first place, which is to allow users to use the Internet anonymously, or else to make connections to the Internet from an otherwise censored location.

#### The `tor` process

The Tor process (`tor` or `tor.real`) that we see is Tor itself. This is the process that provides the [SOCKS proxy](https://en.wikipedia.org/wiki/SOCKS) capability, which allows us access to the anonymizing "[mixnet](https://en.wikipedia.org/wiki/Mix_network)." 

Effectively, the Tor process is the thing that anonymizes the connection your machine is making to another machine elsewhere on the Internet or on Tor's own "[overlay network](https://en.wikipedia.org/wiki/Overlay_network)." An overlay network is just a network that is built on top of another network. In this case, the Tor network is a bunch of servers hosting [Tor relays](https://trac.torproject.org/projects/tor/wiki/TorRelayGuide) of different kinds, which are built "on top of" (meaning, hosted on) the Internet. It's this overlay network that is commonly referred to as "the Dark Web." This monicker refers to its anonymizing nature (it is intended to be a name that contrasts against "the clear web," also known as the regular Internet), and not to any instrinsically nefarious nature, as some documentaries and articles would have you believe.

We should pause here to make it clear that "the" Dark Web, as appears often in the media, is just Tor's overlay network (or at least, it's almost always Tor's network being referred to). But there are in fact many other overlay networks--even similarly anonymizing ones--that are much like Tor's. One example is [The Invisible Internet Project, or I2P](https://geti2p.net/en/). This is simply to say that there is nothing inherently *special* about Tor's network on a technical level, other than its quality: Tor's network was one of the earliest, and remains one of the largest, most well-resourced overlay networks in existence. Its reliability as an anonymizing network as well as an overlay network altogether has been attested to by journalists and whistleblowers living in countries with censored access to the Internet, and even by the [NSA's own documentation](https://archive.org/details/nsa-tor).

#### The Tor Browser process

Tor *Browser*, on the other hand, is simply a modification of the Mozilla [Firefox](https://www.mozilla.org/en-US/firefox/new/) browser, which has been modified by the Tor Project and distributed for Tor users with users' privacy and security as the main focus. While users may run their own Tor process (this is often called a "system Tor") separately, The Tor Browser also comes bundled with Tor, which means that when users run the Tor Browser, a Tor process connected to the Browser begins as well, allowing the user to easily utilize the Tor network simply by activating Tor Browser.

With Tor Browser open and running, and its Tor process running, you've just begun the process of making a Tor connection!

Now, we need to make a connection to someplace else on the Internet. Our connection will be most comprehensible if we have a clear net (normal) Internet connection to compare it to.

> TK-TODO - This part should involve Wireshark analysis.

## Connecting to an authenticated Onion service

> :construction: See [Connecting to an authenticated Onion service](https://github.com/AnarchoTechNYC/meta/wiki/Connecting-to-an-authenticated-Onion-service) for now.

# Discussion

> :construction: TK-TODO

## Additional Tor Infrastructure: Directory Authorities

> :construction: TK-TODO: Flesh this out a bit more.

In addition to [Tor relays](#understanding-tor-circuits-and-relays), there is an additional type of Tor server needed for the Tor network to function, called a *Directory Authority*. This server is distinct from a Tor relay because its primary purpose is to provide other Tor instances with information they can use to construct a Tor circuit for their own traffic. As a Tor user, you will never need to run your own Directory Authority server, but if you want to create your own Tor network, your network will need at least on Directory Authority that you run yourself.

See [Run your own Tor network](https://ritter.vg/blog-run_your_own_tor_network.html) for more information.

# Additional references

> :construction: TK-TODO

1. [Tor Browser support: Connecting to Tor](https://support.torproject.org/connecting/)
