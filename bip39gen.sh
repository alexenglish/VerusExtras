#!/bin/bash
#Copyright Alex (Lex) English, March 2023
#This script comes with no warranty whatsoever. Use at your own risk!
#Tested on Debian 11

#This is intended to provide a way to safely generate bip39 compatible seed phrases on-or-offline from the command line.
#To utilze them in Verus you can use `verus convertpassphrase <your word list here>` to generate your address, keys, and wallet-import-format (WIF). The WIF can be added to your verus wallet using `verus importprivkey <WIF>`.
#This script is only safe if your operating system can provide trustworthy randomness. But the same would apply to any other key generation mechanism.
#Only the passphrase is printed to STDOUT, so you can pipe or redirect this output and only get the passphrase.
WORDLIST="$(dirname "${BASH_SOURCE[0]}")/lib/bip39list.txt"

cat <<EOF 1>&2
Use with caution - only trust this seed phrase generation if you trust the randomness available on the device you're running it on.
Please enter some text, numbers, and/or symbols as a bit of personal entropy, as much as you like, pressing Enter/return will end the collection.
This will be contributed to the entropy in your operating system, it is not the primary basis for your passphrase.
What you enter will be of no use in the future. Your security will be best if you do not enter anything memorable and do not document it.
If you leave this empty you'll still have all the quality of randomness your OS provides, which is probably sufficient on its own.
This is primarily for safety on low-entropy systems like some single-board computers. Review the the source of this file and use at your own risk.

To use this seed phrase to generate a Verus R-address (and public/private keys), use \`verus convertpassphrase "<24-word seed phrase>"\`.

->
EOF

read ENT
echo 1>&2

#keyboard interrupt timing while typing added to entropy along with all the deeper OS factors - network packet timing, device statuses and IDs, device temperatures, etc.
# supply the text itself as entropy
cat <<<"$ENT" > /dev/random

U=3
#select random words
#loop until we don't have more than two occurrences of a word in our phrase (this is usually the first time)
while [ $U -gt 2 ]; do
	WORDS=$(for N in `seq 1 2048`; do shuf "${WORDLIST}" --random-source=/dev/random ; done | shuf --random-source=/dev/random | shuf --random-source=/dev/random -n 24)
	U=$(sort <<<"$WORDS" | uniq -c | awk '{print $1}' | sort -n | head -n1)
done

#shuffle the words and build the phrase
PHRASE=$(shuf --random-source=/dev/random <<<"$WORDS" | tr "\n" ' ' | sed 's/ $/\n/')

printf "$PHRASE\n"
