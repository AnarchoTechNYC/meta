# Introduction to Network Sniffing and Scanning

Once upon a time, using a computer simply meant operating that one machine. Today, most uses of a computer (Web browsing, email, gaming, software development, etcetera) actually involve numerous computers cooperating with one another. This cooperation is usually made possible by connecting the computers together, creating a computer *network*.

Despite their name, computer networks are probably already a familiar concept to you, because at their most fundamental level they are analogous to the telephone system. Each device is assigned an address and, in order to communicate across the network, you &ldquo;make a call&rdquo; to that device. Telephone handsets have *telephone numbers*, and Internet-connected computers have *IP addresses*.

When we pare down digital networks to their most vital essentials, what's really happening is similar to a digitized phone call between machines (or sometimes, a machine speaking to itself). Every time your computer loads a Web page, downloads a file, opens an email, or streams a video, your computer has placed one of these Internet &ldquo;phone calls&rdquo; to another computer somewhere else on the network, the other computer answered, and then the two (or more) of them began to &ldquo;speak&rdquo; to one another. This computer-to-computer &ldquo;conversation&rdquo; happens in &ldquo;languages&rdquo; called *network protocols* with names like HTTP (the HyperText Transfer Protocol, more commonly known as the Web), FTP (the File Transfer Protocol), and others, which we can learn to understand by &ldquo;listening&rdquo; to them, just as we can learn to understand a human language after some practice.

In this practice lab, we&rsquo;ll learn how to eavesdrop on what our computers are saying to one another, learn just enough about several common protocols to understand what they might be saying to one another, and finally learn how to find more conversational partners by exploring the vast expanses of the network itself.

# Contents

