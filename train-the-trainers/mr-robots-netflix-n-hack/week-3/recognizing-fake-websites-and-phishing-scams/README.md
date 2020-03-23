# Recognizing fake websites and phishing scams

In this exercise we will create a fake version of a popular website's login page (a *[phishing](https://simple.wikipedia.org/wiki/Phishing) site*) in order to trick an unsuspecting user into giving us their username and password combination for that website. We will then be able to impersonate that user to the website, gaining access to their account. Our goal is to more quickly recognize the signs of a malicious website so that we sensitize ourselves to any red flags or warnings we experience while browsing the Web.

1. [Objectives](#objectives)
1. [Scenario](#scenario)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
1. [Practice](#practice)
    1. [Introduction](#introduction)
    1. [Components of a Web-based phishing attack](#components-of-a-web-based-phishing-attack)
        1. [Bait](#bait)
            1. [Email bait](#email-bait)
            1. [Text message bait](#text-message-bait)
            1. [Social media message bait](#social-media-message-bait)
            1. [Other types of phishing bait](#other-types-of-phishing-bait)
        1. [Look-alike Web site](#look-alike-web-site)
        1. [Command and Control server](#command-and-control-server)
    1. [Distinguishing Web browser chrome from remote content](#distinguishing-web-browser-chrome-from-remote-content)
    1. [Spoofable parts of Web browser chrome](#spoofable-parts-of-web-browser-chrome)
        1. [Title bar](#title-bar)
        1. [Status bar](#status-bar)
        1. [Address bar](#address-bar)
        1. [Lock icon](#lock-icon)
        1. [TLS certificate subject information](#tls-certificate-subject-information)
    1. [Checking TLS certificate fingerprints](#checking-tls-certificate-fingerprints)
    1. [Crafting a look-alike Web site](#crafting-a-look-alike-web-site)
        1. [Coding from scratch](#coding-from-scratch)
        1. [Mirroring existing sites with `wget`](#mirroring-existing-sites-with-wget)
        1. [Using a reverse proxy](#using-a-reverse-proxy)
    1. [Publishing phishing sites on the Web](#publishing-phishing-sites-on-the-web)
    1. [Receiving POST-backs from lured users](#receiving-post-backs-from-lured-users)
    1. [Automating the attack](#automating-the-attack)
    1. [Making the bait](#making-the-bait)
1. [Discussion](#discussion)
    1. [Implementing additional defensive measures](#implementing-additional-defensive-measures)
        1. [Be careful where you click](#be-careful-where-you-click)
        1. [Harden log in](#harden-log-in)
            1. [Use a password manager](#use-a-password-manager)
            1. [Use a hardware U2F-conformant security key](#use-a-hardware-u2f-conformant-security-key)
            1. [Use Secure Quick Reliable Login (SQRL)](#use-secure-quick-reliable-login-sqrl)
        1. [Validate endpoint and message authenticity](#validate-endpoint-and-message-authenticity)
            1. [Enable HTTPS Everywhere's "EASE mode"](#enable-https-everywheres-ease-mode)
            1. [Use Signal and verify your contact's Safety Numbers](#use-signal-and-verify-your-contacts-safety-numbers)
            1. [Require email be signed with PGP keys or S/MIME certificates](#require-email-be-signed-with-pgp-keys-or-smime-certificates)
    1. [Leveraging current events in phishing bait](#leveraging-current-events-in-phishing-bait)
    1. [Spear-phishing](#spear-phishing)
    1. [Reverse proxies useful for phishing attacks](#reverse-proxies-useful-for-phishing-attacks)
    1. [Web address (URL) obfuscation techniques](#web-address-url-obfuscation-techniques)
        1. [Registering look-alike domain names](#registering-look-alike-domain-names)
            1. [Domain misspellings and pluralizations](#domain-misspellings-and-pluralizations)
            1. [Using alternate character sets](#using-alternate-character-sets)
            1. [Using IRIs for IDN homograph attacks](#using-iris-for-idn-homograph-attacks)
        1. [Using subdomains of look-alike domain names](#using-subdomains-of-look-alike-domain-names)
        1. [Using URL shorteners](#using-url-shorteners)
        1. [Spoofing DNS](#spoofing-dns)
    1. [Obtaining TLS certificates for phishing attacks](#obtaining-tls-certificates-for-phishing-attacks)
        1. [Generating your own TLS certificate](#generating-your-own-tls-certificate)
        1. [Using the Automated Certificate Management Environment (ACME)](#using-the-automated-certificate-management-environment-acme)
        1. [Tricking a legitimiate Certificate Authority to issue you a new certificate](#tricking-a-legitimate-certificate-authority-to-issue-you-a-new-certificate)
        1. [Stealing authentic certificates from target sites](#stealing-authentic-certificates-from-target-sites)
    1. [Auditing your device's root certificate store](#auditing-your-devices-root-certificate-store)
    1. [Monitoring the Certificate Transparency Log (CTL) for phishing attacks](#monitoring-the-certificate-transparency-log-ctl-for-phishing-attacks)
    1. [Command and Control (C2) infrastructures for large-scale phishing campaigns](#command-and-control-c2-infrastructures-for-large-scale-phishing-campaigns)
    1. [Insufficient defensive measures](#insufficient-defensive-measures)
        1. [Two-factor authentication (2FA)](#two-factor-authentication-2fa)
        1. [Web server security headers](#web-server-security-headers)
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

## Components of a Web-based phishing attack

> :construction: TK-TODO

### Bait

> :construction: TK-TODO

#### Email bait

> :construction: TK-TODO

#### Text message bait

> :construction: TK-TODO

#### Social media message bait

> :construction: TK-TODO

#### Other types of phishing bait

> :construction: TK-TODO

### Look-alike Web site

> :construction: TK-TODO

### Command and Control server

> :construction: TK-TODO

## Distinguishing Web browser chrome from remote content

> :construction: TK-TODO

## Spoofable parts of Web browser chrome

> :construction: TK-TODO

### Title bar

> :construction: TK-TODO

### Status bar

> :construction: TK-TODO

### Address bar

> :construction: TK-TODO

### Lock icon

> :construction: TK-TODO

### TLS certificate subject information

> :construction: TK-TODO

## Checking TLS certificate fingerprints

> :construction: TK-TODO
>
> In brief, this is no longer something only "paranoid" users should do. One easy verification utility is the [crt.sh](https://crt.sh/) certificate search service.
>
> See, for example, the [Kazakhstan national requirement to install a trusted root certificate](https://en.wikipedia.org/wiki/Kazakhstan_man-in-the-middle_attack) ([earlier reporting](https://thehackernews.com/2019/07/kazakhstan-https-security-certificate.html)).
>
> For more information, see the [§ Auditing your device's root certificate store](#auditing-your-devices-root-certificate-store) discussion section, below.

## Crafting a look-alike Web site

> :construction: TK-TODO

### Coding from scratch

> :construction: TK-TODO

### Mirroring existing sites with `wget`

> :construction: TK-TODO

### Using a reverse proxy

There is one other popular, more modern method you can use to create your look-alike Web site that deserves a mention: using a reverse proxy. Although we won't spend too much time exploring this method, it's important to be aware that specialized reverse proxies can be used in phishing attacks because they are capable of defeating common forms of two-factor authentication (2FA). Instead of simply intercepting your user name and password, these tools intercept both your username/password pair *and* the additional, secondary one-time password sent to you via text message or generated using a 2FA app such as Google Athenticator or Authy when you try to log in.

This set of attacker tools are no more difficult to use than the ones we'll be using in this exercise, but they do often require a little bit of extra infrastructure setup, which is why we'll leave using them as an exercise to the reader. For more information on using reverse proxies to mount phishing attacks, refer to the [Reverse proxies useful for phishing attacks](#reverse-proxies-useful-for-phishing-attacks) discussion section, below. Similarly, refer to the [Insufficient defensive measures: Two-factor authentication (2FA)](#two-factor-authentication-2fa) discussion section for more information on how two-factor authentication works and why it won't stop these more sophisticated phishing attacks using specialized reverse proxy frameworks.

## Publishing phishing sites on the Web

> :construction: TK-TODO

## Receiving POST-backs from lured users

> :construction: TK-TODO

## Automating the attack

> :construction: TK-TODO - This needs to be fleshed out a bit more but, for now, the basic process is:

Site cloning is a form of credential harvesting:

1. Launch the Social Engineer's Toolkit:
    ```sh
    sudo ./setoolkit
    ```
1. Choose the "Social-Engineering Attacks" item from the main menu, option number `1`.
1. Choose the "Website Attack Vectors" item from the submenu, option number `2`.
1. Choose the "Credential Harvester Attack Method" item from the submenu, option number `3`.
1. Choose the "Site Cloner" method, option number `2`.
1. Enter the IP address of the cloned Web form's HTTP POST location (the form's `action` attribute value). This should be the public IP address of your server. (Choose the automatically detected IP address by pressing `Enter`.)
1. Enter the URL of the site to clone. For example, `https://www.facebook.com/`

## Making the bait

> :construction: TK-TODO

# Discussion

> :construction: TK-TODO

## Implementing additional defensive measures

> :construction: TK-TODO

### Be careful where you click

> :construction: TK-TODO

### Harden log in

> :construction: TK-TODO

#### Use a password manager

> :construction: TK-TODO

#### Use a hardware U2F-conformant security key

> :construction: TK-TODO
>
> Much like a password manager, the U2F standard programmatically checks the domain of the destination server. It also authenticates using public-key crypto instead of a password, but just programmatically checking the origin server is enough to prove the point to most users.
>
> Note that, like a password manager, this *practically* reduces the possibility of phishing attacks succeeding, but it is not immune from cases where the following conditions are all true:
>
> * attackers have stolen the site's U2F private keys for a given user.
> * DNS spoofing is in effect.
>
> Then again, if all the above conditions are all true, the site probably already has a much bigger problem than being having its users phished. :\
>
> For this reason, U2F hardware tokens are considered the strongest defense against phishing. Unfortunately, due to the cost and complexity of implementing this scheme, it is not typically available to organizations of smaller size or shallower pockets. For them, e.g., non-profits running single-server WordPress-powered sites, the recommendation is to adopt SQRL, which is free and easy.

#### Use Secure Quick Reliable Login (SQRL)

> :construction: TK-TODO
>
> In brief, the Secure Quick Reliable Login (SQRL) is a relatively new mechanism that completely replaces username/password pairs with public-key cryptography for Web site login much in the same way that sysadmins have been using for decades with, e.g., passwordless login to SSH servers using SSH keys. In this system, the domain name of the origin server is part of the mathematics that derive the user's public-facing identity, which means that look-alike web sites will be presented with a different identity than the authentic (innocent) Web site.
>
> Note that, like a password manager and the U2F case, SQRL *practically* reduces the possibility of phishing attacks succeeding, but it is not immune from cases where the following conditions are all true:
>
> * DNS spoofing is in effect.
> * Both the SQRL login agent and the login initiator (Web browser) share the same public IP address from the perspective of the targeted (innocent) Web site. In this situation, SQRL's MITM detection (same IP address check) is satisfied.
>
> While there are ways to arrange for this situation to occur, it is a *significantly* higher bar for an attacker to clear. Thanks to that, coupled with the ease with which SQRL can be implemented by extremely under-resourced organizations along with its strong identity protection guarantees (i.e., doing away with usernames and password pairs completely), we consider it a worthwhile anti-phishing investment.
>
> For more details, see [How SQRL Can Thwart Phishing Attacks](https://www.grc.com/sqrl/phishing.htm). Useful SQRL resources:
>
> * [SQRL Login plugin for WordPress plugin](https://wordpress.org/plugins/sqrl-login/)

### Validate endpoint and message authenticity

> :construction: TK-TODO
>
> This category of phishing mitigations strengthening the identity guarantees of the person or website with which you are communicating. Note, importantly, that an authentic message can still be a phishing message if the sender's identity has been compromised. However, as this presents a much higher bar for an attacker to clear, and makes mass-phishing campaigns far less feasible, authenticating the source of your messages is a great way to dramatically reduce the liklihood both of being caught by an opportunitistically-motivated attacker as well as increasing the liklihood of noticing that something is amiss in the first place when reading messages you receive.
>
> Chief among these are TLS certificate checking, mentioned earlier, but there are additional identity verification methods you should know about and use to protect yourself and your team from phishing attacks.

#### Enable HTTPS Everywhere's "EASE mode"

> :construction: TK-TODO
>
> The [HTTPS Everywhere](https://www.eff.org/https-everywhere) add-on's "Encrypt All Sites Eligible" (EASE) mode in the HTTPS Everywhere user interface. This helps mitigate "[Client Domain Hooking](https://blog.duszynski.eu/client-domain-hooking-in-practice/)" by helping the user prevent *all* Web requests that are not secured with TLS. It only takes one non-HTTPS (HTTP-only) request to redirect a victim browser for the remainder of their browsing session.

#### Use Signal and verify your contact's Safety Numbers

> :construction: TK-TODO

#### Require email be signed with PGP keys or S/MIME certificates

> :construction: TK-TODO
>
> For example, use the [WP PGP Encrypted Emails plugin](https://wordpress.org/plugins/wp-pgp-encrypted-emails/) for your WordPress site to ensure that automated email sent by your Web site can be provably authenticated as the source of the email you receive claiming to be from your Web site. This makes it possible to authenticate "password reset" emails and other critical communications.

## Leveraging current events in phishing bait

> :construction: TK-TODO

## Spear-phishing

> :construction: TK-TODO

## Reverse proxies useful for phishing attacks

> :construction: TK-TODO
>
> Quick mentions of [Evilginx2](https://github.com/kgretzky/evilginx2), [Modlishka](https://github.com/drk1wi/Modlishka), etc. These are reverse proxies that do not require phishing pages to be crafted as look-alike sites through mirroring, site cloning, or manual editing. Rather, they act as application-level ("layer 7") shims that translate domain names, DNS queries, and more originally destined to the original site into requests for resources at the fraudulent phishing domain.

## Web address (URL) obfuscation techniques

> :construction: TK-TODO

### Registering look-alike domain names

> :construction: TK-TODO

#### Domain misspellings and pluralizations

> :construction: TK-TODO

#### Using alternate character sets

> :construction: TK-TODO

#### Using IRIs for IDN homograph attacks

> :construction: TK-TODO

### Using subdomains of look-alike domain names

> :construction: TK-TODO

### Using URL shorteners

> :construction: TK-TODO

### Spoofing DNS

> :construction: TK-TODO

## Obtaining TLS certificates for phishing attacks

> :construction: TK-TODO

### Generating your own TLS certificate

> :construction: TK-TODO

### Using the Automated Certificate Management Environment (ACME)

> :construction: TK-TODO

### Tricking a legitimiate Certificate Authority to issue you a new certificate

> :construction: TK-TODO

### Stealing authentic certificates from target sites

> :construction: TK-TODO

## Auditing your device's root certificate store

> :construction: TK-TODO

## Monitoring the Certificate Transparency Log (CTL) for phishing attacks

> :construction: TK-TODO
>
> See [How to start catching phishermen before they catch you](https://techlearningcollective.com/2019/11/05/how-to-catch-the-phishermen-before-they-catch-you.html) on the Tech Learning Collective blog for now.

## Command and Control (C2) infrastructures for large-scale phishing campaigns

> :construction: TK-TODO

## Insufficient defensive measures

> :construction: TK-TODO

## Two-factor authentication (2FA)

> :construction: TK-TODO
>
> A lot of people think enabling 2FA (like a text message with a login code, a TOTP-based authenticator such as Google Authenticator or Authy) is enough to stop phishing but, while this does raise the bar for attackers, there is nothing inherent in 2FA that addresses phishing in the first place. Automated phishing tools like [Modlishka](https://github.com/drk1wi/Modlishka) simply intercept the one-time password as the user enters it, same as they do with the user's own password.
>
> See, for example [Google: Phishing Attacks That Can Beat Two-Factor Are on the Rise](https://www.pcmag.com/news/google-phishing-attacks-that-can-beat-two-factor-are-on-the-rise).

## Web server security headers

> :construction: TK-TODO
>
> In brief, HSTS, CSP, and CORS headers are all insufficient because:
>
> * HSTS simply demands that the site be visited over HTTPS instead of HTTP. Any phishing site that is served over HTTPS with a trusted TLS certificate will satisfy HSTS requirements.
> * CSP controls the type of content that the browser is permitted to run, but if a victim has navigated to a phishing domain, the attacker's CSP headers are the ones being seen, not the origin server's.
> * CORS controls what resources are permitted to be shared across origins but, as with CSP, this is in the attacker's control if a victim has already been lured to a phishing domain.

# Additional references

> :construction: TK-TODO

According to [Phishing.org](https://phishing.org), the term "phishing" been in use since approximately 1996:

> "According to Internet records, the first time that the term 'phishing' was used and recorded was on January 2, 1996. The mention occurred in a Usenet newsgroup called AOHell. It is fitting that it was made there too; America Online is where the first rumblings of what would become a major criminal issue would take place."

Since then, it has quickly become one of, if not the single most popular kind of cyber attack. In part, this is because it has become so easy to do over the last two decades. Plus, phishing works primarily on a security vulnerability that is notoriously difficult to patch: human fallibility.

In 2019, according to [Software-As-A-Service provider Retrust](https://retruster.com/blog/2019-phishing-and-email-fraud-statistics.html), phishing attempts have grown 65% in the last year, and account for a whopping 90% of all reported data breaches, while 76% of businesses reported being a victim of a phishing attack in the last year.

Business Email Compromise (BEC) scams cost over $12 billion dollars in business losses [according to the FBI](https://www.pymnts.com/news/b2b-payments/2018/fbi-business-email-scam-fraud-phishing/). As for phishing websites, Webroot reports that [nearly 1.5m new phishing sites are created each month](https://www.webroot.com/us/en/about/press-room/releases/nearly-15-million-new-phishing-sites).

