# Secretly sharing files with OnionShare and Tor Browser

In this exercise we will create a temporary (ephemeral) *Darknet* Website called an *Onion site* using the Tor anonymity system. We will use our Onion site to secretly transfer a "sensitive" file to a friend. Our goal is to successfully give our friend a copy of the sensitive file without exposing so much as *the fact that* we have even transferred the file in the first place.

Essentially, we will be creating a kind of *digital [dead drop](https://en.wikipedia.org/wiki/Dead_drop)*.

1. [Objectives](#objectives)
1. [Scenario](#scenario)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
1. [Practice](#practice)
    * [Sender steps](#sender-steps)
    * [Receiver steps](#receiver-steps)
1. [Discussion](#discussion)
1. [Additional references](#additional-references)

# Objectives

When you complete this exercise, you will have acquired the following capabilities:

* The ability to share files without revealing your location, whether your own physical ("real world") location or your computer's logical ("Internet address") location.
* The ability to transfer file(s) without relying on corporate providers such as Google, Facebook, or Microsoft; no usernames or account passwords to remember.
* The ability to share files even if you are located behind restrictive firewalls or censored networks such as school, library, or employment networks.

# Scenario

[You are part of the Rebel Alliance (and a traitor)!](https://www.youtube.com/watch?v=2XOzyBQ594E) In order to avoid certain defeat at the hands of The Empire, you must transmit the Death Star plans to a friend of yours, a fellow resistance fighter, whose contact information you already have. However, if you are observed communicating with your friend, you will both be arrested and charged with conspiracy to commit treason against The Emperor.

Your mission is to arrange for the secret transfer of the Death Star plans from your computer to their computer, so that they may deliver the plans to Alliance Headquarters.

# Prerequisites

To participate in this exercise, you must have:

* A friend! :) (You can also do this exercise yourself by role-playing both the sender and receiver portions, but everything is more fun with friends.)
* A computer running any modern version of:
    * Windows,
    * macOS, or
    * any flavor of the GNU/Linux operating system.
* An active Internet connection. (The Internet connection may be censored or surveilled, such as that on a public Wi-Fi network or at an institutional facility such as a public library. In fact, it likely is!)

# Set up

In addition to your laptop or desktop computer and an active Internet connection, you will need to acquire (at least) two tools:

* [Tor Browser](https://www.torproject.org/download/download-easy.html)
* [OnionShare](https://onionshare.org/)

Follow the above links. Then download and install the appropriate software package for your operating system.

# Practice

Agree on roles for yourself and your friend. One of you will be the sender, the other will be the receiver. Then follow the steps below for your role:

## Sender steps

As the sender, you must prepare an Onion site able to transmit the files to the receiver when they initiate the transfer.

* **[Download the Death Star plans](Death_Star_Owner%27s_Technical_Manual_blueprints.jpg)**, if you do not already have them. (Pretend that you did.)

**Do this:**

1. Launch the Tor Browser. (Usually, this is as simple as double-clicking its icon.)
1. Click on the *Connect* button when presented with the *Tor Network Settings* dialogue screen:  
   ![Screenshot of the Tor Network Settings screen on Windows.](https://web.archive.org/web/20170303022410/http://core0.staticworld.net/images/article/2014/09/firsttimetor-100449209-orig.png)  
   This will connect your computer to the Tor anonymity network. It also provides the service your computer will use to set up the Onion site in the following steps.
1. After Tor has successfully connected, you will see a Web browser window open and display (something that looks similar to) the following page:  
   ![Screenshot of Tor Browser's successful connection startup screen.](https://web.archive.org/web/20170303022638/http://core0.staticworld.net/images/article/2014/09/torbrowserhero-100449223-orig.png)
1. Launch OnionShare. (Usually, this is as simple as double-clicking its icon.) You will be presented with the main OnionShare window:  
   ![Screenshot of main OnionShare window on Windows.](https://web.archive.org/web/20180427184305/http://temp.run/images/onionshare/onionshare_home_screen.png)
1. Drag-and-drop the Death Star plans into the main OnionShare window, or click either the *Add Files* or *Add Folder* button and browse to the location of the Death Star plans on your computer to add them to your soon-to-be Onion site:  
   ![Screenshot of main OnionShare window with Death Star Plans ready to be shared.](https://web.archive.org/web/20180427193254if_/https://user-images.githubusercontent.com/7214911/39380175-a3b3d6ea-4a2b-11e8-814a-84bfe61271e4.png)
1. Click the *Start Sharing* button. Wait a few moments as OnionShare prepares your Onion site.
    * When the Onion site is successfully running, the red indicator light will turn green and the "Start Sharing" button will change to read "Stop Sharing" instead.
    * Additionally, two new buttons will appear ("Copy URL" and "Copy HidServAuth") next to a Web address that will look something like `http://fjqkh7xe7ol4tqws.onion/duct-crock`.
    ![Screenshot of main OnionShare window with Onion service server started sharing Death Star Plans file.](https://web.archive.org/web/20180427193318if_/https://user-images.githubusercontent.com/7214911/39380176-a3c2dfb4-4a2b-11e8-96f1-8f574711354c.png)

Now comes the tricky part! You must find a way to securely, secretly communicate this Web address to your friend. Remember, if you are caught communicating this secret information to your friend, you will spend time in an Imperial detention facility for sure, or worse! This step is intentionally ommited from this exercise; if you are not sure what to do, consult the other exercises in this repository, search the Internet for advice, or ask the facilitator of the workshop if one is available.

1. Once you have safely communicated the location of your secret Onion site to your friend, you must return to the main OnionShare window.
1. Pay close attention to the OnionShare status bar (the very bottom of the OnionShare window).
    * When your friend successfully arrives at your Onion site, you will see the message "Download page loaded" appear.
    * When your friend successfully begins receiving the files, a progress bar will appear and will show the estimated time to completion.
1. You must ensure that this download completes!
    * Do not close OnionShare during this process.
    * Do not close the Tor Browser during this process.
    * Do not interrupt your Internet connection during this process.
    * Do not shut down your computer until the download has completed.

## Receiver steps

As the receiver, you must acquire knowledge of the secret Onion site where the Death Star plans are waiting for you to pick them up.

**Do this:**

1. Launch the Tor Browser. (Usually, this is as simple as double-clicking its icon.)
1. Click on the *Connect* button when presented with the *Tor Network Settings* dialogue screen:  
   ![Screenshot of the Tor Network Settings screen on Windows.](https://web.archive.org/web/20170303022410/http://core0.staticworld.net/images/article/2014/09/firsttimetor-100449209-orig.png)  
   This will connect your computer to the Tor anonymity network.
1. After Tor has successfully connected, you will see a Web browser window open and display (something that looks similar to) the following page:  
   ![Screenshot of Tor Browser's successful connection startup screen.](https://web.archive.org/web/20170303022638/http://core0.staticworld.net/images/article/2014/09/torbrowserhero-100449223-orig.png)

Now comes the tricky part! You must find a way to securely, secretly communicate with your friend to learn the Web address of their Onion site. Remember, if you are caught requesting this secret information from your friend, you will spend time in an Imperial detention facility for sure, or worse! This step is intentionally ommited from this exercise; if you are not sure what to do, consult the other exercises in this repository, search the Internet for advice, or ask the facilitator of the workshop if one is available.

1. Once you have acquired the Onion site's Web address, carefully type it verbatim (or copy-and-paste it) into the location bar of your open Tor Browser, then press the "Go" button or press the Return key. If successful, you should see a page like the following:  
   ![Screenshot of the OnionShare server providin the Death Star plans.](https://web.archive.org/web/20180427193343if_/https://user-images.githubusercontent.com/7214911/39380177-a3d363e8-4a2b-11e8-9d49-eeb1b686185d.png)
1. Click on the blue download link; it will start with "onionshare" and then have some random letters and numbers at the end.
    * OnionShare always packages all files in `.zip` format.
1. After the download is complete, [uncompress the downloaded ZIP file](http://www.computerhope.com/issues/ch000506.htm) and confirm that the Death Star plans are now in your posession.

# Discussion

> :construction: TK-TODO

# Additional references

* [How to use the Tor Browser to surf the Web anonymously](http://www.pcworld.com/article/2686467/how-to-use-the-tor-browser-to-surf-the-web-anonymously.html)
* [OnionShare wiki](https://github.com/micahflee/onionshare/wiki)
