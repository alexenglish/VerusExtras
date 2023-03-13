#!/bin/bash
#Copyright Alex (Lex) English, March 2023
#This script comes with no warranty whatsoever. Use at your own risk!
#Tested on Debian 11

#This is intended to provide a way to safely generate bip39 compatible seed phrases on-or-offline from the command line.
#To utilze them in Verus you can use `verus convertpassphrase <your word list here>` to generate your address, keys, and wallet-import-format (WIF). The WIF can be added to your verus wallet using `verus importprivkey <WIF>`.
#This script is only safe if your operating system can provide trustworthy randomness. But the same would apply to any other key generation mechanism.
#Only the passphrase is printed to STDOUT, so you can pipe or redirect this output and only get the passphrase.

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

cat <<EOF 1>&2
Use with caution - only trust this seed phrase generation if you trust the randomness available on the device you're running it on.
Please enter some text, numbers, and/or symbols as a bit of personal entropy.
This will be contributed to the entropy in your operating system, it is not the primary basis for your passphrase.
What you enter will be of no use in the future. Your security will be best if you do not enter anything memorable and do not document it.
You can also pipe something into this script rather than entering text yourself, just perhaps don't pipe in random output from your OS or you're defeating the purpose.
If you leave this empty you'll still have all the quality of randomness your OS provides, which is probably sufficient on its own.
This is primarily for safety on low-entropy systems like some single-board computers. Review the the source of this file and use at your own risk.

->
EOF

read ENT
message

#keyboard interrupt timing while typing added to entropy - supply the text itself as entropy
cat <<<"$ENT" > /dev/random
#supply the hash of a random readable file from /tmp as entropy
sha512sum "$(find /tmp -readable -type f 2>/dev/null | shuf -n1)" 2>/dev/random | cut -d' ' -f1 > /dev/random

U=3
#select random words
#loop until we don't have more than two occurrences of a word in our phrase (this is usually the first time)
while [ $U -gt 2 ]; do
	WORDS=$(for N in `seq 1 2048`; do shuf "${VEPATH}/lib/bip39list.txt"; done | shuf | shuf --random-source=/dev/random -n 24)
	U=$(sort <<<"$WORDS" | uniq -c | awk '{print $1}' | sort -n | head -n1)
done

#shuffle the words and build the phrase
PHRASE=$(shuf --random-source=/dev/random <<<"$WORDS" | tr "\n" ' ' | sed 's/ $/\n/')

printf "$PHRASE\n"
