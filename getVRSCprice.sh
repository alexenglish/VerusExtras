#!/bin/bash
#Copyright Alex English May 2019
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Ubuntu 18.04

#Run "./getVRSCprice.sh <CurrencyPair>" to get the current CoinGecko price in CurrencyPair
#run without an argument to get the price in USD by default
#or run "./getVRSCprice.sh list" to get the list of supported currencies

#I may come back to add other output formats

if [ "$#" -le "0" ]; then
    VS="usd"
elif [ "$#" -gt "1" ]; then
    echo "Usage: ./getVRSCprice.sh <CurrencyPair>"
    echo "Or - get valid currencies using ./getVRSCprice.sh list"
    exit 1
else
    if [ "$1" == "list" ]; then
        echo "Supported currencies: " 1>&2
        curl -X GET "https://api.coingecko.com/api/v3/simple/supported_vs_currencies"
        exit 0
    else
        VS=$1
    fi
fi

curl -X GET "https://api.coingecko.com/api/v3/simple/price?ids=verus-coin&vs_currencies=$VS" -H "accept: application/json"
printf '\n'
