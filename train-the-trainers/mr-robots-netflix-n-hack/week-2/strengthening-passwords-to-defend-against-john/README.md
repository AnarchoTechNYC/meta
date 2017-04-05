# Strengthening Passwords to Defend Against John

In this exercise we will obtain the password of an unsuspecting user by "cracking" the hashed copy of that user's password. Then we will use a password manager to strengthen our own passwords in order to protect ourselves against the same sort of attacks. Our goal is to understand why and how using [password management software](https://en.wikipedia.org/wiki/Password_manager) makes having a digital life both safer and easier at the same time.

In other words, you will perform a *[password cracking](https://en.wikipedia.org/wiki/Password_cracking) attack* and learn how to stop password crackers from cracking your own passwords.

1. [Objectives](#objectives)
1. [Scenario](#scenario)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
    * [John the Ripper installation on Windows](#jtr-installation-on-windows)
    * [John the Ripper installation on macOS](#jtr-installation-on-macos)
    * [John the Ripper installation on GNU/Linux](#jtr-installation-on-gnulinux)
1. [Practice](#practice)
    1. [Introduction](#introduction)
    1. [Sanity check](#sanity-check)
    1. [Crack session preparation](#crack-session-preparation)
    1. [Your first crack](#your-first-crack)
    1. [Better wordlists](#better-wordlists)
    1. [Word mangling rules](#word-mangling-rules)
    1. [Preparing a personally targeted attack](#preparing-a-personally-targeted-attack)
        1. [Writing custom wordlists](#writing-custom-wordlists)
        1. [Writing wordlist rules](#writing-wordlist-rules)
1. [Discussion](#discussion)
    * [Technical errors in the Mr. Robot scene](#technical-errors-in-the-mr-robot-scene)
    * [`passwd` versus `shadow` files](#passwd-versus-shadow-files)
    * [Hash algorithms](#hash-algorithms)
    * [Hash string formats](#hash-string-formats)
    * [Salted versus unsalted hashes](#salted-versus-unsalted-hashes)
    * [Generating custom wordlists automatically](#generating-custom-wordlists-automatically)
1. [Additional references](#additional-references)

# Objectives

When you complete this exercise, you will have acquired the following capabilities:

* The ability to make and use passwords for your user accounts that are practically invincible against many attackers.
* The ability to replace old passwords with strong new passwords easily, on whatever schedule you want.
* The ability to determine other users's original passwords, if theirs are weak, despite sophisticated attempts to protect them.
* The ability to gauge the approximate relative strength of a password using only "the naked eye."

# Scenario

[![Hacking Tyrell Wellick scene, using the `john` password cracker.](https://web.archive.org/web/20161213025246/https://hackertarget.com/mrrobot/wget-shellshock-john.png)](Mr.%20Robot%20S01E02%20-%20Hacking%20Tyrell%20Wellick.mp4?raw=true)

> Hacking Tyrell Wellick, you'd think it'd be tricky but it wasn't. Evil Corp's corporate mail servers? They haven't patched anything since Shellshock. He doesn't even use two-step verification. His password was just his wife's maiden name and Sweden's independence date, `66`. One "six" away from the obvious, but still. This is bad noob practice.

You are Elliot Alderson, ordinary cybersecurity engineer by day, vigilante hacker by night. In order to uncover Evil Corp's next nefarious plot, you must hack into the corporate email account of their Senior Vice President of Technology, Tyrell Wellick. Fortunately for you, Evil Corp's mail servers run a webmail system vulnerable to an exploit called Shellshock, which has enabled you to obtain files listing the usernames and passwords of everyone who uses the system. However, the passwords are obfuscated using a one-way mathematical function called a *hash* (or *digest*).

In order to recover the password, you must "crack" its hashed equivalent, revealing the original. Once cracked, you may impersonate Tyrell Wellick to the Evil Corp mail server by using his username and password to log in as him, thereby gaining access to his emails. Moreover, to make sure that Tyrell Wellick is unable to hack you back, you must set all your online accounts to use "uncrackable" passwords to protect yourself against the very same attack.

# Prerequisites

To participate in this exercise, you must have:

* A computer running any modern version of:
    * Windows,
    * macOS, or
    * any flavor of the GNU/Linux operating system.
* An active Internet connection (for downloading the required tools in the [set up](#set-up) step; you do not need an Internet connection once you have the tools installed).

> :beginner: :computer: This exercise requires the use of a command line, or "terminal." If you don't know what that means, or if you do but you feel intimidated by that, consider spending an hour at [Codecademy's interactive tutorial, "Learn the Command Line"](https://www.codecademy.com/learn/learn-the-command-line) (for macOS or GNU/Linux users) or reviewing [Computer Hope's article, "How to use the Windows command line (DOS)"](http://www.computerhope.com/issues/chusedos.htm) (for Windows users) if you want to get started quickly. You don't need to complete the whole tutorial or article to understand this exercise, but it will dramatically improve your comprehension of this exercise's mechanics. If you want a more thorough but equally gentle introduction to the same material, consider reading (and listening to) [Taming the Terminal](https://www.bartbusschots.ie/s/blog/taming-the-terminal/).

# Set up

In addition to your laptop or desktop computer, you will need to acquire the following tools.

* For cracking Tyrell's password: [John the Ripper password cracker](http://www.openwall.com/john/), often written as *JtR*
* For managing your own passwords: [KeePassX](https://www.keepassx.org/)

There are pre-built versions of KeePassX for both Windows and macOS available for download from the [KeePassX downloads page](https://www.keepassx.org/downloads). For GNU/Linux users, KeePassX is ordinarily provided as a standard software package directly from your operating system's distributor. Use your system's default package manager to install it.

> :bulb: If you already use a different password manager or prefer to choose one of the many different [recommended password managers](https://prism-break.org/en/all/#password-managers), you can still follow along with the overwhelming majority of this exercise. The fundamental features of all password managers are, generally speaking, equivalent to one another. What matters is that you use one, not necessarily which one you use.

There are several different procedures to install John the Ripper available to you. If you're comfortable doing so, you can follow the above link, download JtR's source code, and install the software configuration of your choosing. (See [Beginner's Guide to Installing from Source](http://moi.vonos.net/linux/beginners-installing-from-source/) if you're not comfortable, but want to try that anyway.) The rest of this section will describe more common approaches to installing John the Ripper in a little more detail.

## JtR installation on Windows

Two pre-built Windows versions of John the Ripper are available. One is an "official" build, compiled by the tool's original developers, and the second is a "community-enhanced" build, which bundles (literally) hundreds of additional features written by volunteers into the application itself. For the purposes of this exercise, it does not matter which version you choose to get, although the community-enhanced version is recommended. To install John the Ripper, take the following steps:

**Do this:**

1. Go to [the John the Ripper homepage](http://www.openwall.com/john/).
1. Download the Windows version of your choice. At the time of this writing, these are:
    * [John the Ripper 1.8.0-jumbo-1 community-enhanced version for Windows](http://www.openwall.com/john/j/john180j1w.zip) (recommended)
    * [John the Ripper 1.7.9 official free version for Windows](http://www.openwall.com/john/h/john179w2.zip)
1. Unzip the file. Usually, this is as simple as right-clicking on it and selecting *Extract All* from the context-menu. (See [the Windows Help "Compress and uncompress files (zip files)" article](https://support.microsoft.com/en-us/help/14200/windows-compress-uncompress-zip-files).)
    * This will produce a folder, inside of which is another folder named `run`. Inside *that* folder is a file called `john` (or `john.exe` if your computer is [set to display file extensions](http://www.computerhope.com/issues/ch000573.htm)). That file is the main John the Ripper application. Unlike most Windows applications, this program must be run [using the Windows Command Prompt](http://www.computerhope.com/issues/chusedos.htm); you cannot simply double-click it. However, `john.exe` is now successfully "installed."

## JtR installation on macOS

A pre-built macOS version of John the Ripper is available for modern Apple's Macintosh computers, that is, Macs with an Intel processor. (See [About System Information on your Mac](https://support.apple.com/en-us/HT203001) to learn how to find out what processor your Mac has.) If you have such a Mac, then to install John the Ripper, take the following steps.

**Do this:**

1. Go to [John the Ripper's macOS community-contributed builds page](http://download.openwall.net/pub/projects/john/contrib/macosx/).
1. Download the latest version available. (As of this writing, that is [`john-1.7.9-jumbo-7-macosx-Intel-2.zip`](http://download.openwall.net/pub/projects/john/contrib/macosx/john-1.7.9-jumbo-7-macosx-Intel-2.zip).)
1. Unzip the file. Usually, this is as simple as double-clicking on it.
    * This will produce a folder, inside of which is another folder named `run`. Inside *that* folder is a file called `john`. That file is the main John the Ripper application. Unlike a classic macOS application, this program must be run [using the Terminal](http://guides.macrumors.com/Terminal); you cannot simply double-click it. However, `john` is now successfully "installed."

## JtR installation on GNU/Linux

> :construction: TK-TODO: These instructions are currently missing. Please add them!

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

Recovering passwords is generally accomplished in one of two ways. The approach we'll be taking in this exercise, *offline hash cracking*, is by far the more common of the two. We say it is "offline" because we do it entirely on our own computer, without needing an active network connection, after already acquiring the "hashed" password(s) through some other means.

> :beginner: If you've never encountered a "hash" in this context before, this exercise might seem complex already. Searching the Internet for "hash" probably reveals more pages about cannabis than computer security at first, but adding "computer" to your searches will get you [many](http://www.webopedia.com/TERM/H/hashing.html), [many](http://unixwiz.net/techtips/iguide-crypto-hashes.html), [many](https://en.wikipedia.org/wiki/Hash_function) more [relevant results](http://www.computerhope.com/jargon/h/hashing.htm). Another tip for beginners, especially if you've found the regular Wikipedia article impenetrable, is to check if there is a "simple" version of the Wikipedia page. In this case, you're in luck: the [Simple Wikipedia article for "Cryptographic hash function"](https://simple.wikipedia.org/wiki/Cryptographic_hash_function) is relatively straightforward by comparison.
> 
> In the end, a "hash" in the context of computer security is simply a value that ("cryptographically") represents some other value. The idea, in theory, is that two different original values will never be represented by the same two ultimate values after they have been "hashed," and that it is infeasible to recover the original value from the hashed value. ([Watch these few minutes from "Crypto 101"](https://www.youtube.com/watch?v=3rmCGsCYJF8&t=20m6s) for a further explanation and some pictures depicting this.) In practice, however, weaknesses in cryptographic hash functions (whether by design due to flaws in their algorithm, or by mistakes introduced through their actual implementation) sometimes result in two different values being hashed to the same value. When this happens, the hash function is said to be "cryptographically broken," because if you can hash two different values and get the same resulting value (a situation known as a *hash collision*), then there is little point to the hash from a security perspective in the first place.
> 
> For the purposes of this exercise, we will assume there are no flaws in the hashing algorithm. In reality, this "sanity check" hash value uses a cryptographically broken algorithm called [SHA-1](https://en.wikipedia.org/wiki/SHA-1). To learn more about how SHA-1 is broken, and how to construct a *hash collision attack* yourself, read [Boston Key Party 2017 CTF: Prudentialv2](https://github.com/meitar/CTF/blob/master/2017/BKP/cloud/Prudentialv2/README.md). For more details, see the [Hash algorithms](#hash-algorithms) section in the [Discussion](#discussion), below.

The alternative to offline hash cracking is *online password guessing*. We say it's "online" because it's as simple as repeatedly attempting to log in to an active, remote system, such as an email service or online banking website. Of course, most websites don't allow visitors to try logging in to an account too many times. After some number of failed guesses, they will usually lock out the account. Besides, it would be unbearably slow to have to reload the login page over and over again after each guess. Therein lies the key concept: speed.

A password can, theoretically, be any sequence of characters at all. In practice, many systems place limits on what they consider valid passwords, or limit the length of the password. For instance, many websites require your password to be "between 4 to 12 characters, and must contain only letters, numbers, or punctuation marks," or something like that. The set of possibilities that a given password might be is called a *search space*. Given infinite time, it would be a simple matter of trying every single possibility until one of your guesses is right. This technique is called a *brute force search*. In practice, however, we never have anything close to infinite time. If it took us, say, two hundred years to find Tyrell Wellick's password, we would be long dead, Evil Corp's nefarious plan will surely have gone unopposed, and we have still not even gotten close to infinite time!

This means, to be successful, we only have two techniques available to us:

* Guess more passwords faster.
* Make smarter guesses sooner.

Guessing more passwords faster is pretty intuitive: the faster we can make guesses, the less time it will take to perform an exhaustive, brute-force search. This is simply a function of what computer you have. The better, faster, stronger, more expensive your computers are, the more guesses you can make per second. Making smarter guesses sooner involves much more subtlety, so that's where we'll be focusing the majority of our time in this lab.

## Sanity check

First, let's make sure you successfully installed John the Ripper (JtR) and that its `john` program is working correctly. We'll do this by giving `john` two files. Both files have already been created for you. One file contains a fictional username and hashed password combination. The second file will contain a (correct) "guess" of the un-hashed password. Given these two files, `john` should be able to apply the password guess in the one file to the hashed version of the password in the other file and tell us that the guess is correct.

The file containing the username and hashed password pair is called `sanitycheck.password.txt`. It contains one line that looks like this:

```
fsociety:ced91977849c44fd009ba437c14c1b74f632fae6
```

On the left, at the start of the file, is a username. In this case, that's `fsociety`. Then there is the *field separator* character, a colon (`:`). Finally, there is the *hash value*. That hash is the obfuscated version of the password we need to guess.

The file containing our guesses is called `sanitycheck.wordlist.txt`. It contains four lines and looks like this:

```
randomGuess
alsoWrong
Sup3rs3kr3tP@24431w0rd
someotherword
```

Each guess is written on its own line. We call each guess a *word*, even if there are multiple human-language words on a single line. We call the whole file a *wordlist*, or sometimes a *dictionary* (because it is a "list of words," of course).

When we give the wordlist to `john`, what we're doing is asking `john` to hash each of these "words" one at a time and then compare the resulting hash value to the hash value stored in the password file. When `john` finds a word in the wordlist that hashes to the same hash value as the hashed password, it will tell us that it found a match. When we find a matching value, we say we have "*cracked* the hash." We call this technique a *dictionary attack*.

If `john` is working correctly, we can expect that the third word in the wordlist, `Sup3rs3kr3tP@24431w0rd`, will result in a match. If that guess were missing (as it is in the `sanitycheck.no-crack.wordlist.txt` file), we would expect to see `john` report its failure to find any matches.

To perform the sanity check, we'll use this command invocation on GNU/Linux or macOS systems:

```sh
./john --wordlist=sanitycheck.wordlist.txt sanitycheck.password.txt
```

Windows users will need to reverse the slash, but otherwise can use the same invocation:

```sh
.\john --wordlist=sanitycheck.wordlist.txt sanitycheck.password.txt
```

Breaking this invocation down:

* The first part, `./john` (or `.\john` on Windows), runs the program `john` in the current directory (notated as `./` on GNU/Linux and macOS and `.\` on Windows). The rest of this walkthrough always uses the GNU/Linux and macOS style, so if you're following along on Windows, just remember to reverse the direction of the slash to mean "current directory."
* The next part, i.e., the first [argument](https://bash.cyberciti.biz/guide/Shell_command_line_parameters#What_is_a_command_line_argument.3F), is the `--wordlist` option, which tells JtR to read its guesses from the file given by the value (`=`) of the option, in this case the contents of the file `sanitycheck.wordlist.txt`.
* The final argument, `sanitycheck.password.txt`, is the file containing the hashed passwords we want to crack.

Notice that we did not have to tell John the Ripper what hash algorithm to use. In many cases, it's smart enough to figure that out all on its own! This is one of the reasons JtR is considered an easy tool to use. However, if `john` incorrectly detects the hash format, it will never find a match, since different hash algorithms produce different hash values, even for the same input.

Now, let's practice all this.

**Do this:**

1. Download the [`sanitycheck.password.txt`](sanitycheck.password.txt?raw=true) and [`sanitycheck.wordlist.txt`](sanitycheck.wordlist.txt?raw=true) files and save them in or move them to JtR's `run` folder.
1. Open a command prompt or terminal window and use the `cd` command to navigate to John the Ripper's `run` folder.
1. Invoke `john` as shown above to compare each guess in the wordlist file to the hashed value in the password file.

```sh
$ ./john --wordlist=sanitycheck.wordlist.txt sanitycheck.password.txt
Warning: detected hash type "raw-sha1", but the string is also recognized as "raw-sha1-linkedin"
Use the "--format=raw-sha1-linkedin" option to force loading these as that type instead
Warning: detected hash type "raw-sha1", but the string is also recognized as "raw-sha"
Use the "--format=raw-sha" option to force loading these as that type instead
Warning: detected hash type "raw-sha1", but the string is also recognized as "raw-sha1-ng"
Use the "--format=raw-sha1-ng" option to force loading these as that type instead
Loaded 1 password hash (Raw SHA-1 [128/128 SSE2 intrinsics 4x])
Sup3rs3kr3tP@24431w0rd (fsociety)
guesses: 1  time: 0:00:00:00 DONE (Tue Mar 14 14:18:13 2017)  c/s: 400  trying: randomGuess - someotherword
Use the "--show" option to display all of the cracked passwords reliably
```

Since we did not tell `john` what hashing algorithm to use, the very first thing the program did was make an educated guess about the hash algorithm that was used to produce the hash value in the password file. Its guess is based on the contents of the hash value itself; the hash's length, the characters it contains, and other details can sometimes be used to deduce the hashing algorithm. In this case, `john`'s educated guess ("Raw SHA-1") happens to be correct, and JtR informs us that it will proceed as though we had invoked it with the `--format=raw-sha1` option.

> :beginner: :bulb: We can quiet these "warnings" by telling `john` to use a specific hash algorithm. We do this by passing the `--format` option and setting the option's value to a specific algorithm's name. You can ask `john` for a list of all the algorithm names it knows about by invoking it with no options. This will print some basic help. Look for the `--format` option in that output to read a list of hash format names `john` recognizes.
> 
> In this example, I'm [using a shell's pipe](https://bash.cyberciti.biz/guide/Pipes) (`|`) to send `john`'s help message to [the `grep(1)` command](https://linux.die.net/man/1/grep) on a GNU/Linux system so I can focus on just the fifteen lines of text after (`-A 15`) wherever the `--format` option is described:
> 
> ```sh
> $ ./john | grep -A 15 -- '--format'
> --format=NAME             force hash type NAME: afs bf bfegg bsdi crc32 des
>                           dmd5 dominosec dragonfly3-32 dragonfly3-64
>                           dragonfly4-32 dragonfly4-64 drupal7 dummy dynamic_n
>                           epi episerver gost hdaa hmac-md5 hmac-sha1
>                           hmac-sha224 hmac-sha256 hmac-sha384 hmac-sha512
>                           hmailserver ipb2 keepass keychain krb4 krb5 lm lotus5
>                           md4-gen md5 md5ns mediawiki mozilla mscash mscash2
>                           mschapv2 mskrb5 mssql mssql05 mysql mysql-sha1
>                           nethalflm netlm netlmv2 netntlm netntlmv2 nsldap nt
>                           nt2 odf office oracle oracle11 osc pdf phpass phps
>                           pix-md5 pkzip po pwsafe racf rar raw-md4 raw-md5
>                           raw-md5u raw-sha raw-sha1 raw-sha1-linkedin
>                           raw-sha1-ng raw-sha224 raw-sha256 raw-sha384
>                           raw-sha512 salted-sha1 sapb sapg sha1-gen sha256crypt
>                           sha512crypt sip ssh sybasease trip vnc wbb3 wpapsk
>                           xsha xsha512 zip
> ```
> 
> Depending on the version and configuration of the John the Ripper software package you installed, your copy of `john` may not recognize all of these hash formats, or it may recognize even more than those shown here. Again, the important takeaway is that you need to tell `john` (or hope `john` correctly guesses) the hash algorithm to use when cracking hashes. If you don't get the hash algorithm right, you will never find a match no matter how many guesses you make.

Following the hash format detection warnings, `john` produces a report about what it was able to accomplish. The relevant output snippet is as follows:

```
Loaded 1 password hash (Raw SHA-1 [128/128 SSE2 intrinsics 4x])
Sup3rs3kr3tP@24431w0rd (fsociety)
guesses: 1  time: 0:00:00:00 DONE (Tue Mar 14 14:18:13 2017)  c/s: 400  trying: randomGuess - someotherword
```

Here, `john` informs us that it found one hash in the password file ("`Loaded 1 password hash`"), along with the type of hashing algorithm it suspects (or that we told it) the hash was made with ("`Raw SHA-1`"). On the next line, we see the expected correct guess (`Sup3rs3kr3tP@24431w0rd`), which `john` reports as the plain-text, unobfuscated version of the password associated with the user `fsociety`. Finally, we see the number of *successful* guesses made (`guesses: 1`), the amount of time it took (`time:`), the fact that we have in fact finished trying all guesses loaded from the wordlist (`DONE`), and the time of completion (in this example, shown as `(Tue Mar 14 14:18:13 2017)`). Finally, the current range of password candidates being guessed is reported, shown here as "`trying: randomGuess - someotherword`." Indeed, `randomGuess` was our first guess, listed at the start of our wordlist, and `someotherword` was our last one, listed at the wordlist file's end. Notice that these guesses were attempted in order, from top to bottom. That's important because it means we should place "smarter" guesses, the guesses we think are more likely to successfully crack a hash, nearer to the top of our wordlist, in order to help `john` makes smarter guesses sooner.

> :bulb: There is also some [additional information](http://www.openwall.com/john/doc/FAQ.shtml) in the report. For instance, we're also told that, on this run, `john` is using an [Intel processor feature called SSE2](https://en.wikipedia.org/wiki/SSE2) in an attempt to work as fast as possible. We also see a speed report, shown as "combinations per second" (`c/s`). This metric measures combinations of username and password candidates attempted against each hashed password per second. In our case, with our four guesses and one raw SHA-1 password hash, on my specific hardware, `john` says it can guess passwords at "four hundred combinations per second," although this metric will differ based on what else my computer is doing at the time, the processing power my computer hardware makes available to `john` in the first place, and even what kind of hash algorithm is used because some hash algorithms take much more work to compute than others. There are many ways to benchmark `john`'s speed, and to tune it, in order to optimize the "guess more passwords faster" technique (look into the `--test` option) but, again, we'll be focusing on "making smarter guesses sooner," instead.

Now that we've seen how `john` works when we make a successful guess, let's see what happens when our guesses fail to find the password. This will also demonstrate JtR's "`pot`" file feature.

**Do this:**

1. Download the [`sanitycheck.no-crack.wordlist.txt`](sanitycheck.no-crack.wordlist.txt?raw=true) file and save it in or move it to JtR's `run` folder.
1. Invoke `john` as shown above again, but use this new wordlist file in place of the other one.
    * Optionally, use the `--format=raw-sha1` option to quiet `john`'s warnings and disable its hash format auto-detection.

This time, the report output differs:

```sh
$ ./john --format=raw-sha1 --wordlist=sanitycheck.no-crack.wordlist.txt sanitycheck.password.txt
Loaded 1 password hash (Raw SHA-1 [128/128 SSE2 intrinsics 4x])
No password hashes left to crack (see FAQ)
```

Rather than start a cracking session, `john` simply checks the password file we gave it (same as before, "`Loaded 1 password hash`") but then immediately reports "`No password hashes left to crack (see FAQ)`." This is happening because `john` remembers both this specific password hash file *and* the fact that we have already correctly guessed the password corresponding to the hash inside of it. John the Ripper maintains a list of successfully cracked hashes in a so-called pot. This is literally a file called `john.pot` and it will have appeared in the `run` folder after the previous invocation of `john`. We can open `john`'s `.pot` file with any graphical text editor or have a look at its contents using [the `cat(1)` command](https://linux.die.net/man/1/cat) on a GNU/Linux or macOS terminal, or [the `type` command](https://technet.microsoft.com/en-us/library/bb491026.aspx) in a Windows Command Prompt:

```sh
$ cat john.pot
$dynamic_26$ced91977849c44fd009ba437c14c1b74f632fae6:Sup3rs3kr3tP@24431w0rd
```

> :bulb: The format of this line is JtR-specific, but closely resembles the syntax used by the [Modular Crypt Format](https://pythonhosted.org/passlib/modular_crypt_format.html). See the "[Hash string format](#hash-string-format)" section, below, for generally-applicable details, or the `doc/DYNAMIC` file in the official John the Ripper source distribution for more information about "`dynamic`" hash formats in John the Ripper.

If you look closely, you can see both the hashed and plain versions of the password, but John the Ripper's documentation suggests an easier way of viewing this file's contents. Invoking `john` with its `--show` option (instead of its `--wordlist` option) presents a nicer readout:

```sh
$ ./john --show sanitycheck.password.txt
fsociety:Sup3rs3kr3tP@24431w0rd

1 password hash cracked, 0 left
```

Remembering previously-cracked hashes is convenient, but gets in the way of our sanity check. So, let's just delete the pot file and try again.

**Do this:**

1. Delete the `john.pot` file in JtR's `run` folder, or move it to the trash. 
1. Re-run the previous command invoking `john` with the intentionally-failing sanity check wordlist.

```sh
$ ./john --format=raw-sha1 --wordlist=sanitycheck.no-crack.wordlist.txt sanitycheck.password.txt
Loaded 1 password hash (Raw SHA-1 [128/128 SSE2 intrinsics 4x])
guesses: 0  time: 0:00:00:00 DONE (Tue Mar 14 18:39:29 2017)  c/s: 300  trying: randomGuess - someotherword
```

This report is more like what we were expecting. It's similar to the first report, where we successfully "guessed" the password, but this time it does not display the cracked hash. That's because we simply didn't include that guess in the wordlist we used.

Now that we understand `john`'s basic operation, and we can recognize what a successful and a failed cracking session looks like, we can move on to trying to crack the passwords we obtained off Evil Corp's mail server.

## Crack session preparation

Recall that, [previously](#scenario):

> Evil Corp's mail servers run a webmail system vulnerable to an exploit called Shellshock, which has enabled you to obtain files listing the usernames and passwords of everyone who uses the system.

Since Evil Corp's mail system was powered by a [Unix](https://en.wikipedia.org/wiki/Unix)-like server, the two files you plucked off their system during your hack were the files located at `/etc/passwd` and `/etc/shadow`. Often, these are just called "the `passwd` and `shadow` files" for short. On Unix-like systems, these two files taken together comprise a local database that provides the system with information about its user accounts and their passwords. Numerous programs query one or both of these files to answer numerous questions, including the all important question, "Is *this* the correct password for *that* user?"

Let's have a look at our copies of both the `passwd` and `shadow` files, which we saved as `evilcorp-intl.com.passwd.txt` and `evilcorp-intl.com.shadow.txt`, respectively. As before, we can use `cat` on a GNU/Linux or macOS terminal or `type` in a Windows Command Prompt to print the file's content. Here's the `passwd` file:

```sh
$ cat evilcorp-intl.com.passwd.txt
root:x:0:0:root:/root:/bin/sh
lp:x:7:7:lp:/var/spool/lpd:/bin/sh
tyrellwellick:x:65534:65534:tyrellwellick:/nonexistent:/bin/false
teddieboyle:x:89099:89099:teddieboyle:/nonexistent:/bin/false
paulwiener:x:60222:60222:paulwiener:/nonexistent:/bin/false
stevereeves:x:25652:25652:stevereeves:/nonexistent:/bin/false
chrispollard:x:47771:47771:chrispollard:/nonexistent:/bin/false
andrepaczos:x:20350:20350:andrepaczos:/nonexistent:/bin/false
susanross:x:31909:31909:susanross:/nonexistent:/bin/false
janetcleveland:x:24684:24684:janetcleveland:/nonexistent:/bin/false
torapeterson:x:28434:28434:torapeterson:/nonexistent:/bin/false
peterdunbar:x:54303:54303:peterdunbar:/nonexistent:/bin/false
mikesime:x:25057:25057:mikesime:/nonexistent:/bin/false
derekstenborg:x:78556:78556:derekstenborg:/nonexistent:/bin/false
vanessaweiss:x:79083:79083:vanessaweiss:/nonexistent:/bin/false
malaikajohnson:x:24113:24113:malaikajohnson:/nonexistent:/bin/false
johnlittlejars:x:58594:58594:johnlittlejars:/nonexistent:/bin/false
jeffpanessa:x:77078:77078:jeffpanessa:/nonexistent:/bin/false
aliciaoldham:x:49002:49002:aliciaoldham:/nonexistent:/bin/false
```

Notice that this text is structured, and it's structured the same way `john` expects it to be. At the start of each line is a username, and the values are delimited by colons. In database lingo, we call each line a *record*, and the positions in the record containing values are called *fields*. The fields are demarcated by the *field separater* (the colon, `:`, for this database). This is why the `passwd` file is sometimes also called the `passwd` *database*.

The `shadow` file is structured in the same way. Here is Tyrell Wellick's entry in the `shadow` file:

```
tyrellwellick:$6$ge7W6aVQ$dhJxmLt2qD964d8GXD7Z53EkxxKfe08LVRBNVZ5Xbg.YXXwgIagzJ9bRB.QUcgvOsdrhitXsTf0MbGY7S1sH60:17239:0:99999:7:::
```

Once again, notice the colons acting as field separators. Notice also that the first field is the username, and that this is the same across both files. The second field, however, is different. In the `passwd` file, the second field was always an `x`. In the `shadow` file, the second field is the coveted password hash.

> :beginner: :cinema: In the Mr. Robot episode, Elliot only retrieves one file, `passwd`. He never accesses the `shadow` file, but he is nonetheless able to crack Tyrell's password. This is an error. Since the password hash is located in the `shadow` file, merely obtaining the `passwd` file would have left Elliot without the information he needed to crack any passwords.
> 
> See the [`passwd` versus `shadow` files](#passwd-versus-shadow-files) section below for details, and the "[Technical errors in the Mr. Robot scene](#technical-errors-in-the-mr-robot-scene)" section in the [Discussion](#discussion) for a list of more errors like this.

It's immediately clear that this hash is way more complex than the raw SHA-1 hash we saw earlier. There are two reasons for that. First, it's a different hash algorithm, a more modern one designed to be harder than SHA-1 to crack. "Harder" means that it takes longer to compute a resulting value given some input, and thus slows attackers down. Second, it's been further complicated by a small amount of extra input, called *salt* (yes, from the expression, "salt to taste"). The salt makes *this* hash different from all other hashes that were given the same, original "unsalted" input. Thankfully, none of this need matter much to us, since `john` already knows how to recognize and deal with salted hashes.

> :beginner: For the curious, the salt for this hash is `ge7W6aVQ`. You can read it, plain as day, near the start of the second field in the `shadow` database. See the [Hash string formats](#hash-string-formats) and [Salted versus unsalted hashes](#salted-versus-unsalted-hashes) sections, below, for more details if you're curious.

Now that we know where the hashes actually are, and that they are conveniently enough already in files that match the structure `john` expects, we can just point `john` at them to get cracking, right? Well, almost. Let's do that with what we've got so far and see what happens.

**Do this:**

1. Download the [`evilcorp-intl.com.shadow.txt`](evilcorp-intl.com.shadow.txt?raw=true) file and save it in or move it to JtR's `run` folder.
1. Invoke `john` as shown above again, using the same ol' `sanitycheck.wordlist.txt` wordlist file as before, but use the `shadow` file as the password hash file instead of the "sanity check" one this time.

```sh
$ ./john --wordlist=sanitycheck.wordlist.txt evilcorp-intl.com.shadow.txt
Loaded 21 password hashes with 21 different salts (sha512crypt [64/64])
guesses: 0  time: 0:00:00:00 DONE (Wed Mar 15 19:58:29 2017)  c/s: 48.00  trying: randomGuess - someotherword
```

Unsurprisingly, `john` immediately reports failure. Careful readers will also notice that `john` reports it has "`Loaded 21 password hashes`" but notes they have been loaded "`with 21 different salts`." Thanks, `john`.

The reason why we failed is simple: there are only four guesses in our sanity check wordlist, while the number of possible guesses (the search space we need to attack) is in the zillions upon zillions. Clearly, we need to at least make more than four guesses; we need a bigger wordlist. Moreover, we need a *smart* wordlist, not just any list of words.

## Your first crack

To get us started, John the Ripper comes with a wordlist. It's the `password.lst` file located in JtR's `run` folder. Let's have a peek, and try it out.

**Do this:**

1. Open the `password.lst` file in JtR's `run` folder using your favorite text editor. (Graphical text editors like Notepad or TextEdit are both fine.)
1. Read the lines that start with `#!comment:` at the top of the file. They are reprinted here:  
    ```
    #!comment: This list has been compiled by Solar Designer of Openwall Project,
    #!comment: http://www.openwall.com/wordlists/
    #!comment:
    #!comment: This list is based on passwords most commonly seen on a set of Unix
    #!comment: systems in mid-1990's, sorted for decreasing number of occurrences
    #!comment: (that is, more common passwords are listed first).  It has been
    #!comment: revised to also include common website passwords from public lists
    #!comment: of "top N passwords" from major community website compromises that
    #!comment: occurred in 2006 through 2010.
    #!comment:
    #!comment: Last update: 2011/11/20 (3546 entries)
    ```
1. Invoke `john` again, but this time use Solar Designer's wordlist against Evil Corp's `shadow` file. (From here on out, you will need to work out the correct command invocation yourself.)

Depending on the speed of your computer, in a matter of seconds, this will have cracked (at least) one Evil Corp employee's password, revealing the password belonging to the user `chrispollard`. You were able to crack Chris Pollard's password because, despite not being an English word, it was an entry in the wordlist you just used. For that reason, we say that Chris's password was "in a dictionary," even though it was not in "*the* (Mirriam-Webster) dictionary."

**If *your* password is "in a dictionary," then you've just seen how easy it is for anyone else to crack.** This holds true regardless of how complex the password actually is. Remember `Sup3rs3kr3tP@24431w0rd`? You can bet that's in a dictionary now, just by virtue of it being used as an example on this exercise. So, y'know, never use it as your password for anything, ever.

To drive the point home, let's consider what we've just done. Solar Designer's `password.lst` wordlist has 3,546 entries. That means, for each password hash we loaded from the `shadow` file, and there were 21 of them, we made 3,546 guesses. If we do the math, which is 3,546 &times; 21, we can see we made a total of 74,466 guesses. Technically speaking, we produced 74,466 salted SHA-512 Crypt hashes and compared each one to the appropriate hash in the `shadow` file. Not too shabby, especially when you consider the amount of time you saved compared with making 74,466 guesses *by hand*.

Should you so desire, you can now log on to Evil Corp's corporate mail server and read Chris Pollard's emails. Unfortunately, Chris is just a low-level receptionist. We'll have to crack better passwords if we want to stop Evil Corp's nefarious plot. Besides, Chris's password was exceptionally bad. Most of Evil Corp's other employees are holding strong against this wordlist, including Tyrell Wellick. Ideally, we will crack all their passwords, but his is the one we actually need.

## Better wordlists

The wordlist that comes with John the Ripper isn't bad, it's just small. You might think 3,546 entries sounds like a lot, but given the speed with which your computer can make guesses, it's not. Even the spell-check dictionary on your computer has orders of magnitude more words in it than that, and your computer checks every word you type *as you type it* against each of those entries. Surely, there must be "better" wordlists available.

Of course, better wordlists *are* available, and we're going to use them.

While the most obvious characteristic of better wordlists may be that they're simply larger, remember that the larger the wordlist the longer it will take us to finish hashing and comparing each word in it to the hashes we're trying to crack. That's why a good wordlist is also sorted, with the most likely password candidates at the top. This raises the next obvious question: what are the more "likely" candidates? The answer to that increasingly depends on your target. For instance, most monolingual people choose passwords in the one language they speak, so including English words in a wordlist targeted at the account passwords of Portuguese speakers might waste valuable time.

Before we just chuck a huge number of additional words into our wordlist, though, let's get a deeper sense for how the professionals make their wordlists.

**Do this:**

1. Open the `password.lst` wordlist in your text editor again
1. Skim (scroll) through the wordlist to get a sense of its contents.
1. Find Chris Pollard's password in the wordlist.
    * What was the password immediately preceeding it?
    * What was the password immediately following it?
1. Find the first ten passwords in the wordlist. (These were your ten first guesses.) Compare them with the last ten passwords in the wordlist. (These were your ten last guesses.)
    * How many different classes of characters are in the first ten? (A *character class* is a set of characters, like "numbers," "lowercase letters," "uppercase letters," or "special symbols.")
    * How many different classes of characters are in the last ten?

One thing that should be immediately apparent to you is that many words in the wordlist are just plain old English words. This is because, believe it or not, many people take the term "password" literally, believing that their password must be an actual word. Some security-conscious applications have started using the term pass*phrase* in an attempt to better communicate the fact that a "password" can actually be *completely arbitrary*, and does not necessarily need to be an actual, honest-to-goodness human-language dictionary word.

There's more to notice, though. For instance, you may have noticed that numerous "words" in the wordlist are simple patterns. Common patterns include numeric sequences like "`123456`" and strings that correspond to the rows or layouts of keyboards or a phone's keypad, or the finger positions of trained typists, such as "`asdfjkl;`" (called [the *home row* on a US English keyboard](https://web.archive.org/web/20161225064555/http://www.typing-lessons.org/lesson_1.html)). There are also colloquialisms such as "`shazam`," obscenities like "`fuckyou`," and various pronouns (i.e., the names of places, TV shows, celebrities, companies, and so on). A follow-on obsveration we can make from this is that most of the wordlist's words aren't very long, around ten characters or so.

Moreover, notice that fewer words near the top of the wordlist have a mix of character types. Most of those words are either all letters or all numbers. Most of the ones with letters don't even have a mix of upper- and lower-case characters, and even when they do, the capital letter is usually at the very beginning, just as you'd expect them to appear in regular written text. Later on in the wordlist, where mixed character sets begin to appear, there is still a clearly discernible pattern. Words with numbers overwhelmingly use the digits 1 and 2, and they usually appear at the end of the word. Even the symbols, when they appear at all, are predictable. Most of these also follow clear patterns, like keyboard layouts. Finally, there are almost no occurrences of the more esoteric symbols like the [Section sign (`§`)](https://en.wikipedia.org/wiki/Section_sign).

> :bulb: Of course, the above observations are not the only ones you can make about Solar Designer's wordlist. To find some others, you can ask yourself questions about the list, such as, "In what language are the 'real' words?" and "What is the ratio of 'regular' words to special words like specific industry jargon?" The answers to questions like these can often tell you a lot about where a wordlist came from or what kind of users it might be intended to target. Likewise, it helps to put yourself into the mindset of your target when trying to crack their passwords. Questions like "What kind of information is their password intended to secure?" or "What is the purpose of their account?" might help you find or make a smarter wordlist for a specific kind of target, such as corporate employee work accounts, gamer personal accounts, or crack passwords from a specific source such as an enthusiast or hobbyist forum or social network. See the [Characteristics of a good password cracking wordlist](#characteristics-of-a-good-password-cracking-wordlist) section for a further discussion of this subtlety.

All of these observations are going to be helpful to us in making smarter guesses sooner, that is, in making better wordlists. We *could* now begin the process of composing a custom wordlist to target Evil Corp employees specifically, but in all likelihood "Evil Corp employees" are not so different from any other random company's workers. So, instead, let's just see what other wordlist options are already available to us.

**Do this:**

1. Search the Internet for a better wordlist or two (or three).
    * Some people, including JtR's makers, *sell* wordlists. You do *not* need to buy any of these.
    * Hint: Some of the best wordlists are compiled from previous [data breaches](https://en.wikipedia.org/wiki/Data_breach), and in this context the wordlists are called [*password dumps*](https://web.archive.org/web/20160819141410/http://www.security-faqs.com/what-is-a-password-dump.html).
1. Use the better wordlists you found against the Evil Corp password hashes.

> :beginner: :bulb: Here are some tips for your cracking session:
> 
> * You can press the `return` or `Enter` key on your keyboard while `john` is working to ask for a status report. This report will show you how long `john` thinks it will take to finish the session. Depending on the size of your chosen wordlist and the speed of your computer, `john` might tell you that you're in for a long wait!
> * If you get impatient during your cracking session, or if you need to stop to turn off your laptop, you can press and hold the Control key and then, before releasing it, press and release the `c` key to interrupt `john` before the session completes on its own. (You might also see this keyboard combination notated as `C-c`, `^C`, or `CTRL+C`.) This will stop `john` and give you back your command prompt. Don't worry, you can pick up exactly where you left off by subsequently invoking `john` with the `--restore` option, like this: `./john --restore`
> * As a hint, for the purposes of this exercise, if you find the right wordlist(s), it should not take you very long to crack at least a couple more hashes, even on commodity hardware from about 2012 or so. If you're getting nowhere and `john` tells you that your session will last for more than a few hours, you should consider trying a different wordlist. Think through what kind of wordlist you should look for, given the nature of the accounts you're trying to crack, or what you know about the Evil Corp employees, themselves.

If you found and loaded useful wordlists, you will have cracked a couple more hashes by now. You may also notice some relationships between the revealed passwords, the users who chose them, and their user accounts. People's cracked passwords often reflect little insights about who they are or what they're like.

**If *your* password has any meaningful relationship to things like the provider or purpose of your account, you can now see how easy it would be to guess.** In particular, notice that these guesses are not guesses about *you*, but rather about passwords *generally*. Moreover, notice also that even though your specific *account* may never have been hacked, an attacker may already have your *password* in a dictionary waiting to be used just because someone else once used the same password elsewhere that you're using for one of your own accounts. Since *their* password ended up in a cracking dictionary, your account is now also at risk through no direct fault of your own.

> :beginner: :bulb: This is one of the many ways your personal security and privacy is partly dependent on the actions of others, outside of your immediate control. Professionals call this a "networked" or sometimes a "systems" problem, because inputs to one part of a networked system cause ripples that affect its other parts. Put more plainly, if you truly want to secure yourself and your privacy, you have to help your family and friends do the same for themselves, and on top of that you also all have to work together to protect and respect each other.

At this point, you could log on to Evil Corp's corporate mail server as a number of different users thanks to the smarter guesses in the better wordlists you used during your dictionary attacks. Unfortunately, it's still unlikely that you'll have cracked Tyrell Wellick's password (unless one of the wordlists you used included his exact password, of course). Regardless, there are still a number of passwords left to crack, which requires us to guess passwords (or "explore the search space") more algorithmically. This will make it possible to "automatically" find passwords that are similar to but not exactly matching the guesses in our wordlist.

## Word mangling rules

Most good hash cracking tools provide a built-in facility for the purpose of algorithmically making smart password guesses based on other likely passwords. JtR calls this facility *word mangling*, and it lets you tell `john` how to modify words in your wordlist in arbitrary ways by writing *wordlist rules*. Using these rules in conjunction with a wordlist to guess passwords is called a *rule-based attack*.

To make things easier, John the Ripper comes pre-configured with numerous *rule sections* (or "rulesets"), which are named groups of word mangling rules useful for specific attack purposes. Of course, you can also write your own individual rules or whole rulesets for your own purposes. Before we do that, let's first have a look at JtR's built-in rules and how to use them.

Recall that our "sanity check" wordlist contains four password candidates:

```sh
$ cat sanitycheck.wordlist.txt
randomGuess
alsoWrong
Sup3rs3kr3tP@24431w0rd
someotherword
```

We can ask `john` to show us all the password candidates it will guess by invoking it with the `--stdout` option *instead* of a file with password hashes in it. Running `john` this way, with our `sanitycheck.wordlist.txt` file as the input wordlist, will show a report like the following:

```sh
$ ./john --wordlist=sanitycheck.wordlist.txt --stdout
randomGuess
alsoWrong
Sup3rs3kr3tP@24431w0rd
someotherword
words: 4  time: 0:00:00:00 DONE (Sat Apr  1 15:53:29 2017)  w/s: 80.00  current: someotherword
```

Here, `john` correctly reports there are four password candidates ("`words: 4`"). The purpose of a word mangling ruleset is to take this list of "likely" password candidates and mutate each entry in some pre-defined ways. Each mutation's result is then used as a password candidate, as though it were part of the original wordlist. This way, we can more elegantly express patterns in our guesses, by encoding ideas like "add a `1` to the end of every guess" as a word mangling rule. For instance, look at the following list of guesses (which I've truncated for readability purposes) and the ultimate report `john` gives us after invoking it with the same wordlist (`--wordlist=sanitycheck.wordlist.txt`) *and* its `--rules` option:

```sh
$ ./john --wordlist=sanitycheck.wordlist.txt --rules --stdout
randomGuess
alsoWrong
Sup3rs3kr3tP@24431w0rd
someotherword
randomguess
alsowrong
Randomguess
Alsowrong
Someotherword
randomguesses
alsowrongs
someotherwords
randomguess1
alsowrong1
someotherword1
Randomguess1
Alsowrong1
Someotherword1
# …many more combinations omitted for length…
8randomguess
8alsowrong
8someotherword
Randomguesses
Alsowrongs
Someotherwords
randomguessed
alsowrongged
someotherworded
randomguessing
alsowrongging
someotherwording
Randomguessed
Alsowrongged
Someotherworded
Randomguessing
Alsowrongging
Someotherwording
words: 151  time: 0:00:00:00 DONE (Sat Apr  1 16:07:03 2017)  w/s: 2516  current: Someotherwording
```

This time, `john` produced 151 password candidates even though the input wordlist file still only contains four words. You can see the unmodified wordlist echoed as the first four candidates, and you can see the 147 new guesses are clearly based on those original four words: common English-language suffixes (like `ed` and `ing`) have been added, letter case has been changed or normalized, and single digits have been appended or prepended. All of these changes are described by word mangling rules written inside a *configuration file* in `john`'s `run` folder, named `john.conf`, that `john` loaded automatically each time you invoked it.

> :beginner: :computer: Configuration files are a common way that command line programs describe application preferences or allow a user to customize a program's options that they want to use, so you can think of a configuration file as analogous to a graphical program's Preferences, Settings, or Options screen. Configuration files are almost always plain text files structured in well-defined ways that the program they are intended to configure is pre-programmed to expect. Confusingly, there are many syntactic and stylistic differences between one program's configuration file structure and another's, despite many attempts at standardization over the years. Not even the filename extension is standardized, although extensions like `.conf`, `.config`, `.cfg`, and `.ini` are among the most common.
> 
> :bulb: A full discussion of John the Ripper's configuration file is beyond the scope of this exercise, but see the `doc/CONFIG` file in the official JtR source distribution for more information about customizing `john`'s behavior.

To see why these specific candidates were generated from the original words, we can examine the specific wordlist rules `john` applied to them. By default, when you invoke `john` with a combination of the `--wordlist` and `--rules` options, it will load the mangling rules in the "`Wordlist`" section of the `john.conf` file. You can achieve the same effect while being more explicit by specifying the name of the section you want load rules from, as in `--rules=Wordlist`.

> :beginner: :bulb: John the Ripper ships with four wordlist rulesets: `Single`, `Extra`, `Wordlist`, and `NT`. Any of those names can be passed to the `--rules` option to load the wordlist rules defined in that section of the `john.conf` file. There are also two additional named wordlist rule sections configured by default. The first, `Single-Extra`, loads the `Single` ruleset followed by the `Extra` ruleset. The other, `Jumbo`, loads all four rulesets one after the other, which results in a dramatically expanded password candidate list and greatly increases cracking session time.

In my copy of `john.conf`, this section header is at line 338 of the file and it begins like this:

```
# Wordlist mode rules
[List.Rules:Wordlist]
# Try words as they are
:
# Lowercase every pure alphanumeric word
-c >3 !?X l Q
# Capitalize every pure alphanumeric word
-c (?a >2 !?X c Q
# Lowercase and pluralize pure alphabetic words
<* >2 !?A l p
# Lowercase pure alphabetic words and append '1'
<* >2 !?A l $1
# Capitalize pure alphabetic words and append '1'
-c <* >2 !?A c $1
```

These lines show JtR's specific syntax for a named section header (the `[List.Rules:Wordlist]` part), and some word mangling rules themselves (lines like `-c >3 !?X l Q` and `<* >2 !?A l $1`). Each rule is a single line, and each line is composed of JtR's own miniature language to describe mangling operations. We'll explore this language in more detail shortly. Fortunately, the author of this configuration file included English-language descriptions of what each rule actually does as a comment before each one so we can more easily match up the output of `john`'s candidate list with these rules.

For instance, the very first comment and its rule in the ruleset is:

```
# Try words as they are
:
```

Said another way, "for every input word, make no changes to it." In `john`'s word mangling rule mini-language, this is written as a single colon (`:`). The existence of this first "do nothing" rule in the ruleset is why the first set of generated password candidates from our wordlist exactly match the words in the original wordlist.

The second rule in the ruleset is more complex, as its comment makes clear:

```
# Lowercase every pure alphanumeric word
-c >3 !?X l Q
```

In this wordlist, we have three "pure alphanumeric words." These are:

* `randomGuess`
* `alsoWrong`
* `someotherword`

Note that, of these, `someotherword` is *already* lowercased, so applying this rule to this input is effectively the same as doing nothing. That is, for this input word, this rule is equivalent to the previous rule, the single colon, so no output is generated. That means this rule only actually mangles the other two words, and what it does to them is lowercase the uppercase letters in them. Sure enough, the fifth and sixth words in `john`'s generated wordlist are `randomguess` and `alsowrong`, which are lowercased variants of the same inputs.

The syntax and grammar for composing word mangling rules is rich, but very terse. Each rule contains a list of mangling instructions, called *simple commands* (separated by spaces to make the whole rule slightly more human-readable), with an optional set of qualifiers at the start that determine whether or not to actually apply the rule to the given word, called *rule reject flags*. The first rule we saw, the single colon on its own line, is an example of a rule without any rule reject flags and consisting entirely of one simple command, which was the colon itself. Here's how the "Lowercase every pure alphanumeric word" rule breaks down:

1. `-c` is a rule reject flag that tells `john` to ignore this rule for case-*in*sensitive hashing algorithms. Since the SHA-1 and the SHA-512 Crypt hashing algorithms we're working with in this lab are case-sensistive, `john` will continue to evaluate and apply the remainder of the rule.
1. `>3` is the first simple command in the rule, and it tells `john` to mangle this word only if it has more than (`>`) three (`3`) characters. This is similar to a rule reject flag, but it operates on the input word rather than the hash type. Since all four words in our "sanity check" wordlist are longer than three characters, `john` will mangle all of them according to the instructions in the rest of this rule. 
1. `!?X` is the second simple command in the rule, which tells `john` to mangle this word only if it contains purely alphanumeric characters. More specifically, the exclamation point (`!`) is the simple command to ignore mangling the word if that word contains a given character. The question mark (`?`) signifies a *character class*, which is a pre-defined set of characters (like "A through Z" or "0 through 9"), and the `X` immediately following the question mark means the complement of the `?x` character class, which is alphanumeric characters. Putting this together, `!?X` means "reject this word if the word contains a non-alphanumeric character," and the logical effect of this construction is to apply the rule only to input words that are purley alphanumeric. In our wordlist, this part of the rule disqualifies the word `Sup3rs3kr3tP@24431w0rd` because it contains an at-sign (`@`) character, so `john` will only apply this rule to the other three words in our wordlist.
1. `l` (lowercase letter L) is the simple command to convert the input word to lowercase lettering.
1. Finally, `Q` is a simple command that tells `john` to compare the result of the mutations applied and include the word in the output list of generated candidates only if it's *actually* different from the original input word. This is why `john` doesn't try guessing `someotherword` twice, which would clearly be a waste of time.

> :bulb: Although we'll explore [writing wordlist rules](#writing-wordlist-rules) more soon, a comprehensive manual for John the Ripper's wordlist rule syntax is beyond the scope of this exercise. If you want a complete accounting of each reject flag and simple command that `john` understands, see the `doc/RULES` file in the official JtR source distribution for more information.

Let's give the `--rules` option a go, and see if `john`'s pre-configured "Wordlist" ruleset gives us any more password hits.

**Do this:**

1. Perform a rule-based attack against the Evil Corp server's shadow file using JtR's default `password.lst` wordlist by invoking `john` with its `--rules` option.

If you've invoked `john` correctly (and have not already cracked the matched passwords), this will have cracked (at least) one more Evil Corp employee's password, revealing the password belonging to the user `jeffpanessa`. You were able to crack Jeff Panessa's password hash despite the fact that the `password.lst` wordlist didn't include his exact password because it was nonetheless similar enough to a reasonable guess that could be expressed with a simple wordlist rule. This is why passwords based on common patterns or widely-used variations are not much harder to crack than passwords that are already listed in a dictionary; not only may dictionaries that include the exact password be available to attackers, mangling rules that mutate the words in these dictionaries may have already been written for attackers to use.

**If *your* password uses character substitutions, omissions, additions, or other kinds of common variations on a theme, then you've just seen how easy it is for anyone else to crack.** In this way, wordlist rules can effectively and efficiently expand the size of cracking dictionaries by many orders of magnitude while simultaneously and narrowly targeting only the patterns likely to be devised and used by humans as passwords. This makes rule-based attacks (i.e., using a good wordlist coupled with a good ruleset) an extremely good way to "make smarter guesses sooner" and crack more passwords faster.

You are now well on your way to cracking all the passwords used with Evil Corp's mail server accounts, but Tyrell Wellick's password remains elusive. This simply means you don't yet have his password in a wordlist, or don't yet have something close enough to it that the wordlist rules you've used are expanding to. To crack his password, we'll have to prepare a more targeted password cracking attack.

## Preparing a personally targeted attack

As you've seen, most password hashes can be cracked en-masse. Attackers don't need to target specific individuals to easily crack most account passwords most of the time; you don't need to be a particularly "interesting" person or be doing something particularly "important" for your account to be targeted and your password cracked. Indeed, the passwords used in this exercise that you've cracked so far are fairly typical of real passwords that real people use with their real accounts in real life.

Nevertheless, some passwords will remain elusive even though they're not particularly complex. In most cases, that's because they reference *personally identifiable information*, often abbreviated to *PII* by cybersecurity professionals and password crackers alike. PII most directly refers to a person's name, birthday, or private information like a social security number or bank account, but can also refer to any personally meaningful information, like dates for graduations or anniversaries, names of friends, family members, or pets, childhood addresses, schools, workplaces, or other institutions with which the person is or was affiliated, and so on.

Sometimes, personally identifiable information makes its way into wordlists. For example, you may have come across downloadable wordlists of common names in numerous languages when searching for [better wordlists](#better-wordlists) earlier in this exercise. (If you haven't and you want to try cracking a few more passwords, give that a shot!) Other times, particularly if you're targeting a specific individual, you may get better results by generating your own wordlist based on your target's publicly available (or less-legally acquired) personal information.

Since we're specifically going after Tyrell Wellick's account, we're more likely to guess his password correctly if we do our research about him, as an individual. We'll do this in two phases. First, we'll make a custom wordlist specifically for targeting Tyrell Wellick's passwords and then, if we still can't crack his password, we'll write our own wordlist rules to generate more guesses based on patterns we think he's likely to have used.

### Writing custom wordlists

The more you know about a person, the more likely it is that you'll be able to guess their passwords. This is simply because the nature of using passwords requires their memorization, and human brains are not good at memorizing completely random information. Quite the contrary, in fact. Humans are exceptionally good at recognizing and memorizing patterns of highly structured, and especially personally meaningful, data. That's why so many people use such easily-guessable passwords in the first place.

To make a custom wordlist for targeting Tyrell Wellick, all we have to do is write down everything we think is important or related to him in some way. This should include everything from the utterly obvious, like his name and birthdate, to the far-fetched or hard to discover, like a distant relative's first job title or references to his favorite childhood lullabies, and everything in between. Naturally, we can't know all of this, but the point is to find out as much as we can and then write everything down in a plain text file, one unique item at a time.

For example: we know his name is Tyrell Wellick, so we should start by including `Tyrell` and `Wellick`. We know he works for Evil Corp, so `Evil Corp` (as one "word," with the space) is a sensible third word. We might also consider `Evil` and `Corp` as the fourth and fifth words. Moreover, we know his position at the company, Senior Vice President of Technology, but since `Senior Vice President of Technology` doesn't feel like a password, we would be better off simply including `Senior`, `Vice`, `President`, and `Technology` as individual words. With just this information, we can construct a wordlist such as the following:

```
Tyrell
Wellick
Evil Corp
Evil
Corp
Senior
Vice
President
Technology
```

This is a decent start, but of course we know a lot more than just these bland facts about Tyrell. We know he's ambitious, devoting much of his time to clibming the corporate ladder at Evil Corp, so we should put ourselves in his shoes and think about what phrases he might enjoy typing every time he needs to log in to his work webmail account. This is as simple as playing a word association game with ourselves. For example, `CTO`, `power`, `rich`, `money`, `executive`, and `success` are all decent guesses because these are all things we know Tyrell Wellick aspires to have or be. Since we're also trying to crack his webmail account specifically, we should also include words like `mail`, `email`, `work`, `job`, `business`, and anything else we can associate with the purpose of his account.

Further, we know that Tyrell Wellick began his career as a tech and that he prefers the K Desktop Environment ("KDE") over the alternative that Elliot prefers (GNOME). We know he is married, we know his wife's name is Joanna, we know he's Swedish, that he speaks Dutch, and so on. Some of these details are good guesses in themselves; for instance, we should definitely include `Joanna`, `Sweden`, `Dutch`, and `KDE` in our wodlist. Spending a few minutes brainstorming associations with all of these items will give us even more good guesses.

This gives us the seeds of a good wordlist, but what else can we find out about Tyrell Wellick that we don't already know?

> :cinema: :warning: **SPOILER ALERT.** Since Tyrell Wellick is a fictional character, you can find out a lot of information about the Mr. Robot TV show itself by performing the following exercise. If you have not yet watched the full series, this may expose you to some spoilers. As an alternative, you can simply read through this part of the exercise to get a feel for how personally-targeted attacks are constructed rather than actually performing said searches yourself until you have already watched the show.

**Do this:**

1. Open a new blank text document in a text editor (such as Notepad or TextEdit).
1. Write your basic password guesses, one on each line, in the text document as you come up with them; this will become your Tyrell-specific wordlist.
1. Use an Internet search engine to find any more details you can about Tyrell Wellick.
1. Read articles about him or pages and profiles he's made that come up in your search.
1. Add whatever details you encounter to the wordlist. See if you can find the answers to the following questions about him:

    * Where was Tyrell Wellick born?
    * When is Tyrell Wellick's birthday?
    * What are the names of Tyrell Wellick's parents?
    * When was Tyrell Wellick first hired by Evil Corp?
    * With whom does Tyrell Wellick work?
    * What is Tyrell's home address? His work address?
    * What number is the suite to Tyrell's office?
    * What are some of Tyrell's hobbies?
    * Which kind of music does Tyrell like to listen to?
    * What color is Tyrell's hair, eyes?
    * How much does Tyrell weigh?
    * When did Tyrell Wellick get married?
    * What brands of clothing does Tyrell wear?

    Write down guesses relating to all of these answers in your wordlist. For instance, include the first and last names of all the people Tyrell works with as guesses in your wordlist.

1. Follow any links in the articles you found towards, or perform new searches about, any of the additional people, places or things, relevant to your target. See if you can answer the following questions:

    * When was Tyrell's boss hired by Evil Corp?
    * What is the name of Tyrell's boss's secretary?
    * What are the colors in the Swedish flag?
    * What are the 50 most common Swedish surnames? The 50 most common Danish surnames?
    * What are some famous historical moments in Sweden? When did these events occur? When were these people born? When did they die?
    * Who are the 5 most popular Swedish musicians in Tyrell's favorite musical style?
    * What is Tyrell's wife's birthdate?
    * What is Tyrell's wife's maiden name?
    * From what school did Tyrell's wife graduate?
    * What is the name of the gym that Tyrell's friends visit?
    * Who is Tyrell's father's favorite poet?
    * What are the online handles (usernames) of the KDE developers?

    Include your answers, and any additional word associations you can come up with, in your wordlist.
1. Repeat steps 3 through 6 with the people and things closest to Tyrell's life. For instance, perform the same process for Joanna Wellick, Tyrell's wife, his boss, and anyone or anything else you feel is fruitful.
    * You can continue manually curating your wordlist for as long as you like, but for the purposes of this exercise you needn't continue beyond two to three hundred guesses.
1. Save your wordlist with a meaningful name (such as `tyrellwellick.wordlist.txt`) inside `john`'s `run` folder.

> :beginner: :bulb: As you can imagine, this process is highly automatable. While there is of course no substitute for human judgement and intuition, a good deal of the tedium can be removed by using a tool like [CeWL, the Custom Wordlist generator](https://digi.ninja/projects/cewl.php). The `cewl` program is a command-line utility that crawls a website you specify and generates a wordlist of all the unique words, email addresses, and other metadata published on it. See the [Discussion](#discussion) about [generating custom wordlists automatically](#generating-custom-wordlists-automatically) for more information.

Unless your guesses were remarkably intuitive, or the passwords you're trying to crack were exceptionally bad, it's not very likely that a straight dictionary attack will crack any new hashes just by manually creating a small wordlist like this. More usefully, you now have the seeds of a highly targeted rule-based attack. Since John the Ripper ships with some default wordlist rules and some of these rulesets include the exact guesses in a wordlist (and since your wordlist is still relatively small), it's worth trying a quick rule-based attack to expand your guesses to some very common variations.

**Do this:**

* Perform a rule-based attack using `john`'s default "`Wordlist`" ruleset using your custom wordlist against the Evil Corp sever's shadow file. Since this ruleset includes the "do nothing" wordlist rule (`:`), this also has the effect of performing a straight dictionary attack using your custom wordlist.

Although this may have cracked a couple more passwords, we can do even better by further expanding these guesses with our own wordlist rules that hit specific patterns of likely passwords. Also, while there's some good inspiration available to us in JtR's default wordlist rulesets, using all of them (with `--rules=Jumbo`, for instance), might just take too long. We can save ourselves time and zero-in on the "smartest" guesses by crafting our own rules based what we know about our target, Mr. Wellick.

### Writing wordlist rules

Equipped with a custom wordlist, we can now use it as the basis for patterned guessing by mangling those words in specific ways. Of course, once we've written our own rules, we can apply them to any wordlist we have. We will probably want to append and prepend numbers and some symbols, because that's a very common password pattern, but we can also do smarter things like insert specific abbreviations, mnemonics, or phrases meaningful to our target, replace certain characters with others, and more.

John the Ripper's wordlist rules are always loaded from one or more configuration files. While we could directly edit the `john.conf` file that JtR ships with, there's a better way: we can write our custom rules in a new named section within a second configuration file called `john.local.conf`. This file is automatically loaded each time we invoke `john` because the very last line of the first configuration file, `john.conf`, instructs `john` to do exactly that, as shown here:

```
# include john.local.conf (defaults to being empty, but never overwritten)
.include "$JOHN/john.local.conf"
```

> :beginner: :bulb: This is what's known as an "include directive" in John the Ripper's configuration file, sometimes more generically referred to as a "dot-command," because the directive begins with a dot (`.`). In this case, it translates to English as "read the contents of the `john.local.conf` file in whatever directories `john` searches for such files inside of (`$JOHN`) as though those files's contents were written here." The actual directory or directories to which the symbol `$JOHN` refers depends on how you've installed `john`, but if you've followed the instructions in the [set up](#set-up) section, it will always mean "`john`'s `run` folder."

We'll need to tell `john` that we're writing a wordlist ruleset, and we'll need to give this ruleset a name. The syntax for this is `[List.Rules:A_NEW_NAME]` on a line by itself. Section headers in a JtR configuration file begin and end with square brackets, `List.Rules` signifies that the section will contain wordlist rules, the colon (`:`) introduces the section's name, and so `A_NEW_NAME` is the name we want to use. For instance, if the first line of the `john.local.conf` file was `[List.Rules:EvilCorp]`, then you could invoke `john` with `--rules=EvilCorp` to load the ruleset written in that section.

**Do this:**

1. Open the `john.local.conf` file with a text editor. (If the file doesn't exist, create a new text document and save it in `john`'s `run` folder with that name.)
1. Type a named wordlist rule section header at the first line of this file; you can copy-and-paste `[List.Rules:EvilCorp]` if you like.

Beneath the named section header of a `List.Rules` section, we can compose the specific wordlist rules we want to use. This is the trickiest part, because it not only requires knowing what we want to do, but also how to express our intent in `john`'s wordlist rule mini-language. Let's take it one step at a time.

First, let's imagine some common password variations. We'll record these ideas in English-language *comments* in the configuration file as we think of them. Then we'll come back to each English-language expression of these patterns and translate them into John the Ripper's wordlist syntax.

For instance, Internet slang often appears in passwords because it mixes letters and numbers, like `b4` to mean "before" and `g8` to mean "great." So, for instance, we can compose a wordlist rule that takes each word (password guess) from our wordlist and prepends `g8` to it, turning something like `password` into `g8password` (which is, of course, not actually a great password), appends it, turning `password` into `passwordg8`, inserts it in a specific character position, turning `password` into `passg8word`, and so on. We are limited only by the original wordlist and our understanding of `john`'s wordlist rule syntax.

In English, we can express these ideas by simply writing, "Prepend and append Internet slang words like 'b4' or 'g8'." To make this a configuration file comment, all we have to do is put an octothorpe (or pound-sign, `#`) before the English text. It would look like this:

```
[List.Rules:EvilCorp]
# Prepend and append Internet slang words like 'b4' and 'g8'.
```

Another common variation on passwords is to prepend or append (a loved) someone's year of birth. A naive approach would be to write rules for all possible four-digit years (`0000`, `0001`, `0002`, and so on), but since everyone currently living was born in the 1900's or 2000's, that's pretty silly. Instead, we should focus just on the late 1900's and early 2000's. Once again, we can express this in our native human language first as a comment in the configuration file. We can deal with translating that idea to John the Ripper's syntax later.

There are, of course, many other common variations and substitions. For instance, people often replace the letter `a` in passwords with the digit `4`, or sometimes the at-sign (the `@` symbol), and they do similar things for the letter `i` (lowercase I) with the digit `1`. For now, simply write these ideas out in natural language as comments, with the ones you think Tyrell Wellick is more likely to use before the ones you think he's less likely to use.

**Do this:**

1. On the second line of your `john.local.conf` file, immediately underneath the section header, write a comment. You can copy-and-paste `# Prepend and append Internet slang words like 'b4' and 'g8'.` if you want.
1. On the third line, write another comment that reads, "`Prepend and append birthyears.`"
1. Come up with another variation or two, and write a comment in the configuration file that expresses your idea in human language.

At this point, your `john.local.conf` file should look something like this:

```
[List.Rules:EvilCorp]
# Prepend and append Internet slang words like 'b4' and 'g8'.
# Prepand and append birthyears.
# […your next idea here…]
```

John the Ripper will ignore our comments in its configuration files. This is useful because it allows us to write notes to ourselves, but we still need to translate those ideas into a language that `john` will understand. Here's a brief primer:

> :beginner: :bulb: You can find a complete description of John the Ripper's wordlist rule syntax in the `doc/RULES` file in JtR's source distribution, but another helpful reference is [Hashcat's Rule-based Attack page, which has a section named "Implemented compatible functions"](https://hashcat.net/wiki/doku.php?id=rule_based_attack#implemented_compatible_functions) that shows input and output examples for many of John the Ripper's simple commands. Hashcat is an alternative hash cracking tool with its own word mangling rule engine. Mercifully, much of Hashcat's wordlist rule syntax is the same as `john`'s.

* To prepend a single character, the caret (`^`) simple command is used. For example:
    * `^8` will turn `password` into `8password`.
* To append a single character, the dollar sign (`$`) simple command is used. For example:
    * `$1` will turn `password` into `password1`.
* To prepend a string of two or more characters, the "string command" is used. This command always begins with a capital letter A, followed by the number for where to insert the characters, a delimeter, the string literal to insert, and the delimeter again. For example:

    * `A0"g8"` will turn `password` into `g8password`. Breaking this down:
        * `A` signals to `john` that this is a string simple command.
        * `0` indicates the starting position, in this case `0`, meaning "before the first character."
        * `"` is the chosen delimeter. In this example, we used a double-quote, but we could also use any other character we like, so long as the character we choose doesn't appear in the string literal we want to insert.
        * `g8` is the string literal we want to insert.
        * `"` is the second, and closing instance, of our chosen string delimeter.

    Note that the simple command `A0"g8"` is equivalent to a wordlist rule with the two simple commands `^8 ^g`. In this rule, `john` will first prepend (`^`) the character `8`, turning `password` into `8password` as instructed by the first simple command in the rule. Then `john` proceeds to follow the instruction of the second simple command, which takes the result of the previous command and further mangles it, this time prepending `g` (turning `8password` into `g8password`).

* To append a string of two or more characters, we use the string command again, but with a `z` as the character position "number." For example:

    * `Az"g8"` will turn `password` into `passwordg8`. This is composed in exactly the same way as the previous example, but uses `z` instead of a number since this will work regardless of how many characters are in the given input word.

    Of course, another way to get the same result is `$g $8`.

* To generate password candidates with a range of characters at once, we can write those characters in square brackets with a dash in between indicating the range from the start to the end character. For example:
    * `$[1-3]` will turn `password` into `password1`, `password2`, and `password3`. This is equivalent to the three rules `$1`, `$2`, and `$3` on three different lines, but is more concise and easier to write. Breaking this down:
        * `$` is the command to append a single character, same as above.
        * `[` begins a *preprocessor directive*, which tells `john` to treat the next sequence as a set of characters to automatically create rules for, independent.
        * `1` is the first character in the range.
        * `-` is the range specifier, which tells `john` to automatically fill in "from 1 to…" the ending character.
        * `3` is the last character in the range, so `john` will create equivalent rules for everything "from 1 to 3."
        * `]` ends the preprocessor directive.
    * Similarly, `^[a-c]` will turn `password` into `apasswod`, `bpassword`, and `cpassword`, which shows that ranges work with letters, too.
* To substitute one character with another, use the the `s` simple command. For example:
    * `ss$` will turn every lowercase letter S (`s`) into the dollar sign symbol `$`, so `password` will become `pa$$word`. Breaking this down:
    * The first `s` is the "substitute" (or "replace") simple command. It needs to know what to find, and what to replace the found characters with.
    * The second `s` in this example is the character to find.
    * The dollar sign character, `$`, in this example is the character to replace all the found characters with.

When writing a rule, you can use as many simple commands in sequence as you like. For example, a rule to replace all the `s`'s with dollar signs and then append two exclamation points at the end of each word could be written like this `ss$ Az"!!"`. If you find yourself writing many similar rules, using a preprocessor directive with a range in a rule can be more expressive. For example, a rule to prepend all the four-digit years from 1950 to 1999 to every word could be written in one simple command with two ranges, like `A0"19[5-9][0-9]"`. Don't hesitate to refer to JtR's documentation while writing rules (most professionals do).

> :beginner: As you're writing these wordlist rules, you can test them on a very short wordlist (such as the `sanitycheck.wordlist.txt`) by invoking `john` with its `--stdout` option, as before. This will give you feedback about whether or not your wordlist rules are doing what you expect them to. For example, `./john --wordlist=sanitycheck.wordlist.txt --rules=EvilCorp --stdout` should generated passwords including `g8randomGuess`, `randomGuessg8` and so forth. Be sure to pay attention to how quickly the rules you're writing increase the number of guesses `john` will make; the more guesses, you need to make, the more time you'll need to attempt each guess.

**Do this:**

1. Translate the first two comments into actual wordlist rules. Your `john.local.conf` configuration file should now begin to look something like this:

    ```
    [List.Rules:EvilCorp]
    # Prepend and append Internet slang words like 'b4' and 'g8'.
    A0"b4"
    $b $4
    A0"g8"
    Az"g8"
    ```

1. Use your custom rules to perform a rule-based attack in conjunction with one or more of your wordlists against Evil Corp's shadow file.

> :beginner: :cinema: :warning: One thing you're likely to notice immediately is that it takes you a lot longer than the several seconds shown on the Mr. Robot TV show to perform a rule-based attack like this. Don't be disheartened if your rules have ballooned your crack session time from minutes to hours; that's pretty normal and happens when you're using John the Ripper's built-in rulesets, too. You can either further tweak your rules themselves, re-order them to improve your attempt at "making smarter guesses sooner," further refine your wordlist or use a smaller one, or you can press `^C` to cancel a long-running crack session prematurely. Regardless, you can now see how cracking passwords instantly on television is a bit more "movie magic" than reality.

If you've written good rules that guessed likely patterns (and have not already cracked the matching passwords), you will have cracked (at least) one more Evil Corp employee's password, revealing the password belonging to the user `janetcleveland`. You may even have cracked Tyrell Wellick's password! (A hint: Tyrell Wellick's password is absolutely crackable at this stage with the right wordlist and rules.) You were able to crack their passwords, and possibly even Tyrell's, because despite the fact that these passwords were not directly included in cracking dictionaries per se, they still relied on references to personal yet publicly available information from which you were able to draw. Professionals call this information gathering process open-source intelligence ("OSINT"), and it's often used in the construction of highly targeted attacks like these.

**If *your* password is based on, has roots in, or references relationships to any publicly-available information about yourself, even if that information is "personal" or hard to find, you've now seen how attackers can easily find that information and use it to generate huge numbers of guesses to quickly crack your passwords, too.** This combination of a wealth of publicly available information about people, wordlists, and hash cracking tools can make even the cleverest of passwords merely a wordlist rule away from being cracked within hours, if not minutes. That's why the only truly strong passwords are "random" (or, more technically, "high-entropy") passwords.

Congratulations, you are now a [*1337 h4x0r*](https://www.urbandictionary.com/define.php?term=1337%20h4x0r)! You've now hopefully cracked Tyrell's password, and can impersonate Evil Corp's Senior Vice President of Technology to the Evil Corp mail server by logging in using Tyrell Wellick's account. However, there are still Evil Corp employee passwords you've not yet cracked. If you want to totally own Evil Corp's network, and crack these remaining passwords, you can try to use a couple more advanced techniques to "make smarter guesses sooner" before you're forced to fall back to a time-consuming "brute-force" search.

* If you want to continue cracking Evil Corp account passwords, continue to [statistical hash cracking techniques](#statistical-hash-cracking-techniques).
* If you want to protect your passwords from being hacked by Tyrell Wellick, continue to [using a password manager](#using-a-password-manager).

## Statistical hash cracking techniques

> :construction: TK-TODO: Just the "basics." Remember: the focus is demonstrating why the answer is *always* "just STFU and use a password manager." That means this section should be optimized for "aha" moments, along the lines of:
> 
> Optionally, continue cracking more passwords with advanced modes such as `--loopback` and `--markov`; another "aha" moment with regards to the "smarts" of wordlists and why the only "good" passwords are *random* passwords.

## Cracking hashes with brute-force

> :construction: TK-TODO:
> 
> There will be at least one password hash that is still uncrackable, so finally, after all else fails, explain how to do an actual brute force ("incremental") search. The aha moment here is "see, this will take fucking forever, and that's the point." <-- This is what using a password manager correctly forces attackers to do.

## Using a password manager

> :construction: TK-TODO: Don't forget we also then need to write up the defense:
> 
> 1. Get a password manager. Generate a password with it. Etc.

# Discussion

## Technical errors in the Mr. Robot scene

1. Elliot only retrieves the `/etc/passwd` file, and is never shown accessing the `/etc/shadow` file. We are left to presume that we simply didn't see him grabbing that file.

> :construction: TK-TODO: Brief walkthrough of the incorrect parts of the Mr. Robot scene and screenshots.

## `passwd` versus `shadow` files

On Unix-like systems, the [`/etc/passwd` file](https://en.wikipedia.org/wiki/Passwd#Password_file) and [`/etc/shadow` file](https://en.wikipedia.org/wiki/Passwd#Shadow_file) taken together make up a local database of sorts. Numerous programs query one or both of these files to answer questions such as, "What users are permitted to login to this system?" "How long has it been since this user last changed their password?" And, of course, the all important question: "Is this the correct password for that user?"

Some information, such as the user's login name, are stored in both files. Other properties about the user are stored in only one or the other file. For instance, a user's [primary group ID](https://en.wikipedia.org/wiki/Group_identifier) and [home folder](https://en.wikipedia.org/wiki/Home_directory) location are stored in the `passwd` file but not the `shadow` file. Conversely, a user's hashed password and the date of their last password change is stored in the `shadow` file but not the `passwd` file.

In a `passwd` file, the seven fields, from left to right, are:
 
1. The account's login username. This is typically what a user would type into the "`Username`" field of a login form.
1. A symbol representing the account's login password. At one time, this field held the user's literal password. Perhaps needless to say, that is no longer standard practice. An `x` means the password is actually stored as a hash in the `shadow` file, instead.
1. The account's ID number. This is how the operating system refers to the account, internally.
1. The account's primary group ID number. This is often used to assign the user to a certain role shared by other users on the system as part of a [role-based access control](https://en.wikipedia.org/wiki/Role-based_access_control) system.
1. The user's display name. In the example above, every user's display name is identical to their login username. If I were in Tyrell's shoes, I might have updated my display name to read `Tyrell Wellick` instead of `tyrellwellick`, but to each their own.
1. The filesystem location of the account's home folder. In the example above, everyone's home is set to `/nonexistent`. This location (presumably) doesn't exist, which is the point. Setting this value to a non-existent location is the equivalent of setting "no home directory."
1. The command to run by default when (or if) the account logs in to the system interactively (i.e., with a command line). In the example above, a few accounts have this set to `/bin/sh`, but most are set to `/bin/false`. The latter case has the effect of disallowing command line access for that user.

These plain text files are not the only way a system might store this kind of information, but it was one of the first methods designed, is among the simplest, and is often still used. Other places to store equivalent information includes more complex locally-stored databases (often in [Berkeley DB](https://en.wikipedia.org/wiki/Berkeley_DB) file format) or network-accessible directories. On a typical Unix-like system, the [`nsswitch.conf(5)`](https://linux.die.net/man/5/nsswitch.conf) file determines which sources are consulted, and in which order. Other systems use different methods. (If you're on a macOS computer, look into [Apple Open Directory](https://en.wikipedia.org/wiki/Apple_Open_Directory) ([`opendirectoryd(8)`](https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man8/opendirectoryd.8.html)), while Windows users could explore the [Security Account Manager](https://en.wikipedia.org/wiki/Security_Account_Manager).)

## Hash algorithms

Over the years, [many different *hash algorithms* (or "*hash functions*") have been devised](https://valerieaurora.org/hash.html). You can think of a hash algorithm as a mathematical "recipe" that describes how to produce output with [certain cryptographic properties](https://en.wikibooks.org/wiki/Cryptography/Hashes) from any given input. Moreover, the recipe must be able to deal with *any* arbitrary input and must yield the exact same output when given the same input. Hashing algorithms must be deterministic.

Most hash algorithms yield output of a fixed size (such as the aging [MD5](https://en.wikipedia.org/wiki/MD5), [SHA-1](https://en.wikipedia.org/wiki/SHA-1), and [SHA-2](https://en.wikipedia.org/wiki/SHA-2) family of algorthms). Some newer algorithms can be directed to produce any amount of output you like (such as [SHA-3](https://en.wikipedia.org/wiki/SHA-3) and [Skein](https://en.wikipedia.org/wiki/Skein_%28hash_function%29)). A hash algorithm's output is alternately called a *digest*, *hash value*, or more simply, just a *hash*.

The act of taking some data and performing the steps of a given hash algorithm on that data is called *hashing*. Your laptop may already have some built-in tools you can use to create hashes. Since you can hash any data you like, it's very easy to create a hashed version of a password. To make the hash in this exercise's sanity check, I used [the `shasum(1)` command](https://linux.die.net/man/1/shasum) on a GNU/Linux system:

```sh
$ echo -n "Sup3rs3kr3tP@24431w0rd" | shasum --algorithm 1
ced91977849c44fd009ba437c14c1b74f632fae6  -
```

Similarly, Windows users can use [Notepad](https://en.wikipedia.org/wiki/Microsoft_Notepad) and a utility called the [File Checksum Integrity Verifier](http://support.microsoft.com/kb/841290) to create SHA-1 hashes.

Different hash algorithms have different properties. Some can be computed extraordinarily quickly (MD5 and SHA-1 fall into this category). Others take far longer to compute, and yet others were intentionally designed to be used to hash passwords or password-like data (such as [PBKDF2](https://en.wikipedia.org/wiki/PBKDF2), [scrypt](https://en.wikipedia.org/wiki/Scrypt), and [Argon2](https://en.wikipedia.org/wiki/Argon2)). This makes some hash algorithms more useful for specific purposes than others. For instance, if you are trying to protect password hashes from hash crackers, you should use an algorithm that takes a comparitively long time to compute in order to force password crackers to spend more computing power (and thus time) to crack the hashes they're targeting; the functions designed specifically for password-hashing are your best choices, here.

Unfortunately for users, and fortunately for password crackers, many systems still don't properly protect user passwords. They choose bad hashing algorithms (i.e., hash functions that run quickly), improperly handle the user's password before the hash function is applied, and in [the worst cases simply don't bother hashing the password](http://plaintextoffenders.com/) at all! One sure-fire way to recognize the latter case is when a website or service simply emails your password back to you when you use its "I forgot my password" feature; if the service can email you the password you used in plain text, it means they never bothered hashing your password in the first place. Yikes!

## Hash string formats

Tyrell Wellick's account password hash value is not *merely* a hash algorithm's output. The raw hash output is there, yes, but it's stored along with some additional metadata that has been prepended as part of a longer *hash string*. The full hash string for Tyrell's password in the `shadow` file is:

```
$6$ge7W6aVQ$dhJxmLt2qD964d8GXD7Z53EkxxKfe08LVRBNVZ5Xbg.YXXwgIagzJ9bRB.QUcgvOsdrhitXsTf0MbGY7S1sH60
```

A hash string, like this one, is composed of three separate parts. They're not really "fields" in the proper sense because there's no formal, universally agreed upon standard way of denoting the parts. The closest thing to a standard is the popular [Modular Crypt Format](https://pythonhosted.org/passlib/modular_crypt_format.html) specification and the more recent [Password Hashing Competition (PHC) String Format](https://github.com/P-H-C/phc-string-format/blob/master/phc-sf-spec.md) specification.

The parts of a hash string are more-or-less delimited by dollar signs (`$`). From left-to-right, those parts are:

1. The *hash prefix* (or *hash identifier*), which is a short alphanumeric string in between dollar signs. In this hash, it's `$6$`, which generally indicates SHA-512 Crypt.
1. Next comes the salt value, which continues until the next dollar sign. In this hash, that's the `ge7W6aVQ` part.
1. The remainder of the field is the hashing algorithm's output, sometimes called the *digest*. This is the value `john` compares to its own output after concatenating the salt value with each of our guesses and performing the computation specified by the hash algorithm.

## Salted versus unsalted hashes

Part of the usefulness of adding salt to a password in order to produce a *salted hash* is that it forces attackers like us to go through this hash cracking process each time we want to crack a different user's password. If a system hashed a user's password without adding any salt, then the hashes for two different accounts that happened to have the same password would be exactly the same. Worse, this would even be true of two user accounts across completely unrelated systems, if those systems happened to use the same hash algorithm.

Without salting hashes, assuming we already cracked one account, we could instantly recognize the password of any other account that used the same password just by reading the hash value. In other words, we would learn the password without having to perform the laborious process of actually computing its hash. That defeats the whole point of hashing in the first place.

Furthermore, many huge, public, free lookup databases of previously-computed (or previously-encountered) hashes and their original inputs exist online. One such popular database is at [CrackStation.net](https://crackstation.net/). These databases of precomputed hashes and their corresponding original inputs are called [rainbow tables](https://en.wikipedia.org/wiki/Rainbow_table). Some even larger rainbow tables are accessible, for a fee.

## Generating custom wordlists automatically

> :construction: TK-TODO: Briefly describe the installation and use of `cewl` and `crunch`.

* [Generating Wordlists](https://netsec.ws/?p=457) - use `cewl` to generate a custom wordlist by spidering a website.
* [Making a Perfect Custom Wordlist Using Crunch](https://thehacktoday.com/making-perfect-custom-wordlist-using-crunch/) - use `crunch` to automate the process of composing large wordlists, see espeically the `-t` option.

# Additional references

* [Ars Technica: How I became a password cracker](https://arstechnica.com/security/2013/03/how-i-became-a-password-cracker/)
* [How crackers ransack passwords like “qeadzcwrsfxv1331”](https://arstechnica.com/security/2013/05/how-crackers-make-minced-meat-out-of-your-passwords/)
* [Password Haystacks: How Well-Hidden is Your Needle?](https://www.grc.com/haystack.htm)
* [Hashcat: Advanced Password Recovery](https://hashcat.net/) - a popular alternative to John the Ripper
* [Blog post by g0tmi1k about what makes for a good password cracking wordlist](https://blog.g0tmi1k.com/2011/06/dictionaries-wordlists/)
* [Making password complexity calculations](https://www.youtube.com/watch?v=R-UFOXDxe4w&t=1h54m10s).

