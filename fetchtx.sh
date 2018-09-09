#!/bin/bash
#Copyright Alex English September 2018
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Ubuntu 17.10
#Make sure you have a correct path set for the verus cli

#fetch complete transaction data for the given TXID passed as first and only argument
#There didn't seem to be a way to get this directly for all transactions, so this wraps a couple RPC calls together to get it.

VERUS=~/verus-cli/verus

if [ ! -x $VERUS ]; then
    echo "It looks like $VERUS doesn't exist, or isn't executable. Edit the value of VERUS on line 6 to reflect an accurate path to the Verus CLI RPC executable."
    exit 1
fi

../fiat/verus decoderawtransaction "$(../fiat/verus getrawtransaction "$1")"
