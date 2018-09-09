#!/bin/bash
#Copyright Alex English September 2018
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Ubuntu 17.10
#Make sure you have a correct path set for the verus cli

#fetch UTXOs for an address - this is just a wrapper for the getaddressutxos command to sipmlify the syntax
#pass an address as the first and only argument

VERUS=~/verus-cli/verus

if [ ! -x $VERUS ]; then
    echo "It looks like $VERUS doesn't exist, or isn't executable. Edit the value of VERUS on line 6 to reflect an accurate path to the Verus CLI RPC executable."
    exit 1
fi

../fiat/verus getaddressutxos '{"addresses": ["'$1'"]}'
