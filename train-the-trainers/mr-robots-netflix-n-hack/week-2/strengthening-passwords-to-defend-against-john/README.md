# Strengthening Passwords to Defend Against John

In this exercise we will obtain the password of an unsuspecting user by cracking the hashed copy of that user's password. Then we will use a password manager to strengthen our own passwords in order to protect against the same sorts of attacks in the future. Our goal is to understand why and how password management software makes having a digital life both safer and easier at the same time.

1. [Objectives](#objectives)
1. [Scenario](#scenario)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
    * [Installation on Windows](#installation-on-windows)
    * [Installation on macOS](#installation-on-macos)
    * [Installation on GNU/Linux](#installation-on-gnulinux)
1. [Practice](#practice)
    1. [Introduction](#introduction)
    1. [Sanity check](#sanity-check)
1. [Discussion](#discussion)
    * :construction: TK-TODO: Fill in this part of the TOC.
1. [Additional references](#additional-references)

# Objectives

When you complete this exercise, you will have acquired the following capabilities:

* The ability to make and use passwords for your user accounts that are practically invincible against many attackers.
* The ability to replace old passwords with strong new passwords easily, on whatever schedule you want.
* The ability to determine other users's original passwords, if theirs are weak, despite sophisticated attempts to protect them.
* The ability to guage the approximate relative strength of a password using only "the naked eye."

# Scenario

[![Hacking Tyrell Wellick scene, using the `john` password cracker.](https://web.archive.org/web/20161213025246/https://hackertarget.com/mrrobot/wget-shellshock-john.png)](Mr.%20Robot%20S01E02%20-%20Hacking%20Tyrell%20Wellick.mp4?raw=true)

> Hacking Tyrell Wellick, you'd think it'd be tricky but it wasn't. Evil Corp's corporate mail servers? They haven't patched anything since Shellshock. He doesn't even use two-step verification. His password was just his wife's maiden name and Sweden's independence date, `66`. One "six" away from the obvious, but still. This is bad noob practice.

You are Elliot Alderson, ordinary cybersecurity engineer by day, vigilante hacker by night. In order to uncover Evil Corp's next nefarious plot, you must hack into the corporate email account of their Senior Vice President of Technology, Tyrell Wellick. Fortunately for you, Evil Corp's mail servers run a webmail system vulnerable to an exploit called Shellshock, which has enabled you to obtain a file listing the usernames and passwords of everyone who uses the system. However, the passwords are obfuscated using a one-way mathematical function called a *hash* (or *digest*).

In order to recover the password, you must "crack" its hashed equivalent, revealing the original. Once cracked, you may impersonate Tyrell Wellick to the Evil Corp mail server by using his username and password to log in as him, thereby gaining access to his emails. Moreover, to make sure that Tyrell Wellick is unable to hack you back, you must set all your online accounts to use "uncrackable" passwords to protect yourself against the very same attack.

# Prerequisites

To participate in this exercise, you must have:

* A computer running any modern version of:
    * Windows,
    * macOS, or
    * any flavor of the GNU/Linux operating system.
* An active Internet connection (for downloading the required tools in the [set up](#set-up) step; you do not need an Internet connection once you have the tools installed).

> :beginner: :computer: This exercise requires the use of a command line (or terminal). If you don't know what that means, or if you do but you feel intimidated by that, consider spending an hour at [Codecademy's Learn the Command Line interactive tutorial](https://www.codecademy.com/learn/learn-the-command-line) (for GNU/Linux or macOS users) or reviewing [Computer Hope's How to use the Windows command line (DOS) article](http://www.computerhope.com/issues/chusedos.htm) (for Windows users). You don't need to complete their tutorial or article to understand this exercise, but it will dramatically improve your comprehension of this exercise's mechanics.

# Set up

In addition to your laptop or desktop computer, you will need to acquire the following tool:

* [John the Ripper password cracker](http://www.openwall.com/john/), sometimes written as *JtR*

A number of different installation procedures are available. If you're comfortable doing so, you can follow the above link, download, and install the software configuration of your choosing. (See [Beginner's Guide to Installing from Source](http://moi.vonos.net/linux/beginners-installing-from-source/) if you're not comfortable, but want to try that anyway.) The rest of this section will describe more common approaches to installing John the Ripper in a little more detail.

## Installation on Windows

Two pre-built Windows versions of John the Ripper are available. One is an "official" build, compiled by the tool's original developers, and the second is a "community-enhanced" build, which bundles (literally) hundreds of additional features written by volunteers into the application itself. For the purposes of this exercise, it does not matter which version you choose to get. To install John the Ripper, take the following steps:

**Do this:**

1. Go to [the John the Ripper homepage](http://www.openwall.com/john/).
1. Download the Windows version of your choice. At the time of this writing, these are:
    * [John the Ripper 1.8.0-jumbo-1 community-enhanced version for Windows](http://www.openwall.com/john/j/john180j1w.zip) (recommended)
    * [John the Ripper 1.7.9 official free version for Windows](http://www.openwall.com/john/h/john179w2.zip)
1. Unzip the file. Usually, this is as simple as right-clicking on it and selecting *Extract All* from the context-menu. (See [the Windows Help "Compress and uncompress files (zip files)" article](https://support.microsoft.com/en-us/help/14200/windows-compress-uncompress-zip-files).)
    * This will produce a folder, inside of which is another folder named `run`. Inside *that* folder is a file called `john` (or `john.exe` if your computer is [set to display file extensions](http://www.computerhope.com/issues/ch000573.htm)). That file is the main John the Ripper application. Unlike most Windows applications, this program must be run [using the Windows Command Prompt](http://www.computerhope.com/issues/chusedos.htm); you cannot simply double-click it. However, `john.exe` is now successfully "installed."

## Installation on macOS

A pre-built macOS version of John the Ripper is available for modern Apple Macintosh computers, that is, Macs with an Intel processor. (See [About System Information on your Mac](https://support.apple.com/en-us/HT203001) to learn how to find out what processor your Mac has.) If you have such a Mac, then to install John the Ripper, take the following steps.

**Do this:**

1. Go to [John the Ripper's macOS community-contributed builds page](http://download.openwall.net/pub/projects/john/contrib/macosx/).
1. Download the latest archive file available. (As of this writing, that is [`john-1.7.9-jumbo-7-macosx-Intel-2.zip`](http://download.openwall.net/pub/projects/john/contrib/macosx/john-1.7.9-jumbo-7-macosx-Intel-2.zip).)
1. Unzip the file. Usually, this is as simple as double-clicking on it.
    * This will produce a folder, inside of which is another folder named `run`. Inside *that* folder is a file called `john`. That file is the main John the Ripper application. Unlike a classic macOS application, this program must be run [using the Terminal](http://guides.macrumors.com/Terminal); you cannot simply double-click it. However, `john` is now successfully "installed."

## Installation on GNU/Linux

> :construction: TK-TODO: These instructions are currently missing. Please add them!

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

Recovering passwords is generally accomplished in one of two ways. The approach we'll be taking in this exercise, *offline hash cracking*, is by far the more common of the two. We say it is "offline" because we do it entirely on our own computer, without needing an active network connection, after already acquiring the "hashed" password(s) through some other means. The alternative to this approach, *online password guessing*, is said to be "online" because it's as simple as repeatedly attempting to log in to an active, remote system, such as an email service or online banking website. Of course, most websites don't allow visitors to try logging in to an account too many times. After some number of failed guesses, they will usually lock out the account. Besides, it would be unbearably slow to have to reload the login page over and over again after each guess. Therein lies the key concept: speed.

A password can, theoretically, be any sequence of characters at all. In practice, many systems place limits on what they consider valid passwords, or limit the length of the password. For instance, many websites require your password to be "between 4 to 12 characters, and must contain only letters, numbers, or punctuation marks," or something like that. The set of possibilities that a given password might be is called a *search space*. Given infinite time, it would be a simple matter of trying every single possibility until one of your guesses is right. This technique is called a *brute force search*. In practice, however, we never have anything close to infinite time. If it took us, say, two hundred years to find Tyrell Wellick's password, we would be long dead, Evil Corp's nefarious plan will surely have gone unopposed, and we have still not even gotten close to infinite time!

This means, to be successful, we only have two techniques available to us:

* Guess more passwords faster.
* Make smarter guesses sooner.

Guessing more passwords faster is pretty intuitive: the faster we can make guesses, the less time it will time to perform an exhaustive, brute-force search. This is simply a function of what computer you have. The better, faster, stronger, more expensive your computers are, the more guesses you can make per second. Making smarter guesses sooner involves much more subtlety, so that's where we'll be focusing the majority of our time in this lab.

### Sanity check

First, let's make sure you successfully installed John the Ripper (JtR) and that its `john` program is working correctly. We'll do this by giving `john` two files. One file contains a fictional username and hashed password combination. The second file will contain the correct password. Given these two files, `john` should be able to apply the password guess to the hashed version of the password in the other file and tell us that the guess in the other file is correct.

The file containing the username and password pair is called `sanitycheck.password.txt`. It contains one line that looks like this:

```
fsociety:ced91977849c44fd009ba437c14c1b74f632fae6
```

On the left, at the start of the file, is a username. In this case, that's `fsociety`. Then there is the *field separator* character, a colon (`:`). Finally, there is the *hash value*. That hash is the obfuscated version of the password we need to guess.

> :beginner: If you've never encountered a "hash" in this context before, this exercise might seem complex already. Searching the Internet for "hash" probably reveals more pages about cannabis than computer security at first, but adding "computer" to your searches will get you [many](http://www.webopedia.com/TERM/H/hashing.html), [many](http://unixwiz.net/techtips/iguide-crypto-hashes.html), [many](https://en.wikipedia.org/wiki/Hash_function) more [relevant results](http://www.computerhope.com/jargon/h/hashing.htm). Another tip for beginners, especially if you've found the regular Wikipedia article impenetrable, is to check if there is a "simple" version of the Wikipedia page. In this case, you're in luck: the [Simple Wikipedia article for "Cryptographic hash function"](https://simple.wikipedia.org/wiki/Cryptographic_hash_function) is relatively straightforward by comparison.
> 
> In the end, a "hash" in the context of computer security is simply a value that ("cryptographically") represents some other value. The idea, in theory, is that two different original values will never be represented by the same two ultimate values after they have been "hashed," and that it is infeasible to recover the original value from the hashed value. ([Watch these few minutes from "Crypto 101"](https://www.youtube.com/watch?v=3rmCGsCYJF8&t=20m6s) for a further explanation and some pictures depicting this.) In practice, however, weaknesses in cryptographic hash functions (whether by design due to flaws in their algorithm, or by mistakes introduced through their actual implementation) sometimes result in two different values being hashed to the same value. When this happens, the hash function is said to be "cryptographically broken," because if you can hash two different values and get the same resulting value (a situation known as a *hash collision*), then there is little point to the hash from a security perspective in the first place.
> 
> For the purposes of this exercise, we will assume there are no flaws in the hashing algorithm. In reality, this "sanity check" hash value uses a cryptographically broken algorithm called [SHA-1](https://en.wikipedia.org/wiki/SHA-1). To learn more about how SHA-1 is broken, and how to construct a *hash collision attack* yourself, read [Boston Key Party 2017 CTF: Prudentialv2](https://github.com/meitar/CTF/blob/master/2017/BKP/cloud/Prudentialv2/README.md).

The file containing our guesses is called `sanitycheck.wordlist.txt`. It contains four lines and looks like this:

```
randomGuess
alsoWrong
Sup3rs3kr3tP@24431w0rd
someotherword
```

Each guess is written on its own line. We call each guess a *word*, even if there are multiple human-language words on a single line. We call the whole file a *wordlist*, or sometimes a *dictionary* (because it is a "list of words," of course).

When we give the wordlist to `john`, what we're doing is asking `john` to hash each of these "words" one at a time and then compare the resulting hash value to the hash value stored in the password file. When `john` finds a word in the wordlist that hashes to the same hash value as the hashed password, it will tell us that it found a match. When we find a matching value, we say we have "*cracked* the hash."

If `john` is working correctly, we can expect that the third word in the wordlist, `Sup3rs3kr3tP@24431w0rd`, will result in a match. If that guess were missing (as it is in the `sanitycheck.no-crack.wordlist.txt` file), we would expect to see `john` report its failure to find any matches.

> :beginner: It's very easy to create a hashed version of a password, or any content, such as an arbitrary file. To make the hash in this sanity check (`ced91977849c44fd009ba437c14c1b74f632fae6`), I used [the `shasum(1)` command](https://linux.die.net/man/1/shasum) on a GNU/Linux system:
> 
> ```sh
> $ echo -n "Sup3rs3kr3tP@24431w0rd" | shasum --algorithm 1
> ced91977849c44fd009ba437c14c1b74f632fae6  -
> ```
> 
> Then I just copy-and-pasted the resulting hash into the password file.

To perform the sanity check, we'll use this command invocation:

```sh
./john --wordlist=sanitycheck.wordlist.txt sanitycheck.password.txt
```

Breaking this invocation down:

* The first part, `./john`, runs the program `john` in the current directory (`./`).
* The first option, `--wordlist`, tells JtR to read its guesses from the file given by the value (`=`) of the option, in this case the contents of the file `sanitycheck.wordlist.txt`.
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

> :bulb: We can quiet these "warnings" by telling `john` to use a specific hash algorithm. We do this by passing the `--format` option and setting the option's value to a specific algorithm's name. You can ask `john` for a list of all the algorithm names it knows about by invoking it with no options. This will print some basic help. Look for the `--format` option in that output to read a list of hash format names `john` recognizes.
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

Here, `john` informs us that it found one hash in the password file ("`Loaded 1 password hash`"), along with the type of hashing algorithm it suspects (or that we told it) the hash was made with ("`Raw SHA-1`"). On the next line, we see the expected correct guess (`Sup3rs3kr3tP@24431w0rd`), which `john` reports as the plain-text, unobfuscated version of the password associated with the user `fsociety`. Finally, we see the number of *successful* guesses made (`guesses: 1`), the amount of time it took (`time:`), the fact that we have in fact completed making all guesses (`DONE`), and the time of completion (in this example, shown as `(Tue Mar 14 14:18:13 2017)`). Finally, the current range of password candidates being guessed is reported, shown here as "`trying: randomGuess - someotherword`." Indeed, `randomGuess` was our first guess, listed at the start of our wordlist, and `someotherword` was our last one, listed at the wordlist file's end. Notice that these guesses were attempted in order, from top to bottom. That's important because it means we should place "smarter" guesses, the guesses we think are more likely to successfully crack a hash, nearer to the top of our wordlist file.

> :bulb: There is also some [additional information](http://www.openwall.com/john/doc/FAQ.shtml) in the report. For instance, we're also told that, on this run, `john` is using an [Intel processor feature called SSE2](https://en.wikipedia.org/wiki/SSE2) in an attempt to work as fast as possible. We also see a speed report, shown as "combinations per second" (`c/s`). There are many ways to benchmark `john`'s speed, and to tune it, in order to optimize the "guess more passwords faster" technique.

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

Rather than start a cracking session, `john` simply checks the password file we gave it (same as before, "`Loaded 1 password hash`") but then immediately reports "`No password hashes left to crack (see FAQ)`." This is happening because `john` remembers both this specific password hash file *and* the fact that we have already correctly guessed the password corresponding to the hash inside of it. John the Ripper maintains a list of successfully cracked hashes in a so-called pot. This is literally a file called `john.pot` and it will have appeared in the the `run` folder after the previous invocation of `john`. We can open `john`'s `.pot` file with any graphical text editor or have a look at its contents using [the `cat(1)` command](https://linux.die.net/man/1/cat) on a GNU/Linux or macOS terminal, or [the `type` command](https://technet.microsoft.com/en-us/library/bb491026.aspx) in a Windows Command Prompt:

```sh
$ cat john.pot
$dynamic_26$ced91977849c44fd009ba437c14c1b74f632fae6:Sup3rs3kr3tP@24431w0rd
```

> :bulb: The format of this line is JtR-specific, but closely resembles the syntax used by the [Modular Crypt Format](https://pythonhosted.org/passlib/modular_crypt_format.html). See the `doc/DYNAMIC` file in the official John the Ripper source distribution for details.

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

> :construction: TK-TODO: Just the "basics." Remember: the focus is demonstrating why the answer is *always* "just STFU and use a password manager." That means this section should be optimized for "aha" moments, along the lines of:
> 
> 1. Get the files, have a quick look at them to, y'know, understand them.
> 1. `unshadow` the files (maybe unnecessary/distracting for educational purposes?)
> 1. Do the thing! (`john --wordlist=mywordlist.list the_file_with_hashes_to_crack_`)
>     * Provide "mywordlist.list" with this repo, as an example file. But *also*,
>     * point out that other wordlists exist, dramatic-dot-dot-dot.
> 1. Tell students to go get their own, better wordlist. ("rockyou"?)
>     * Doing `john --wordlist=rockyou.txt` or whatever should produce several more password hits, which is an "aha" moment.
> 1. Do the thing again, this time with `--rules` and so on.
>     * This should crack maybe one or two more passwords, again, to provide that "aha" moment for what `--rules` are and do.
> 1. Finally, introduce the idea that we can devise our own password guessing strategies, write our own rules files, etc.
>     * Doing this correctly should reveal yet another couple of passwords; have the passwords be Mr. Robot themed but the rules common (adding numbers at the end, 1337 speak, and so on).
> 
> Obvi, we already "know" Tyrell's password so doesn't really matter if we actually crack his. But it's good that we already know is that students can "check their work" against a known quantity.
> 
> Don't forget we also then need to write up the defense:
> 
> 1. Get a password manager. Generate a password with it. Etc.

# Discussion

## Differences between the practice lab and the Mr. Robot episode

> :construction: TK-TODO: Brief walkthrough of the incorrect parts of the Mr. Robot scene and screenshots.

## Calculating password strength

[A couple tricks for password complexity calculations](https://www.youtube.com/watch?v=R-UFOXDxe4w&t=1h54m10s).

## `passwd` versus `shadow` files

> :construction: TK-TODO: A brief discussion of `/etc/passwd` and why that's not quite enough to get at password hashes, as well as some more brief explanations of the file formats (though see `passwd(5)` and `shadow(5)` for more info).

## `crypt(3)` formatted hash strings

> :construction: TK-TODO: Some more detailed explanations of that somewhat complex-looking hash string, and how it's not *just* a hash output. See also Modular Crypt Format and PHC String Format, linked in the [references](#additional-references) section.

# Additional references

* [Ars Technica: How I became a password cracker](https://arstechnica.com/security/2013/03/how-i-became-a-password-cracker/)
* [Modular Crypt Format](https://pythonhosted.org/passlib/modular_crypt_format.html)
* [PHC String Format](https://github.com/P-H-C/phc-string-format/blob/master/phc-sf-spec.md)
* [Password Haystacks: How Well-Hidden is Your Needle?](https://www.grc.com/haystack.htm)
* [Hashcat: Advanced Password Recovery](https://hashcat.net/) - a popular alternative to John the Ripper
