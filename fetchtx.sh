#!/bin/bash
#Copyright Alex English September 2018
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Ubuntu 17.10
#Make sure you have a correct path set for the verus cli

#fetch complete transaction data for the given TXID passed as first and only argument
#There didn't seem to be a way to get this directly for transactions not stored in the wallet, so this wraps a couple RPC calls together to get it.

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

$VERUS decoderawtransaction "$($VERUS getrawtransaction "$1")"
