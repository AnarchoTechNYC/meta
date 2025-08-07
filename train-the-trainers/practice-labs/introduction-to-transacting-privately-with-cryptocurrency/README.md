# Introduction to Transacting Privately with Cryptocurrency

The advent of digitally securable currencies, known as *cryptocurrency*, heralded a watershed moment for what was still a young Internet of the time. It happened in 2009 with the formal announcement of the first official release of software called *Bitcoin*. The notion of securing a financial system using the awesome power of modern cryptography has some obvious benefits, such as eliminating certain classes of fraud and abuse, but it comes with massive implications that variously both appeal to and threaten everyone who needs to participate in such a system. 

While Bitcoin remains one of the most important cryptocurrencies today, it was not initially designed for financial privacy. In many ways, the Bitcoin software was similar to other networked software applications of its day: it had a peer-to-peer (P2P) architecture where anyone who ran an instance of the program, called *Bitcoin Core*, would connect to other instances of the same software in order to transmit and receive data from them that, eventually, all users would share.

This sharing of data meant that every single user of the Bitcoin software who joined the network would eventually have the exact same view of the data in the network. Since everyone on the network shared all the data of the network, everything anyone did on the network was visible to everyone else on the network at any time. And since valid transactions were always ever appended to, never deleted, anything anyone ever did on the network remained enshrined in the network's account of its own history for as long as at least one copy of the network's data survived.

For certain use cases requiring transparency, such as auditing non-profit or government revenues and expenses, such a system makes a lot of sense. But there are many situations in which publicizing financial dealings this way poses serious risks to life or liberty for all sorts of individuals and groups of people.

Enter *privacy coins*, a newer class of cryptocurrencies whose technology can obscure or even fully encrypt all parts of a cryptocurrency transaction without compromising the same digitally securable methods as originally offered by Bitcoin. Effective privacy coins such as *Zcash* and *Monero* have been incredibly popular among online communities where financial privacy is key to survival. And as centralized fiat payment processors like credit card companies or digital payment apps increasingly restrict the sorts of transactions they permit their own networks be used for, it becomes increasingly important to understand how such privacy coins offer financial independence and protection from corporate or State surveillance.

In this practice lab, you will learn enough about cryptocurrencies to make use of both transparent (non-private) and opaque (private) cryptocurrencies for buying, selling, or trading anything you can find a buyer, seller, or trading partner for. In the process, we'll gain exposure to some cryptocurrency analytics tools, called *block explorers*, to show you how you might be observed when transacting on the non-private, transparent ledger systems like Bitcoin, debunking privacy myths along the way. Although familiarity with some basic computer operation skills will be helpful (using a smartphone app, a Web browser, copy and paste, and so on), we try to present the material in a way that even someone who has never touched cryptocurrency before will be able to benefit.

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

* The ability to receive and send monetary funds in a private and discreet manner using a cryptocurrency "wallet" application.
* The ability to anonymously convert ("exchange" or "swap") otherwise incompatible cryptocurrencies for one another.
* THe ability to purchase goods and services without the cryptocurrency transaction itself revealing unnecessary information about you.
* An understanding of how to assess "coinflow" analytics and observe other people's transactions on transparent blockchains.

# Bill of materials

This folder contains the following files and folders:

* `README.md` - This file.

# Prerequisites

To perform this lab, you must have:

* A smartphone running any modern version of:
    * Android,
    * Apple iOS (such as an iPhone or iPad).
* A computer running any modern version of:
    * Windows,
    * macOS, or
    * any flavor of the GNU/Linux operating system.
* An active Internet connection.

# Set up

In addition to your smartphone and laptop or desktop computer, you will need to acquire the following tools.

On your smartphone, you will need the following wallets:

* [Zashi](https://electriccoin.co/zashi/), for Zcash transactions
* [Cake Wallet](https://cakewallet.com/), for Monero and BitCoin transactions, or
* [Edge Wallet](https://edge.app/), for Monero and BitCoin transactions.

For educational purposes, the authors recommend acquiring all three.

On your laptop or desktop computer, for maximum privacy, you will also need:

* [Tor Browser](https://www.torproject.org/download/)

Follow the above links. Then download and install the appropriate software packages for your operating system. The installation processes should be familiar, since they are performed in the same way as for any other software application that runs on your operating system.

## Zashi installation on Android

> :construction: TODO

## Zashi installation on Apple iOS

> :construction: TODO

## Cake Wallet installation on Android

> :construction: TODO

## Cake Wallet installation on Apple iOS

> :construction: TODO

## Edge Wallet installation on Android

> :construction: TODO

## Edge Wallet installation on Apple iOS

> :construction: TODO

## Tor Browser installation on Windows

> :construction: TODO

## Tor Browser installation on macOS

> :construction: TODO

## Tor Browser installation on GNU/Linux

> :construction: TODO

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

The Bitcoin project was famously spearheaded by a mysterious entity named Satoshi Nakamoto, who remains anonymous to this day; no one knows whether Satoshi Nakamoto is a single individual or a group of people. What is known is that the Bitcoin software combined several old ideas in a novel way and, in so doing, birthed the possibility for an economic revolution unlike anything the world had seen before: cryptographically secure money.

Rather than merely trust one another, each individual node in the network that ran a complete copy of the Bitcoin software was programmed to *cryptographically validate* every incoming message, called a *transaction* in Bitcoin's parlance, ensuring it met certain criteria. If the transaction's math literally didn't add up, it would be discarded and ignored.

Prior to Bitcoin, money was susceptible to certain kinds of manipulation in the physical world. When gold was considered the equivalent of money, discovering veins of gold in gold mines or panhandling in rivers meant literally finding more money in the world. Later, when the value of legally binding tender like the US Dollar was disassociated from the value of gold on April 20<sup>th</sup>, 1933, governments could simply create more money on demand by printing more of it and declaring it valid. But with Bitcoin, the supply of money in circulation, known as metaphorical "coins," was mathematically fixed by an algorithm computed each and every time any transaction on the network was tested for validity.

Theoretically, this meant that anyone who ran the Bitcoin software could absolutely trust that a financial transaction would provide exactly and only the precise value they expected it to. But it also meant that such transactions would never validate if they included counterfeit coinage, promising to eliminate a whole category of financial fraud.

To use a cryptocurrency and access its network yourself, you need special software designed to interact with the specific cryptocurrency you want to use. Since we'll be concerning ourselves primarily with making transactions, rather than ensuring the validity and stability of the network, we'll use a certain subcategory of cryptocurrency software called *wallet apps* (or just "*wallets*" for short). Let's get you a wallet now.

### Your first cryptocurrency wallet

A *wallet*, *wallet app*, or *crypto wallet* is simply a software program or application that you 

TK-TODO

# Discussion

> :construction: TK-TODO

# Additional references

> :construction: TK-TODO
