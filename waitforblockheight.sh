#!/bin/bash
#Copyright Alex English February 2021
#This script comes with no warranty whatsoever. Use at your own risk.

#blocks execution until the specified block height is reached
#typical usage would be ./waitforblockheight.sh 1500000; echo "Block Height Reached"
#or ./waitforblockheight.sh 1500000 && echo "Block Height Reached"

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

if ! [[ "$1" =~ ^[0-9]+$ ]] || [ $# -ne 1 ];
then
	echo "1st and only argument must be an integer block height"
	exit 1
fi

until [ "$($VERUS getblockcount)" -ge "$1" ]; do
    sleep 1
done
