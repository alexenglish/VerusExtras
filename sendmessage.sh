#!/bin/bash
#Copyright Alex English August 2018
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Ubuntu 16.04, 17.10, 18.04
#Make sure you have a correct path set for the verus cli

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

function usage {
    echo "Usage: ./sendmessage.bash <RECEIVING ADDRESS> <MESSAGE> (AMOUNT TO SEND) (FEE) (FROM ADDRESS)"
    echo "Default amount to send is 0.0001 VRSC."
    echo "Default fee to use is 0.0001 VRSC."
    echo "Default from address is the first z-address with sufficient funds, if present."
    echo "Addresses must be z-addresses"
}

#Check for bc dependency
if ! command -v bc &> /dev/null ; then
    echo "Please install bc (a command-line calculator)"
    exit 1
fi

#Check for xxd dependency
if ! command -v xxd &> /dev/null ; then
    echo "Please install xxd (a command-line hex-editor)"
    exit 1
fi

######Recipient
RCPT=$1
#test for correct length of recipient address string
if [ "${#RCPT}" -ne 78 ]; then
    echo Recipient address is not the correct length
    usage
    exit 1
fi

######Message
MSG=$2

#make sure there is a message
if [ -z "$MSG" ]; then
    echo There does not appear to be a message. Please include your message.
    usage
    exit 2
fi

MSGHEX=$(xxd -pu <<< "$MSG" | tr -d \\n | sed '$a\')
#test for correct byte length of message string
if [ "${#MSGHEX}" -gt 1024 ]; then
    echo Message is too long, must be 512 bytes or less.
    usage
    exit 2
fi

######Amount
AMT=0.0001 #default value
#use the amount given if present
if [ $# -ge 3 ]; then
    AMT=$3
fi

######Fee
FEE=$DEFAULT_FEE
if [ $# -ge 4 ]; then
    FEE=$4
fi

######From
FROM=""
if [ $# -ge 5 ]; then
    if [ "${#$5}" -ne 78 ]; then
        echo The From address does is not the right length.
        usage
        exit 5
    fi
    FROM=$5
else
    #get the first from address that has a balance large enough for the transaction
    ZADDRS=$($VERUS z_listaddresses | tr -d '[]",')
    for Z in $ZADDRS; do
        B=$($VERUS z_getbalance $Z)
        if [ "$(bc<<<"($B-$AMT-$FEE)>=0")" -eq 1 ]; then
            FROM=$Z
            break
        fi
    done
    
    if [ -z "$FROM" ]; then
        echo No z-address found to have sufficient funds to send a message with this amount and fee.
        usage
        exit 5
    fi
fi

echo -e "\n\n"
echo "Recipient: $RCPT"
echo "Message: $MSG"
echo "Message HEX: $MSGHEX"
echo "Amount to send: $AMT"
echo "Fee: $FEE"
echo "From: $FROM"

echo -e "\n\n"
echo "Proposed command - $VERUS z_sendmany \"$FROM\" '[{\"address\": \"$RCPT\", \"amount\": $AMT, \"memo\": \"$MSGHEX\"}]' 1 $FEE"

echo -e "\n\n"
read -p "Do you want to run this command? (Y/y to continue, anything else to abort): " -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]$ ]]; then
    $VERUS z_sendmany "$FROM" '[{"address": "'$RCPT'", "amount": '$AMT', "memo": "'$MSGHEX'"}]' 1 $FEE
else
    echo Aborted sending, exiting
    exit 10
fi
