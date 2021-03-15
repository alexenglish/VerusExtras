#!/bin/bash
#Copyright Alex English January 2021
#This script comes with no warranty whatsoever. Use at your own risk.

#First argument is the file you'd like to check
#Second argument is the name of the signature file - if no second argument is provided it will use a default of the input file plus .signature.txt

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/../config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

#depends on jq
if ! command -v jq > /dev/null ; then
	echo "jq not installed - please install jq, command line json tool"
	exit 1
fi

F="$1"
S="$2"
D="$F.signature.txt"
S="${S:-$D}"

SIGNER="$(jq -r '.signer' "$S")"
SIG="$(jq -r '.signature' "$S")"

#TODO - add a check to see if $F starts with a /, to use as an absolute path and not include pwd
PATH="$(pwd)/$F"

result="$($VERUS verifyfile "$SIGNER" "$SIG" "$PATH")"

if [ "$result" == "true" ]; then
    echo "Valid Signature by: $SIGNER" >&2
    exit 0
else
    echo "Invalid Signature" >&2
    exit 1
fi
