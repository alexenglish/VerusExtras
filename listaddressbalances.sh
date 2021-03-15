#!/bin/bash

<<<<<<< HEAD
#Copyright Alex English November 2019 
#This script comes with no warranty whatsoever. Use at your own risk.                                                        
#Tested on Ubuntu 17.10
=======
#Copyright Alex English November 2019
#This script comes with no warranty whatsoever. Use at your own risk.                                                        
#Tested on Ubuntu 17.10 and Debian 10

SHOWEMPTY=$1
>>>>>>> 90380b938ac5c57373afdee73968654d627f27bf

#lists balances for each address that has any unspent transactions
if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

#depends on jq
if ! command -v jq > /dev/null ; then
	echo "jq not installed - please install jq, command line json tool"
	exit 1
fi

<<<<<<< HEAD
$VERUS listunspent 0 999999999 | jq -cr '.[]|[.address,.amount]' | tr -d '[]"' | tr ',' "\t" | awk '{x[$1]+=$2} END {for (key in x) { print key "\t" x[key] }}'
=======
$VERUS listunspent 0 999999999 | jq -cr '.[]|[.address,.amount]' | tr -d '[]"' | tr ',' "\t" | awk '{x[$1]+=$2*1.0} END {for (key in x) { print key "\t" x[key] }}' | while read L; do
	ADDR="$(awk '{print $1}'<<<"$L")"
	AMT="$(awk '{print $2}'<<<"$L")"

	#if it is empty skip unless SHOWEMPTY is set
	if [ "$AMT" = "0" ] && [ -z "$SHOWEMPTY" ]; then
		continue
	fi

	#if it's an iaddress resolve the identity name
	if [[ "$ADDR" =~ ^i ]]; then
		ADDR="$($VERUS getidentity "$ADDR" | jq -r '.identity.name')@"
	fi

	printf "$ADDR:%.8f\n" "$AMT"
done | column -s : -t
>>>>>>> 90380b938ac5c57373afdee73968654d627f27bf