1. [Objectives](#objectives)
1. [Bill of materials](#bill-of-materials)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
1. [Practice](#practice)
1. [Discussion](#discussion)
1. [Additional references](#additional-references)

# Objectives

When you complete this lab, you will have acquired the following capabilities:

* Create, analyze, and edit packet capture files, which represent the conversations between computers on a network.
* Query various Regional Internet Registries (RIRs) to find information about the operators of a given network.
* Perform host discovery and port scans in order to map network topologies and learn details about connected devices.

# Bill of materials

This folder contains the following files and folders:

* `README.md` - This file.
* `Vagrantfile` - The Vagrant configuration for our lab environment.
* `provision/` - Folder that houses some artifacts for the lab environment. You can safely ignore this folder.

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

Then, bring the virtual machine(s) for the lab online.

**Do this:**

1. Boot both virtual machines needed for the lab:
    ```sh
    vagrant up
    ```

Once both the virtual machines are running, you can continue to the next step.

# Practice

## Exercise 0.1: Understanding basic networking concepts

> Caveat this with, "here we aren't going into packet structures, which is needed to understand how this all works; much as we must understand that a plant comes from a seed."

* IP addresses, external vs. internal
* Logical addresses rather than physical ones
* Visual traceroute

## Exercise 1.1: Finding other machines on the Internet

In order to begin exploring cyberspace, one of our first goals is to locate other machines (otherwise, we won't have explored very much at all). One of the first question then is, how do we *find* these other machines?

The most naïve way of finding other machines would be something like, randomly typing addresses into the domain bar and seeing whether or not you get something. At its most fundamental, network scanning is very much like this, although when we get further into scanning, we'll be dealing mostly with IP addresses rather than with domain names.

> Not sure if this is a good place to get into the distinction between the two, but the phonebook metaphor should probably come in here, especially if the "phonecall" metaphor is going to hold up in the earlier part.

### Intro to `traceroute`

If we're sick of sitting around typing random names, words, and domains into our URL bar, we can try something a little bit more direct.

The Internet, as we said before, is really like a multi-billion-way call between machines. But if two machines are not physically located near one another, or physically connected in some way, they have to reach each other via some other mechanism other than a physical wire or radio connection. The way this is done is very simple, conceptually: computers simply pass messages along from one to the nearest computer, much as how note-passing works in classrooms (and, yes, there is a consideration to be made as to whether or not your message has been intercepted and read, or even changed, by someone in-between; but that'll come later).

The main point is that Internet packets are passed just the same as these messages, and are made to be sent along until they arrive at their specified recipient.

This means that we can actually trace the route of the message by using a utility called `traceroute`.

> Question: How does `traceroute` actually use UDP to trace its procession across the Internet? How does the information retrieved get sent back to the inquirer?

Let's run a `traceroute` right now and see what we can find.

1. Select an endpoint to which you will be tracing the route. This can be any machine, although it usually serves one well to select a machine that is reliably available, such as `google.com`. You can give `traceroute` a domain name or an IP address.
1. Run a `traceroute` (`tracert` on Windows) to that machine. For example:
    ```sh
    traceroute google.com
    ```
1. Now let's examine the results of that command. Most of what you'll probably see in your `traceroute` output is a series of IP addresses, perhaps also some domain names. These machines are the machines your message traversed in order to go from your origin point (where you are) to your destination (if you used `google.com`, this would be some machine that is on the other end of `google.com`.) You may notice some machines with domain names, such as this one, which I got when running a `traceroute google.com` from my location:
    ```
    451be066.cst.lightpath.net (65.19.99.102)  18.839 ms 64.15.4.56 (64.15.4.56)
    ```

This time, rather than guessing randomly where a machine might be by guessing domain names, I've located a machine by following the path my message took.

It looks like that machine is associated with the domain name `lightpath.net`. Let's say we want to find out more about what that is.

## Exercise 1.2: Finding out more who's behind a website

Obviously, from our last steps, one of the most immediate ways to check out a website would be to simply go to that domain. Let's see what happens if we try to visit `http://lightpath.net` in a browser.

And lo and behold, we see that there isn't a *website* at that address. This doesn't mean there isn't a machine there, of course. There are many, many more things on the Internet than just websites. But it means that that there doesn't happen to be one at that URL. Yet, the domain name is still registered. This is a key detail, and one that can be used to discover more about the owner of the machine at that address.

> Talk a little bit more about the paperwork registration of a domain name?

### IANA's Whois database

So, say you want to know more about `lightpath.net`, and there's no website to visit. How else can we get information about it?

One thing we could and probably should try to do is a simple cursory search on the Internet to see if we can find any information about a service with that name or associated with that domain, but this isn't always reliable. Especially with a name like "Lightpath," where there is a good chance that (and actually, in this case, there are) there are other services that have nothing to do with what `lightpath.net` is serving have the same name.

Instead, we will have a better chance of getting authentic informaton by digging into the domain name itself, and any records associated with it.

The simplest way to do this is by querying the [IANA Whois database (Internet Assigned Numbers Authority)](https://www.iana.org/) for the domain.

> More info about IANA.

While IANA provides a nice Web interface for searching this database, we'll prefer to use the commandline utility, which is simply called `whois`.

Using `whois` in its most basic form is as simple as using the command with a domain name as its argument, such as:

```sh
whois google.com
```

Running this command will give us back some information about the registrant of the domain, `google.com`:

```sh
whois google.com
[Querying whois.verisign-grs.com]
[Redirected to whois.markmonitor.com]
[Querying whois.markmonitor.com]
[whois.markmonitor.com]
Domain Name: google.com
Registry Domain ID: 2138514_DOMAIN_COM-VRSN
Registrar WHOIS Server: whois.markmonitor.com
Registrar URL: http://www.markmonitor.com
Updated Date: 2019-09-09T08:39:04-0700
Creation Date: 1997-09-15T00:00:00-0700
Registrar Registration Expiration Date: 2028-09-13T00:00:00-0700
Registrar: MarkMonitor, Inc.
Registrar IANA ID: 292
Registrar Abuse Contact Email: abusecomplaints@markmonitor.com
Registrar Abuse Contact Phone: +1.2083895740
Domain Status: clientUpdateProhibited (https://www.icann.org/epp#clientUpdateProhibited)
Domain Status: clientTransferProhibited (https://www.icann.org/epp#clientTransferProhibited)
Domain Status: clientDeleteProhibited (https://www.icann.org/epp#clientDeleteProhibited)
Domain Status: serverUpdateProhibited (https://www.icann.org/epp#serverUpdateProhibited)
Domain Status: serverTransferProhibited (https://www.icann.org/epp#serverTransferProhibited)
Domain Status: serverDeleteProhibited (https://www.icann.org/epp#serverDeleteProhibited)
Registrant Organization: Google LLC
Registrant State/Province: CA
Registrant Country: US
Admin Organization: Google LLC
Admin State/Province: CA
Admin Country: US
Tech Organization: Google LLC
Tech State/Province: CA
Tech Country: US
Name Server: ns4.google.com
Name Server: ns3.google.com
Name Server: ns2.google.com
Name Server: ns1.google.com
DNSSEC: unsigned
URL of the ICANN WHOIS Data Problem Reporting System: http://wdprs.internic.net/
```

As we can see, from here we can get information such as:

* The "Admin Organization" - Google LLC
* The registry date of the domain - 1997-09-15
* The registrant state and country - CA and US, respectively

Now, let's try asking the same question for `lightpath.net`:

```sh
whois lightpath.net
```

And we'll get similar-looking information:

```
Domain Name: lightpath.net
Registry Domain ID: 4524746_DOMAIN_NET-VRSN
Registrar WHOIS Server: whois.godaddy.com
Registrar URL: http://www.godaddy.com
Updated Date: 2019-08-20T14:56:25Z
Creation Date: 1997-08-21T04:00:00Z
Registrar Registration Expiration Date: 2020-08-20T04:00:00Z
Registrar: GoDaddy.com, LLC
Registrar IANA ID: 146
Registrar Abuse Contact Email: abuse@godaddy.com
Registrar Abuse Contact Phone: +1.4806242505
Domain Status: clientTransferProhibited http://www.icann.org/epp#clientTransferProhibited
Domain Status: clientUpdateProhibited http://www.icann.org/epp#clientUpdateProhibited
Domain Status: clientRenewProhibited http://www.icann.org/epp#clientRenewProhibited
Domain Status: clientDeleteProhibited http://www.icann.org/epp#clientDeleteProhibited
Registrant Organization: Cablevision Systems Corporation
Registrant State/Province: New York
Registrant Country: US
Registrant Email: Select Contact Domain Holder link at https://www.godaddy.com/whois/results.aspx?domain=lightpath.net
Admin Email: Select Contact Domain Holder link at https://www.godaddy.com/whois/results.aspx?domain=lightpath.net
Tech Email: Select Contact Domain Holder link at https://www.godaddy.com/whois/results.aspx?domain=lightpath.net
Name Server: AUTHNS1.CV.NET
Name Server: AUTHNS1.CVNET.COM
DNSSEC: signedDelegation
```

Here, we can see that the registrant organization is "Cablevision Systems Corporation," and they are registered in New York, USA.

* `dig`
* GeoIP tools

## Exercise 1.3: Introducing port scanning

## Exercise 1.4: Scanning an entire IP space with Nmap

## Exercise 1.5: Finding more services

* [censys.io](https://censys.io/)
* [Shodan](https://shodan.io/)

# Discussion

> :construction: TK-TODO

# Additional references

> :construction: TK-TODO
