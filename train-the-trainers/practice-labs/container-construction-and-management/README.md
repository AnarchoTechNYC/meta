# Container Construction and Management

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
* `scripts/` - Folder containing some helper scripts for demo/educational purposes.

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

Some preliminary concepts listed in order of age and thus, portability:

1. Changed root directory, i.e., `chroot(8)` - notably, basically any \*nix system will support this. This ensures a contained process (i.e., a "container") only has access to files in its container.
1. [Linux kernel namespaces](https://en.wikipedia.org/wiki/Linux_namespaces#Namespace_kinds). This is Linux-specific, of course. This feature controls what other types of objects (other processes, network interfaces, and so on) the contained process can see.
1. Linux kernel control groups (`cgroup`s), i.e., `cgroups(7)`. Also Linux-specific, and technically optional, but used everywhere for many good reasons. This feature limits the amount or type of resources (memory, CPU, etc.) that a contained process can use.

`chroot`'ing a process means giving that process a view of the filesystem hierarchy such that a chosen directory is its own root directory. Outside of that process, the filesystem still has its original, real root directory. To make a super basic `chroot` environment on either macOS or Linux, a helper script called [`makechroot.sh`](scripts/makechroot.sh) is provided.

These three concepts work together to create a so-called "container," but can be used independently as well. For instance, simply creating a `chroot` environment does not inherently isolate a process from the rest of the system. In this example, we run a `chroot`'ed Bash shell, but then are still able to mount `/proc`:

1. Log in to the Linux virtual machine, if you haven't already:
    ```sh
    vagrant ssh
    ```
1. Run the `makechroot.sh` helper script to create a new `chroot` environment:
    ```sh
    /vagrant/scripts/makechroot.sh
    ```
1. Enter the `chroot` environment as instructed by the helper script. The command will be something like:
    ```sh
    sudo chroot chroot-example* /bin/bash
    ```
1. Explore the `chroot` environment; note the "new root directory". The "isolation," however, is *only* related to the filesystem.
1. Try getting a process listing by using the `ps` command. The command will fail with an error like `Error, do this: mount -t proc proc /proc` because the Linux `ps` command expects to have access to the [`procfs`](https://en.wikipedia.org/wiki/Procfs) pseudo-filesystem mounted at `/proc`.
1. Create the `/proc` directory:
    ```sh
    mkdir /proc
    ```
1. Mount the `proc` filesystem:
    ```sh
    mount -t proc proc /proc
    ```
1. This causes the kernel to populate the `/proc` directory with information about the system's running processes
    * Browse the `/proc` filesystem hierarchy to see information about processes, including those that are outside of the `chroot`'ed environment.
    * The `ps` command now also works; notice, however, that the PID values are very high numbers. This is because we are still using the same `pid` Linux kernel namespace as is being used outside of the `chroot` environment.

So a `chroot` filesystem itself is not sufficient to create what we think of today as a container. To move towards "full containerization," we'll need to limit what the processes with the `chroot`'ed filesystem can see. For this, we turn to namespaces. Namespaces act like groups for certain types of system objects, such as processes.

As you may know, processes on Linux each have a process identifier number, or PID. Every PID is also associated with a PID Namespace, which determines what other processes are visible to it. Only PIDs in the same namespace, or in namespaces descended from their own, can see that the other exists. Like processes, namespaces themselves also have ID numbers and parent ID numbers, creating a namespace tree. The `lsns(8)` command lists namespaces. Run `sudo lsns` to see the `root` user's view of existing namespaces:

```sh
vagrant@ubuntu-bionic:~$ sudo lsns
        NS TYPE   NPROCS   PID USER            COMMAND
4026531835 cgroup     99     1 root            /sbin/init
4026531836 pid        99     1 root            /sbin/init
4026531837 user       99     1 root            /sbin/init
4026531838 uts        99     1 root            /sbin/init
4026531839 ipc        99     1 root            /sbin/init
4026531840 mnt        95     1 root            /sbin/init
4026531861 mnt         1    19 root            kdevtmpfs
4026531993 net        99     1 root            /sbin/init
4026532158 mnt         1   433 root            /lib/systemd/systemd-udevd
4026532160 mnt         1   638 systemd-network /lib/systemd/systemd-networkd
4026532161 mnt         1   653 systemd-resolve /lib/systemd/systemd-resolved
```

You can use `lsns`'s `-t` option to filter the list of namespaces reported to the type of namespace you're interested in. For instance, to view only PID namespaces:

```sh
vagrant@ubuntu-bionic:~$ sudo lsns -t pid
        NS TYPE NPROCS PID USER COMMAND
4026531836 pid      99   1 root /sbin/init
```

When a Linux system starts, it begins with only one PID namespace. All other PID namespaces are descended from this so-called *root PID namespace* or the *initial PID namespace*. This means any process running in the root PID namespace can see all the processes on the entire system, regardless of their own PID namespace.

Let's limit what other processes our minimally contained process can see. To do this we need to run a command within a new PID namespace, rather than having it share the root PID namespace. We use the `unshare(1)` command to do this.

```sh
sudo unshare --pid --fork /bin/bash
```

The above command runs copy the `bash` shell in a new process (i.e., we `--fork`ed) in a new, unshared PID namespace. This will bring you to a new root shell. Run `lsns -t pid` again and you should now see two rather than only one PID namespace:

```sh
root@ubuntu-bionic:/vagrant# lsns -t pid
        NS TYPE NPROCS   PID USER COMMAND
4026531836 pid      97     1 root /sbin/init
4026532175 pid       2  5576 root /bin/bash
```

Lastly, for cgroups, we'll create our own without any additional tooling to understand what they do and how we can interact with them from a very low level.

1. First, as `root`, create a new directory hierarchy to house our new cgroup interface. Each cgroup controller is responsible for a different aspect of system resources, so perhaps `/my_cgroups/cpu` is a good filesystem path to co-mount the `cpu` and `cpuacct` (CPU accounting) cgroup controller interfaces:
    ```sh
    mkdir -p /my_cgroups/cpu
    ```
1. Next, mount the controller interfaces into that directory:
    ```sh
    mount -t cgroup -o cpu,cpuacct cgroup /my_cgroups/cpu
    ```
    Note that the `cgroup` argument in the above `mount` command is somewhat arbitrary, as cgroups don't actually use any physical device.

    Notice also that the directory has been populated by the two controllers with a view of the Linux kernel's relevant control group data:
    ```sh
    ls /my_cgroups/cpu
    ```
    On a system with systemd running, you probably have several directories ending in `.slice`, which are the cgroups underlying the named systemd Slice Units.
1. To make a new control group of our own, we merely need to create a directory for it. The name of the directory becomes the name of the new control group. For example, to create a group named `testgroup`:
    ```sh
    mkdir /my_cgroups/cpu/testgroup
    ```
    Notice that, as before, the cgroup controllers have populated the new control group's directory with the default values, represented as simple files:
    ```sh
    ls /my_cgroups/cpu/testgroup
    ```
1. Resources in control groups are constrained by the limits set in their parent cgroup, along with those resources offered to their sibling cgroups or the rest of the system. To see this in action, we'll need some sibling groups:
    ```sh
    mkdir /my_cgroups/cpu/testgroup{2,3}
    ```
1. Now we can set various values by writing data to the relevant file. For example, to set the relative CPU shares available for allocation by processes in these cgroups, we can write a value to their `cpu.shares` files:
    ```sh
    echo "2048" > /my_cgroups/cpu/testgroup/cpu.shares
    echo "768" > /my_cgroups/cpu/testgroup2/cpu.shares
    echo "256" > /my_cgroups/cpu/testgroup3/cpu.shares
    ```
   None of this will have any effect until we add some existing process to the new cgroups, of course.
1. In a new tab or SSH connection, generate some test load on the system, for example with the following command:
    ```sh
    cat /dev/urandom
    ```
1. While the above load-generating command is running, observe that the unconstrained process eats up as much CPU time as it can by monitoring the system with a utility such as `top(1)`.
1. Repeat the process by starting a second load-generating command and notice the even distribution between processes, as no process is constrained by a cgroup.
1. Write the PIDs of the load-generating commands into their respective cgroup's `tasks` file:
    ```sh
    echo "$A_PID_TO_CONSTRAIN" > /my_cgroups/cpu/testgroup/tasks
    echo "$B_PID_TO_CONSTRAIN" > /my_cgroups/cpu/testgroup2/tasks
    echo "$C_PID_TO_CONSTRAIN" > /my_cgroups/cpu/testgroup3/tasks
    ```
1. Observe the system again with a utility such as `top(1)` and notice that the processes are now constrained in direct proportion to the value written to their control group's `cpu.shares` file relative to each other.

The above demonstrates a very manual way of interfacing with Linux kernel control groups. More sophisticated tooling exists, including the systemd Slice facilities (and its suite of commands such as `systemd-cgls` to list control groups, and `systemd-cgtop` to monitor control group resource usage), and of course fully fledged container porcelain like Docker. This is how control groups make up the foundation of Kubernetes Pod resource requests and limits, too.

# Additional references

> :construction: TK-TODO
