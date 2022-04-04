#!/bin/bash
#Copyright Alex English April 2022
#This script comes with no warranty whatsoever. Use at your own risk.                                                        
#Tested on Ubuntu 18.04

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

#depends on jq
if ! command -v jq > /dev/null ; then
	echo "jq not installed - please install jq, command line json tool"
	exit 1
fi

COUNT=$($VERUS getblockcount)
Tb=$($VERUS getblock $COUNT | jq '.time')
T=$(date +%s)

echo "Time of last block: $(date -d @$Tb)"
echo "Seconds since last block: $((T-Tb))"
echo "Block Height: $COUNT"
