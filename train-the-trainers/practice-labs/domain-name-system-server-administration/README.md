# Domain Name System Server Administration

> :construction: TK-TODO

# Contents

1. [Objectives](#objectives)
1. [Bill of materials](#bill-of-materials)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
1. [Practice](#practice)
    1. [Introduction](#introduction)
1. [Additional references](#additional-references)

# Objectives

When you complete this lab, you will have acquired the following capabilities:

> :construction: TK-TODO

# Bill of materials

This folder contains the following files and folders:

* `README.md` - This file.
* `Vagrantfile` - The Vagrant configuration for our virtual private cloud.

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

Then, bring the virtual machines for the lab online.

**Do this:**

1. Boot the virtual machines needed for the lab:
    ```sh
    vagrant up
    ```

Once the virtual machines are running, you can continue to the next step.

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

> :construction: TK-TODO

Some notes for a basic outline:

1. Installing BIND (`sudo apt install bind9`) will provide several important things:
    * `bind9.service` systemd service unit, already started and enabled by default,
    * `named` is the actual name server daemon, and,
    * `rndc`, the remote name daemon controller, so you don't have to bounce the `named` process itself.
1. Check that BIND is really running:
    ```sh
    systemctl status bind9.service
    ```

    It should be. You can triple check by looking out what process is bound to your UDP DNS ("domain") port:

    ```
    sudo ss -lup | grep domain
    # (Remember, the services database entry is "domain," not "DNS"! I.e., `getent services domain`)
    ```
1. As long as your client can connect to this port, you should be able to `dig @` it, like `dig @"$server_ip" example.com`.
1. To configure the server, the `bind9` package also provides several very useful helper commands:
    * `named-checkconf` will do a syntax and general sanity check against either the default or a given BIND configuration file. BIND syntax is notoriously arcane and hard to write correctly, so use this command often.
    * `named-checkzone` will double check a given zone file, but you have to tell it what zone to expect.
1. Try adding a new top-level domain as a new zone:
    1. Start by editing the `/etc/bind/named.conf.local` file. You can either add your new zone to this file directly or place your new zone in an `include`d file. Either way, write your zone:
        ```DNS Zone
        zone "example" in # `in` stands for "Internet" and is the default RR class.
        {                 # This brace starts a block of "sub-statements."
            type master;  # Mark the end of EVERY (sub-)statement with a semicolon.
            file "/etc/bind/db.example"; # <- Another semicolon.
        }; # Don't forget that final semicolon to end the `zone` block statement!
        ```

        Newlines are ignored, so this entire zone could also have been written like so:

        ```DNS Zone
        zone "example" in { type master; file "/etc/bind/db.example"; };
        ```

        Notice that all the necessary statement-ending semicolons are present in the same positions.
    1. Remember to check your work by asking `named-checkconf` to verify that things are at least generally correct:
        ```sh
        named-checkconf # Check `/etc/named.conf` and all `include`d files.
        ```
    1. Now that we have a zone called `example`, we need to fill it with *Resource Records (RRs)* by writing them into the zone's data file (defined by the `file` sub-statement in the zone declaration). The RRs we write are essentially the answers we can give to inquisitive clients. It's easiest to copy an existing data file and then edit it rather than writing one from scratch:
        ```sh
        sudo cp /etc/bind/db.empty /etc/bind/db.example
        ```

        In most BIND distrubtions, you should see something like the following file contents:

        ```DNS Zone
        $TTL    86400
        @       IN      SOA     localhost. root.localhost. (
                                        1         ; Serial
                                   604800         ; Refresh
                                    86400         ; Retry
                                  2419200         ; Expire
                                    86400 )       ; Negative Cache TTL
        ;
        @       IN      NS      localhost.
        ```

        Confusingly, note that the zone data file uses a different syntax:
            * In BIND's zone data files, semicolons no longer denote the end of a statement but the start of a comment.
            * Block statements do not exist, and each RR is expected to be written on one line. The above snippet shows two RRs, one of type `SOA` and the other of type `NS`. The `SOA` RR is extended across multiple lines by the use of parenthesis (instead of bracesa,)  grouping lines into the same RR.

        See [BIND 9 Configuration Reference § Zone File](https://bind9.readthedocs.io/en/latest/reference.html#zone-file) for details.

        This will give us a simple blank slate; replace `localhost` with your chosen zone name (`example`) in both RRs.
    1. Use the helper tool `named-checkzone` to see if this is a sensible data file. (Spoiler: it isn't.)
        ```sh
        named-checkzone example db.example
        ```

        You'll see the error:

        ```
        zone example/IN: NS 'example' has no address records (A or AAAA)
        zone example/IN: not loaded due to errors.
        ```

        Add an `A` record to provide the nameserver called `example` with an IP address that can be queried. Here are some details about how BIND zone data files work, syntactically:

        ```DNS Zone
        ; The at-sign (`@`) is a special symbol that means "here." So,
        ; in the root of the `example` zone, the `@` expands to `example.`.
        ;
        ; Since RRs are written as whitespace-separated fields, every RR
        ; must begin at the very left-most (first) column in your data file.

        @    IN    A    192.0.2.1 ; Or whatever IP you want to use here.

                   A    192.0.2.2 ; Since this line begins with a blank,
                                  ; it's assumed to be a continuation of
                                  ; the line above it. This gives us two
                                  ; different IP addresses for the domain.
        ```

        When you're done editing, remember to check your work with `named-checkzone example /etc/bind/db.example`.
    1. Finally, tell `named` to reload the zone data we just edited by using the remote name daemon controller, `rndc`:
        ```sh
        sudo rdnc reconfig
        ```
    1. Now we can query this server for the `example.` domain:
        ```sh
        dig @"$server_ip" example
        ```

        Note that if we make the same query again, the IP addresses that we entered will be returned to us in a new order. This is a simple (and imperfect) form of load balancing. Add another `A` record for practice and watch the replies shift after each request.


# Additional references

> :construction: TK-TODO
