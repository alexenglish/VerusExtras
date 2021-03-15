#!/bin/bash

#Copyright Alex English November 2019 
#This script comes with no warranty whatsoever. Use at your own risk.                                                        
#Tested on Ubuntu 17.10 and 18.04
SHOWEMPTY=$1

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

printf "\e[33m%-78s %17s \e[0m\n" Address Balance
printf "%78s %17s \n" ------------------------------------------------------------------------------ -----------------
$VERUS listunspent 0 999999999 | jq -cr '.[]|[.address,.amount]' | tr -d '[]"' | tr ',' "\t" | awk '{x[$1]+=$2*1.0} END {for (key in x) { printf "%s %17.8f \n", key, x[key] }}' | while read L; do
	ADDR="$(awk '{print $1}'<<<"$L")"
	AMT="$(awk '{print $2}'<<<"$L")"

	#if it is empty skip unless SHOWEMPTY is set
	if [ "$AMT" = "0.00000000" ] && [ -z "$SHOWEMPTY" ]; then
		continue
	fi

	#if it's an iaddress resolve the identity name
	if [[ "$ADDR" =~ ^i ]]; then
		ADDR="$($VERUS getidentity "$ADDR" | jq -r '.identity.name')@"
	fi

	printf "\e[36m%-78s \e[33m%17.8f\e[0m\n" "$ADDR" $AMT
done | column -s : -t

$VERUS z_listunspent 0 999999999 | jq -cr '.[]|[.address,.amount]' | tr -d '[]"' | tr ',' "\t" | awk '{x[$1]+=$2*1.0} END {for (key in x) { printf "%s %17.8f \n", key, x[key] }}' | while read L; do
	ADDR="$(awk '{print $1}'<<<"$L")"
	AMT="$(awk '{print $2}'<<<"$L")"

	#if it is empty skip unless SHOWEMPTY is set
	if [ "$AMT" = "0.00000000" ] && [ -z "$SHOWEMPTY" ]; then
		continue
	fi

	printf "\e[36m%-78s \e[33m%17.8f\e[0m\n" "$ADDR" $AMT
done | column -s : -t
printf "%78s %17s \n\n" ------------------------------------------------------------------------------ -----------------
