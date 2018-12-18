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


## How passwords are generated

Lets say your master key password is `bananas` and you are registering for a website lets say drop box. Mystiko combines the domain name and the master key and puts a `/` between them and creates a key as follows: `www.dropbox.com/test`. This string is hashed again and again for `2^16` and then the first 16 characters of the result value will be used as the password. So for the above case the final passowrd will be `cAj8weKzHMRfVGwq`.

## Security

If someone gets your password, it is impossible for them to backtrack to your master key because of the hashing algorithm.

One strategy for cracking your secret key is to try hashing all English words, for example. This is called a *dictionary attack*. An attacker might even try to pre-compute the hashes of all English words and other common passwords. Then they could simple look up hashes in this hash table to crack them. The table in this attack is called a *rainbow table*.

A brute force attack is practically impossible with the current computational power available.


Link for the webpage:http://www.cs.uml.edu/~nchandra/513_f2018/
Link for the chrome extension:https://chrome.google.com/webstore/detail/mystiko/elgebokhcmefncfkfejmgdppipfhjgeh

## References
1. https://www.itninja.com/question/how-to-package-and-deploy-chrome-extension
2. https://github.com/bitwiseshiftleft/sjcl
3. https://docker-curriculum.com/
4. https://www.linkedin.com/pulse/serve-static-files-from-docker-via-nginx-basic-example-arun-kumar/
5. https://www.sitepoint.com/create-chrome-extension-10-minutes-flat/
6. https://crypto.stanford.edu/sjcl/
7. https://medium.freecodecamp.org/how-to-create-a-chrome-extension-part-1-ad2a3a77541
8. http://www.adambarth.com/experimental/crx/docs/external_extensions.html
9. https://usersnap.com/blog/develop-chrome-extension/
10. https://hub.docker.com/r/navaneethcsiva/iws/
11. http://dennisspan.com/deploying-google-chrome-extensions-using-group-policy/
12. https://circleci.com/blog/continuously-deploy-a-chrome-extension/
