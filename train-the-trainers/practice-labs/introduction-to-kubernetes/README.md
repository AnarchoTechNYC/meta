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

1. Try viewing any of the cluster's other objects (Pods, for example):
    ```sh
    kubectl get pods
    ```
    Especially in a new cluster, you might instead receive the message:
    ```
    No resources found in default namespace.
    ```
    This is because, as mentioned, Pods (and any other namespaced resource) are organized into logical groupings called Kubernetes Namespaces. In order to retrieve them, you must be "looking" in the correct Namespace.
1. Since a Kubernetes Namespace is an API resource just like Nodes (and Pods) are, they can be queried in the same way:
    ```sh
    kubectl get namespace # List all the cluster's Namespaces.
    kubectl get ns        # Same, using API resource shortname.
    ```
    Listing all Namespaces in a cluster you are unfamiliar with is a quick and easy way to get an overview of how its objects are organized at a high level.

    > :beginner: :shield: Namespaces are not security boundaries. Nothing prevents a user with access to the cluster from reaching across Namespaces. The purpose of Namespaces is simply to organize cluster objects into groups so that they are more easily manageable and to provide some scoping of names (similar to Label prefixes) and services (as part of that service's in-cluster DNS name). Never rely on Namespaces for your protection, but do use Namespaces liberally to, for example, group a given user's objects or objects that all serve a similar purpose together. Much like a given folder in a filesystem is used to group files, so too should Namespaces be used to group objects. Similarly, a folder by itself is not a security measures (you might use file permissions for that), and a Namespace by itself is also not a security measure.

1. Kubernetes runs itself in Pods (we'll talk about Pods in detail soon), but organizes its system Pods into a Namespace called `kube-system`. Listing the Pods running in the `kube-system` Namespace is likely to return at least some more interesting results:
    ```sh
    kubectl --namespace kube-system get pods # Long option.
    kubectl -n kube-system get po            # Same thing, but shorter.
    ```
    Now that you can see some Pods, take a moment to get acquainted with their labels. Becoming familiar with how a cluster is organized is important for working effectively with the objects it contains. Start with a combination of `--show-labels` and `grep`, for example, followed by various combinations of `--label-columns` and `--selector` invocations.
1. In addition to listing one kind of object at a time, you can ask for multiple by providing a comma-separated list. For example, most Pods don't exist on their own, but are controlled by (and created by) different kinds of objects such as Deployments or DaemonSets. Let's see if the Pods in the `kube-system` Namespace are related to any of these other kinds of objects by first seeing if those other kinds of objects exist in the Namespace:

    ```sh
    kubectl --namespace kube-system get pods,deployments,daemonsets
    kubectl -n kube-system get po,deploy,ds # Same, using shorthand.
    ```

    Another way to `get` multiple kinds of objects is to ask for the `all` kind of object. This is not really a true API resource type, but rather a conventional keyword that auto-expands to a comma-separated list of common kinds of objects most people want to see in a Namespace most of the time.

    > :beginner: :warning: The `all` keyword does not, in fact, show *all* kinds of objects, which can be a little confusing. It only shows *the most common* kinds of objects. Remember, use the `kubectl api-resources` command to get an exhaustive list of all the kinds of objects you can `get`. Then, use a comma-separated list with `kubectl get` to actually exhaustively list all objects.

    Notice that there are, in fact, Deployments whose name is very similar to the name of some of the Pods. By convention, objects that are created by another resource inherit the name of their parent resource and a suffix of a dash (`-`) followed by an ID (usually some string of letters or, in the case of Pods descended from a StatefulSet resource, a number).

    You might notice that the Pods in the `kube-system` Namespace have not one but two suffixes after the name of the Deployment from which they were spawned. That's because the Deployment itself also didn't create the Pods directly. Instead, the Deployment spawned a ReplicaSet, which then actually created the Pod.

    ```sh
    kubectl -n kube-system get replicaset # Or use shorthand, `rs`.
    ```

1. Every API object that is queryable with the `kubectl` command line client is essentially a data structure that is saved to a database.

    > :beginner: :bulb: In most Kubernetes deployments, this database itself is usually implemented with [etcd](https://etcd.io/), which is a simple key-value store that can itself be run in a highly-available mode inside a Kubernetes cluster. In fact, at least one of the Pods you've seen in the `kube-system` Namespace are running `etcd` in a container!

    In addition to listing those objects with `get`, we can see the data structure of the object itself by `get`ting it in one of a number of various *output formats* with the `--output` or `-o` option. The most common formats are YAML and JSON. Try getting the YAML representation of any Pod.

    ```sh
    kubectl get --output yaml pod $POD_NAME
    ```

# Discussion

> :construction: TK-TODO

# Additional references

> :construction: TK-TODO
