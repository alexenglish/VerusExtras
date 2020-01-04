#!/bin/bash
#Copyright Alex English September 2018
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Ubuntu 17.10
#Make sure you have a correct path set for the verus cli

#fetch UTXOs for an address - this is just a wrapper for the getaddressutxos command to sipmlify the syntax
#pass an address as the first and only argument

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

#need to add error checking to make sure we have exactly one address

$VERUS getaddressutxos '{"addresses": ["'$1'"]}'
