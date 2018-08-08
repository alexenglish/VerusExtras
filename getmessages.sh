#!/bin/bash
#Copyright Alex English August 2018
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Ubuntu 17.10, 18.04, Arch
#Make sure you have a correct path set for the verus cli

#This script will list all received memos (messages) for the supplied address.

VERUS=~/veruscoin/src/fiat/verus

if [ ! -x $VERUS ]; then
        echo "It looks like $VERUS doesn't exist, or isn't executable. Edit the value of VERUS on line 3 to reflect an accurate path to the Verus CLI RPC executable."
        exit 1
fi

#Check for xxd dependency
xxd --version &> /dev/null
if [ $? -eq 127 ]; then
    echo "Please install xxd (a command-line hex-editor)"
    exit 1
fi

if [ -z $1 ]; then
        echo "Supply the receiving address you want to receive messages for as a (the first) parameter."
        exit 1
fi

ADDR=$1

#just using this to print a newline
echo 

for M in $($VERUS z_listreceivedbyaddress "$ADDR" | grep memo | awk '{print $2}' | tr -d '"'); do
    echo
    sed 's/[a-f0-9]\{2\}/& /g' <<<"$M" | xxd -p -r | cat - <(echo)
done
