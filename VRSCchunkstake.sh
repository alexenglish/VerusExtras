#!/bin/bash
#Copyright Alex English September 2018
#Adapted from chunsend.sh to chunkstake.sh by Oink April 2020
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Ubuntu 18.04 LTS

#This script will send funds to the specified address in separate transactions
#This is useful if you'd like to manage the size of the UTXOs, such as for staking.

#First arg - address to send from
#Second arg - address to send to
#Third arg - initial size of chunks - defaults to 1000 if not set
#Fourth arg - increment size of chunks - defaults to 50 is not set
DEFAULTCHUNK=1000
DEFAULTINCREMENT=50

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
    echo -e "Useage: ./chunksend.sh <FROM-ADDRESS> <TO-ADDRESS> (CHUNKSIZE CHUNKINCREMENT) "
    exit
fi

SOURCE=$1
#Check for source address arg presence and format (length 34 for VerusID, 78 for private)
if [ "${#SOURCE}" -ne 34 ]; then
    if [ "${#SOURCE}" -ne 78 ]; then
        echo "Recipient address is not the correct length"
        exit
    else
        if [[ $SOURCE =~ ^z.* ]]; then
            sleep 0.01
        else
            echo "Supplied private address does not start with z"
            exit
        fi
    fi
else
    if [[ $SOURCE =~ ^i.* ]]; then
        sleep 0.01
    else
        echo "Supplied VerusID address does not start with i"
        exit
    fi
fi

ADDR=$2
#Check for target address arg presence and format (length 34 for public and/or VerusID, 78 for private)
if [ "${#ADDR}" -ne 34 ]; then
    if [ "${#ADDR}" -ne 78 ]; then
        echo "Recipient address is not the correct length"
        exit
    else
        if [[ $ADDR =~ ^z.* ]]; then
            sleep 0.01
        else
            echo "Reciepient private address does not start with z"
            exit
        fi
    fi
else
    if [[ $ADDR =~ ^i.*|^R.* ]]; then
        sleep 0.1
    else
        echo "Supplied VerusID or Public address does not start with i or R"
        exit
    fi
fi


CHUNK=$3
#set a default value if CHUNK is null
CHUNK=${CHUNK:-$DEFAULTCHUNK}

INCREMENT=$4
#set a default value if INCREMENT is null
INCREMENT=${INCREMENT:-$DEFAULTINCREMENT}

#Set complete address balance to Ammount to send to

AMT=$(bc<<<"scale=8; $($VERUS z_getbalance "$SOURCE")")
echo "Private balance is: $AMT"

SENT=0

echo  "Sending $AMT to $ADDR in chunks of increasing size" 

while (exit $(bc<<<"$SENT >= $AMT")); do
    LEFT=$(bc<<<"$AMT - $SENT")
    if [ "$(bc<<<"$LEFT >= $CHUNK")" -eq 1 ]; then
        #send a full chunk
        echo "Sending $CHUNK to $ADDR"
        OUTPUT="[{\"address\": \"$ADDR\", \"amount\":$CHUNK}]"
        OPID=$($VERUS z_sendmany "$SOURCE" "$OUTPUT")
        INPUT="[\"$OPID\"]"

# Check if OPID is succesfull, if so increase CHUNK with INCREMENT
	STATUS=$(jq -cr '.[] | .status' <<< $($VERUS z_getoperationstatus "$INPUT"))
        while [ "$STATUS" = "executing" ]; do
            sleep 1
            date
            STATUS=$(jq -cr '.[] | .status' <<< $($VERUS z_getoperationstatus "$INPUT"))
        done
        if [ "$STATUS" = "failed" ]; then
            echo "$OPID - failed"
        fi
        if [ "$STATUS" = "success" ]; then
            echo "$OPID - succesfull"
            SENT=$(bc<<<"$SENT + $CHUNK")
            CHUNK=$(bc<<<"$CHUNK + $INCREMENT")
        fi

# wait loop courtesy of 0x03@ (BloodyNora)
	CUR=$($VERUS getblockcount)
	while [ $($VERUS getblockcount) -lt $((CUR+2)) ]; do
	    sleep 1
	done
    else
        #send the last, partial CHUNK
        echo "leaving $LEFT on $SOURCE"
	exit
    fi
done
