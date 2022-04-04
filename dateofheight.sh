#!/bin/bash
#Copyright Alex English April 2022
#This script comes with no warranty whatsoever. Use at your own risk.                                                        
#Tested on Ubuntu 18.04

#This script takes a block number as its first argument
#If that block height has already occurred it will print out the date of that block height
#If that block height has not yet occurred it will print a prediction for when it will occur based on the average blocktime since block 2
#If a second argument is supplied (any value) it will increase verbosity

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

#depends on jq and bc
if ! command -v jq > /dev/null ; then
	echo "jq not installed - please install jq, command line json tool"
	exit 1
fi

if ! command -v bc &>/dev/null ; then
    echo "bc not found. please install using your package manager."
    exit 1
fi

HEIGHT=$($VERUS getblockcount)
TARGET=$1

if [ -z "$TARGET" ]; then
    echo "No block height supplied, finding time for the last block (current height)" >&2
    TARGET=$($VERUS getblockcount)
fi

if [ $HEIGHT -ge $TARGET ]; then
    if [ -n "$2" ]; then
        echo "Block already occurred: " >&2
    fi
    date -u -d @"$($VERUS getblock $TARGET | jq '.time')"
    date -d @"$($VERUS getblock $TARGET | jq '.time')"
else
    AVG=$($VEPATH/avgblocktime.sh $((HEIGHT-2)) )
    DH=$((TARGET-HEIGHT))
    DT=$(bc<<<"$DH*$AVG")
    TIME=$(bc<<<"$($VERUS getblock $HEIGHT | jq '.time')+$DT")
    if [ -n "$2" ]; then
        echo "Block not yet found." >&2
        echo -n "Blocks to go: " >&2
        echo "$DH"
        echo -n "Based on an average block time of ${AVG}s, the estimated date/time for this block is " >&2
    fi
    echo "$(date -u -d @$TIME)"
    echo "$(date -d @$TIME)"
fi
