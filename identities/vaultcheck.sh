#!/bin/bash
#Copyright Alex English and Bree Phelps April 2022
#This script comes with no warranty whatsoever. Use at your own risk. Tested on Ubuntu 18.04.

#This script returns the vault status for each ID specified as a commandline argument. It will handle ID names with or without the trailing @. Any number of IDs may be specified, just make sure to enclose any with spaces or special characters in quotes.

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/../config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

#depends on jq
if ! command -v jq > /dev/null ; then
	echo "jq not installed - please install jq, command line json tool"
	exit 1
fi

#No ID names specified as args
if [ $# -lt 1 ]; then
    echo "Usage: ./vaultcheck.sh <IDNAME> <IDNAME> ... <IDNAME>" 1>&2
    exit 1
fi

function flagcheck ()
{
    #First arg is value to check for the flag
    #Second arg is flag(s) to test
    return $((($1 & $2) == 0))
}

FLAG_REVOKE=0x8000
FLAG_DELAYLOCK=0x02

NAMES=( "$@" )

for NAME in "${NAMES[@]}"; do
    NAME="${NAME%@}"
    ID="$($VERUS getidentity "${NAME}@" 2>/dev/null | jq -c '.identity')"

    if [ -z "$ID" ]; then
        echo "${NAME}@ ID not registered"
        continue
    fi

    TIMELOCK="$(jq -r '.timelock' <<<"$ID")"
    FLAGS="$(jq -r '.flags' <<<"$ID")"

    if flagcheck "$FLAGS" $FLAG_DELAYLOCK; then
        echo "${NAME}@ Delay lock of $((TIMELOCK+20)) blocks active."
    elif flagcheck "$FLAGS" $FLAG_REVOKE; then
        echo "${NAME}@ Is Revoked."
    else
        BLOCKHEIGHT="$($VERUS getblockcount)"
        if [ "$TIMELOCK" -gt "$BLOCKHEIGHT" ]; then
            echo "${NAME}@ Timelock unlocks in $((TIMELOCK-BLOCKHEIGHT)) blocks"
        else
            echo "${NAME}@ Unlocked"
        fi
    fi

done
