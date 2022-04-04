#!/bin/bash
#Copyright Alex English April 2022
#This script comes with no warranty whatsoever. Use at your own risk.                                                        
#Tested on Ubuntu 18.04

#This script returns statistics for the number of blocks mined or staked over the last N blocks, and the ratio between the two.

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

N=$1

H=$($VERUS getblockcount)
HP=$((H-N+1))

echo "Block count: $H"
echo "Scanning back to height: $HP"

MINED=0
MINTED=0

for I in `seq $HP $H`; do
    TYPE=$($VERUS getblock $I | jq -r '.blocktype')
    echo "$I: $TYPE"
    if [ "$TYPE" == "mined" ]; then
        MINED=$((MINED+1))
    elif [ "$TYPE" == "minted" ]; then
        MINTED=$((MINTED+1))
    fi
done

echo "Mined: $MINED of $N"
echo "Minted: $MINTED of $N"
echo "Mined Percent: $(bc<<<"scale=2; 100*$MINED/$N")%"
echo "Minted Percent: $(bc<<<"scale=2; 100*$MINTED/$N")%"
