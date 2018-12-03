# IWS
Internet and Web Systems - UMass Lowell
# Mystiko

[Mystiko](https://chrome.google.com/webstore/detail/mystiko/elgebokhcmefncfkfejmgdppipfhjgeh) is a Chrome extension designed to make passwords management easier. It will automatically generate a unique and secure password for every website and it is going to be different for each website that makes your passwords more secure.

The main advantage of this tool is, it is stateless. That means, there is no server behind this application which makes sure that our passwords are never stored anywhere. It is calculated on the go.

## Installation

Install Mystiko from the Chrome App Store ([link](https://chrome.google.com/webstore/detail/hashpass/gkmegkoiplibopkmieofaaeloldidnko)). You will then see the Mystiko icon next to your address bar.

## Compatible implementations

In addition to the chrome extension, there is also a website developed for this tool which makes your password available even when you dont have access to your chrome extension.
http://weblab.cs.uml.edu/~nchandra/513_f2018/



## A quick tour

Click the Hashpass button and this will pop up:

![Screenshot](https://raw.githubusercontent.com/boyers/hashpass/master/screenshot1.png)

Hashpass generates a password based on your key and the current domain. Usually you will want to select a password field first. Then Hashpass doesn't show the generated password, giving you the option to fill in the field instead:

![Screenshot](https://raw.githubusercontent.com/boyers/hashpass/master/screenshot2.png)

## How passwords are generated

Lets say your master key password is `bananas` and you are registering for a website lets say drop box. Mystiko combines the domain name and the master key and puts a `/` between them and creates a key as follows: `www.dropbox.com/test`. This string is hashed again and again for `2^16` and then the first 16 characters of the result value will be used as the password. So for the above case the final passowrd will be `cAj8weKzHMRfVGwq`.

## Security

If someone gets your password, it is impossible for them to backtrack to your master key because of the hashing algorithm.

One strategy for cracking your secret key is to try hashing all English words, for example. This is called a *dictionary attack*. An attacker might even try to pre-compute the hashes of all English words and other common passwords. Then they could simple look up hashes in this hash table to crack them. The table in this attack is called a *rainbow table*.

A brute force attack is practically impossible with the current computational power available.
