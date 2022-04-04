#!/bin/bash
#Copyright Alex English April 2022
#This script comes with no warranty whatsoever. Use at your own risk.                                                        
#Tested on Ubuntu 18.04

#This script will make a best effort to predict the block height at a particular date/time.
#The first and only argument is the target UNIX epoch timestamp for the date/time you want an estimated block height for.

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

if [ $# -ne 1 ]; then
    echo "Estimates a future blockheight for a given date/time in UNIX epoch time format."
    echo "Usage: ./targetheight.sh <EPOCHTIME>"
    exit 1
fi

#target ephoch time 
TARGET=$1

TIPHEIGHT=$($VERUS getblockcount)
TIPTIME=$($VERUS getblock $TIPHEIGHT | jq -r '.time')
BLOCKTIME=$($VEPATH/avgblocktime.sh 10000)
echo "Average block time: $BLOCKTIME seconds"

DT=$((TARGET-TIPTIME))
BLOCKS=$(bc<<<"scale=4; $DT/$BLOCKTIME")
TARGETHEIGHT=$(bc<<<"scale=4; $BLOCKS+$TIPHEIGHT")
echo -n "Time Specified: "; date -u -d @$TARGET
echo "$BLOCKS blocks in the future"
echo "Target height: $TARGETHEIGHT"
