#!/bin/bash
#Copyright Alex English April 2022
#This script comes with no warranty whatsoever. Use at your own risk.                                                        
#Tested on Ubuntu 18.04

#This script returns the average block time in seconds when considered over the last N blocks
#Argument 1 is the number of blocks to consider

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
    echo "Returns average seconds per block for the last N blocks."
    echo "Usage: ./avgblocktime.sh <N>"
    exit 1
fi

NUMBLOCKS=$1
BLOCKHEIGHT=$($VERUS getblockcount)
ENDHEIGHT=$((BLOCKHEIGHT-$NUMBLOCKS))

TIPTIME=$($VERUS getblock $BLOCKHEIGHT | jq -r '.time')
ENDTIME=$($VERUS getblock $ENDHEIGHT | jq -r '.time')

TOTALTIME=$((TIPTIME-ENDTIME))
AVG=$(bc<<<"scale=4; $TOTALTIME/$NUMBLOCKS")

printf "$AVG\n"
