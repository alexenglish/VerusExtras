#!/bin/bash
#Copyright Alex English February 2021
#This script comes with no warranty whatsoever. Use at your own risk.

#spend UTXOs for an address - this is just a wrapper to simplify the raw transaction process
#the first argument is the json input to createrawtransaction, an array of objects containing txids and vouts
#the second argument is the json list of outputs, a single object with addresses as keys and amounts as values
#whatever value from the inputs isn't accounted for in the outputs becomes your fee, so calculate your fee accordingly and be careful not to give all your money to the miners/stakers

set -e

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

#Dependencies: jq (command-line json parser/editor)
if ! command -v jq &>/dev/null ; then
    echo "jq not found. please install using your package manager."
    exit 1
fi

if [ $# -ne 2 ] || ! jq '.' <<<"$1" &> /dev/null || ! jq '.' <<<"$2" &> /dev/null; then
    echo "Bad number of arguments or json did not validate"
    echo "Two arguments required:"
    echo "First argument is an array of objects with txids and vouts - '[{"txid":"xxxx...xxxx","vout":n},...]'"
    echo "Second argument is an object addresses as keys and amounts as values - '{"Rxxx...xxx":n.nnn,...}'"
    echo "Be careful, whatever value isn't sent to outputs becomes your fee."
    exit 1
fi

#no error checking on the inputs, it either works or fails - exit on error
HEX=$($VERUS createrawtransaction "$1" "$2")
SIGNED="$($VERUS signrawtransaction $HEX)"
$VERUS sendrawtransaction "$(jq -r '.hex' <<<"$SIGNED")"
