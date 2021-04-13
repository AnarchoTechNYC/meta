# Introduction to Kubernetes

> :construction: TK-TODO

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

> :construction: TK-TODO

# Bill of materials

This folder contains the following files and folders:

* `README.md` - This file.
* `Vagrantfile` - The Vagrant configuration for our lab environment.
* `provision/` - Folder containing provisioning script(s) assisting in bringing up the lab environment.

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

Some portions of this lab are easier to do if you also have the following optional software:

* An X11 window server, such as:
    * on a macOS host, [XQuartz](https://www.xquartz.org/).
    * on a Microsoft Windows host, [xwin](https://x.cygwin.com/) or [VcXsrv](https://sourceforge.net/projects/vcxsrv://sourceforge.net/projects/vcxsrv/).
    * GNU/Linux systems ship X11 support in their Desktop Environments by default.

# Set up

In addition to your laptop or desktop computer, you will need to acquire the following tools.

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

> :construction: TK-TODO

## Introduction

> :construction: TK-TODO

In brief:

1. Explore the cluster a bit. For example, look at a list of all the Nodes:
    ```sh
    kubectl get nodes
    ```
    ```
    NAME           STATUS   ROLES                  AGE   VERSION
    minikube       Ready    control-plane,master   47m   v1.20.2
    minikube-m02   Ready    <none>                 46m   v1.20.2
    ```
1. Learn about [Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) early. Any Kubernetes object can be labelled. Show the Nodes and their labels:
    ```sh
    kubectl get nodes --show-labels
    ```
    Labels are simple key-value pairs, but by convention the keys are often written with a key *prefix* delimeted by a slash (`/`) in order to allow different vendors or projects to use the same label. So a Label tends to look like this:
    ```
    prefix/name=value
    ```
1. You can use Labels to build better views about the resources (objects) in your cluster. Some Labels are already treated specially by convention and show up in the default `kubectl` output. For example, any Label with the `node-role.kubernetes.io` prefix has its name listed in the "ROLES" column shown by default when you invoke `kubectl get nodes`. Any Label can become a new column with the `--label-columns` or `-L` option. For example:
    ```sh
    kubectl get nodes -L kubernetes.io/os -L kubernetes.io/arch
    ```
    ```
    NAME           STATUS   ROLES                  AGE   VERSION   OS      ARCH
    minikube       Ready    control-plane,master   47m   v1.20.2   linux   amd64
    minikube-m02   Ready    <none>                 46m   v1.20.2   linux   amd64
    ```
    Notice that the Labels become columns whose name (but not prefix) are column headings.
1. You can also use Labels to act on a subset of objects in your cluster using the `--selector` or `-l` options. This is called a *label query* and the selector itself is a set of one or more Labels. For example, to `get` only the control plane Node:
    ```sh
    kubectl get nodes -l node-role.kubernetes.io/control-plane
    ```
    ```
    NAME       STATUS   ROLES                  AGE   VERSION
    minikube   Ready    control-plane,master   51m   v1.20.2
    ```
    The label query selector can be combined with the `--label-columns`:
    ```sh
    kubectl get nodes -l node-role.kubernetes.io/control-plane \
        -L kubernetes.io/os -L kubernetes.io/arch
    ```
    ```
    NAME       STATUS   ROLES                  AGE   VERSION   OS      ARCH
    minikube   Ready    control-plane,master   52m   v1.20.2   linux   amd64
    ```
1. Nodes are not the only kind of object in a Kubernetes cluster. Use [the `api-resources` subcommand](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#api-resources) to view a list of all kind of objects the cluster currently knows about:
    ```sh
    kubectl api-resources
    ```
    Note the output produces several columns, including:

    * a "SHORTNAMES" column indicating shorthands. For example `nodes` can be abbreviated as `no` wherever `nodes` would be valid.
    * a "NAMESPACED" column, indicating whether or not the resource is associated with a [Kubernetes Namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/). More on that in a bit. For now, notice that Nodes are *not* namespaced (they show `false` in the NAMESPACED column) but many other resources, like Pods, are.

1. Try viewing the cluster's other objects (Pods, for example):
    ```sh
    kubectl get pods
    ```
    Especially in a new cluster, you might instead receive the message:
    ```
    No resources found in default namespace.
    ```
    This is because, as mentioned, Pods (and any other namespaced resource) are organized into logical groupings called Kubernetes Namespaces. In order to retrieve them, you must be "looking" in the correct Namespace.
1. Kubernetes runs itself in Pods, but organizes its system Pods into a Namespace called `kube-system`. Listing the Pods running in the `kube-system` Namespace is likely to return at least some more interesting results:
    ```sh
    kubectl --namespace kube-system get pods # Long option.
    kubectl -n kube-system get po            # Same thing, but shorter.
    ```
1. Now that you can see some Pods,  get familiar with their labels. Becoming familiar with how a cluster is organized is important for working effectively with the objects it contains. Start with a combination of `--show-labels` and `grep`, for example, followed by various combinations of `--label-columns` and `--selector` invocations.
1. :construction: TODO

# Discussion

> :construction: TK-TODO

# Additional references

> :construction: TK-TODO
