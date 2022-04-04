#!/bin/bash
#Copyright Alex English August 2021
#This script comes with no warranty whatsoever. Use at your own risk.

#blocks execution until a block is found (but only samples once per second
#This is useful when scripting so you can take actions after others have likely confirmed
#typical usage would be ./waitforblock.sh; echo "Block Found"

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

STARTBLOCK="$($VERUS getblockcount)"

echo "Starting block: $STARTBLOCK" 1>&2
until [ "$($VERUS getblockcount)" -gt "$((STARTBLOCK+1))" ]; do
    sleep 1
done
