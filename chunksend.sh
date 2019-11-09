#!/bin/bash
#Copyright Alex English September 2018
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Ubuntu 17.10
#Make sure you have a correct path set for the verus cli

#This script will send funds to the specified address in separate transactions
#This is useful if you'd like to manage the size of the UTXOs, such as for staking.

#First arg - address to send to
#Second arg - amount to send
#Third arg - size of chunks - defaults to 1000 if not set

source config

#Check for bc dependency
bc --version &> /dev/null
if [ $? -eq 127 ]; then
    echo "Please install bc (a command-line calculator)"
    exit 1
fi

if [ "$#" -lt 2 ]; then
    echo -e "Useage: ./chunksend.sh <ADDRESS> <AMOUNTTOSEND> (CHUNKSIZE)\nChunk size defaults to 1000"
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
CHUNK=${CHUNK:-1000}

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
