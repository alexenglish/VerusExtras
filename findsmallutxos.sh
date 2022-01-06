#!/bin/bash

#Copyright Alex English July 2021
#This script comes with no warranty whatsoever. Use at your own risk.                                                        
#Tested on Ubuntu 18.04
#This script counts the number of UTXOs in each address that are below a given threshold
#The first and only argument is the size threshold for the UTXOs, it defaults to 5000 if not specified
#The addresses with high counts might be good candidates for a UTXO defrag

SIZE=${1-5000}

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

#depends on jq
if ! command -v jq > /dev/null ; then
	echo "jq not installed - please install jq, command line json tool"
	exit 1
fi

$VERUS listunspent | jq -r '.[]|select(.amount<'"$SIZE"')|select(.amount>0)|[.address,.amount|tostring]|join(" ")' | awk '{ADDR[$1]+=1} END {for (key in ADDR) { print ADDR[key]" "key }}' | sort -n | column -t
