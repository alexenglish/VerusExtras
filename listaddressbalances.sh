#!/bin/bash

#Copyright Alex English November 2019 
#This script comes with no warranty whatsoever. Use at your own risk.                                                        
#Tested on Ubuntu 17.10

#lists balances for each address that has any unspent transactions
if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

#depends on jq
if ! command -v jq > /dev/null ; then
	echo "jq not installed - please install jq, command line json tool"
	exit 1
fi

$VERUS listunspent 0 999999999 | jq -cr '.[]|[.address,.amount]' | tr -d '[]"' | tr ',' "\t" | awk '{x[$1]+=$2} END {for (key in x) { print key "\t" x[key] }}'
