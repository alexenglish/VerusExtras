#!/bin/bash
#Copyright Alex English September 2018
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Ubuntu 17.10

#This script will send funds to the specified address in separate transactions
#This is useful if you'd like to manage the size of the UTXOs, such as for staking.

#First arg - address to send to
#Second arg - amount to send
#Third arg - size of chunks - defaults to 2500 if not set
DEFAULTCHUNK=5000

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

#Check for bc dependency
if ! command -v bc &> /dev/null ; then
    echo "Please install bc (a command-line calculator)"
    exit 1
fi

if [ "$#" -lt 2 ]; then
    echo -e "Useage: ./chunksend.sh <ADDRESS> <AMOUNTTOSEND> (CHUNKSIZE)\nChunk size defaults to $DEFAULTCHUNK"
    exit
fi

#Check for address arg presence and format
ADDR=$1
if [ "${#ADDR}" -ne 34 ]; then
    echo "Recipient address is not the correct length"
    exit
fi

#Check for amount arg presence
AMT=$2
if [ -z "$AMT" ]; then
    echo "No amount to send given"
    exit
fi

CHUNK=$3
#set a default value if CHUNK is null
CHUNK=${CHUNK:-$DEFAULTCHUNK}

SENT=0

printf "Sending $AMT to $ADDR in chunks of $CHUNK\n" | tee chunktxlog

while (exit $(bc<<<"$SENT >= $AMT")); do
    LEFT=$(bc<<<"$AMT - $SENT")
    if [ "$(bc<<<"$LEFT >= $CHUNK")" -eq 1 ]; then
        #send a full chunk
        echo "Sending $CHUNK to $ADDR"
        SENT=$(bc<<<"$SENT + $CHUNK")
        $VERUS sendtoaddress "$ADDR" "$CHUNK" | tee -a chunktxlog
    else
        #send the last, partial chunk
        echo "Sending $LEFT to $ADDR"
        SENT=$(bc<<<"$SENT + $LEFT")
        $VERUS sendtoaddress "$ADDR" "$LEFT" | tee -a chunktxlog
    fi
done
