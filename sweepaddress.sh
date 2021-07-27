#!/bin/bash
#Copyright Alex English June 2021
#This script comes with no warranty whatsoever. Use at your own risk.

#Sweeps all funds from the source address and sends them to the destination address minus the fee in a single transaction (no chunking for staking)
#First argument is the source address, second is the destination
#Either the source or destination may be a private address, transparent address, or ID specified as an iaddress or name@ (make sure to use quotes for names with spaces and non-alphanumeric characters)

#TODO - test edge cases such as fee amounts for transactions with a large number of inputs, etc.

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

: ${DEFAULT_FEE=0.0001}

#Check for bc dependency
if ! command -v bc &> /dev/null ; then
    echo "Please install bc (a command-line calculator)"
    exit 1
fi

if [ "$#" -lt 2 ]; then
    echo -e "Useage: ./sweepaddress.sh <SRCADDRESS> <DESTADDRESS"
    echo "This will send all funds from SRCADDRESS to DESTADDRESS minus a transaction fee."
    exit
fi

BAL="$($VERUS z_getbalance "$1")"
AMT="$(bc<<<"scale=8; $BAL - $DEFAULT_FEE")"
AMT="$(printf "%.8f\n" "$AMT")"

if [ "$(bc<<<"$BAL>=$DEFAULT_FEE")" -gt 0 ]; then
    echo "Sweeping $AMT from $1 to $2"
    $VERUS sendcurrency "$1" '[{"address":"'"$2"'","amount":'"$AMT"'}]'
else
    echo "Insufficient funds to sweep from $1"
    exit 1
fi
