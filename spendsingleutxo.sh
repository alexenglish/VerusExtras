#!/bin/bash
#Copyright Alex English February 2021
#This script comes with no warranty whatsoever. Use at your own risk.

#spend a single UTXO to a single address, minus the fee
#arguments are:
#1: txid
#2: vout
#3: address to send to

FEE=0.0001

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

#Dependencies: jq (command-line json parser/editor), bc (command-line calculator)
if ! command -v jq &>/dev/null ; then
    echo "jq not found. please install using your package manager."
    exit 1
fi

if ! command -v bc &>/dev/null ; then
    echo "bc not found. please install using your package manager."
    exit 1
fi

if [ $# -ne 3 ]; then
    echo "Two arguments required:"
    echo "First argument is an array of objects with txids and vouts - '[{"txid":"xxxx...xxxx","vout":n},...]'"
    echo "Second argument is an object addresses as keys and amounts as values - '{"Rxxx...xxx":n.nnn,...}'"
    exit 1
fi

#no error checking on the inputs, it either works or fails - exit on error
set -e

#determine the amount
AMT="$($VEPATH/fetchtx.sh "$1" | jq -r ".vout[] | select(.n==$2).value")"
#This will willingly send 0 VRSC if the UTXO is 0.0001 VRSC
if [ "$(bc<<<"$AMT<$FEE")" -gt 0 ]; then
    echo "UTXO is smaller than the standard transaction fee, not going to send."
    exit 1
fi
AMT=$(bc<<<"$AMT-$FEE")

#the first argument is the json input to createrawtransaction, an array of objects containing txids and vouts
#the second argument is the json list of outputs, a single object with addresses as keys and amounts as values
./spendutxos.sh '[{"txid":"'"$1"'","vout":'"$2"'}]' "{\"$3\":$AMT}"
