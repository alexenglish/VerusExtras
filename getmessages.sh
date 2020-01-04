#!/bin/bash
#Copyright Alex English August 2018
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Ubuntu 17.10, 18.04, Arch
#Make sure you have a correct path set for the verus cli

#This script will list all received memos (messages) for the supplied address.

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

#Check for xxd dependency
if ! command -v xxd &> /dev/null ; then
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
