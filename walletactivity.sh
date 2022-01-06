#!/bin/bash

#Copyright Alex English July 2021
#This script comes with no warranty whatsoever. Use at your own risk.                                                        
#Tested on Ubuntu 18.04
#This script lists recent wallet transaction activity in a format more easily digestible than just looking at the output of listtransactions
#The first argument is the number of transactions to view - it defaults to 100
#If any value is set for the second argument it will create tab-delimited output intended for processing with other scripts or importing into spreadsheets

NUM=${1-32}
SCRIPT=${2-}

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

#depends on jq and bc
if ! command -v jq > /dev/null ; then
	echo "jq not installed - please install jq, command line json tool"
	exit 1
fi

if ! command -v bc &>/dev/null ; then
    echo "bc not found. please install using your package manager."
    exit 1
fi

cols () {
    if [ -z $1 ]; then
        column -t -s "$(printf '\t')"
    else
        cat
    fi
}

if [ -z "$SCRIPT" ]; then
	#not script output, columnize and color
	COLS=""
	NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
else
	#script output, no columns, no color
	COLS="true"
	NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
fi

$VERUS listtransactions "*" $NUM | jq -c '.[]' | while read T; do
	CATEGORY="$(jq -r '.category' <<<"$T")"
	TXID="$(jq -r '.txid' <<<"$T")"
	AMOUNT="$(jq -r '.amount' <<<"$T")"
	ADDR="$(jq -r '.address' <<<"$T")"
	BLOCKHASH="$(jq -r '.blockhash' <<<"$T")"
	CONFIRMATIONS="$(jq -r '.confirmations' <<<"$T")"

	#use block time rather than tx time
        #the block time is immutable and tx time may be reported as when it was scanned
	if [ "$BLOCKHASH" != "null" ] && [ -n $BLOCKHASH ]; then
		TIME="$($VERUS getblock $BLOCKHASH | jq -r '.time')"
	else
		TIME="$(jq -r '.time' <<<"$T")"
	fi

	HUMANTIME="$(date -d @$TIME +"%a_%d_%b_%Y-%H:%M:%S")"

	#resolve ID names for addresses
	if [ "${ADDR:0:1}" == "i" ]; then
		ADDR="$($VERUS getidentity "$ADDR" | jq -r '.identity.name')@"
	fi

	#check for orphans to apply color and label
	if [ "$CONFIRMATIONS" == "-1" ]; then
		STATUS="Orphan/Invalid"
	       	COLOR=$RED
	elif [ "$CONFIRMATIONS" == "0" ]; then
		STATUS="Unconfirmed"
		COLOR=$CYAN
        else
            if [ -z "$SCRIPT" ]; then
                STATUS="."
            else
                STATUS="VALID"
            fi
		unset COLOR
	fi

	case "$CATEGORY" in
		stake)
			if [ "$(bc <<<"$AMOUNT >= 0")" -gt 0 ]; then
				continue
			fi
			AMOUNT=${AMOUNT#-}
            if [ -z "$SCRIPT" ]; then
                printf "${COLOR:-$YELLOW}$HUMANTIME\tStaked\t$AMOUNT\tOn\t$ADDR\n"
            else
                printf "$TIME\tStaked\t$STATUS\t$CONFIRMATIONS\t$AMOUNT\t$ADDR\t$TXID\n"
            fi
			;;

		mint)
            if [ -z "$SCRIPT" ]; then
                printf "${COLOR:-$GREEN}$HUMANTIME\tMinted\t$AMOUNT\tTo\t$ADDR\n"
            else
                printf "$TIME\tMinted\t$STATUS\t$CONFIRMATIONS\t$AMOUNT\t$ADDR\t$TXID\n"
            fi
			;;

		immature)
            if [ -z "$SCRIPT" ]; then
                printf "${COLOR:-$GREEN}$HUMANTIME\tImmature\t$AMOUNT\tTo\t$ADDR\n"
            else
                printf "$TIME\tImmature\t$STATUS\t$CONFIRMATIONS\t$AMOUNT\t$ADDR\t$TXID\n"
            fi
			;;

		generate)
            if [ -z "$SCRIPT" ]; then
                printf "${COLOR:-$GREEN}$HUMANTIME\tMined\t$AMOUNT\tTo\t$ADDR\n"
            else
                printf "$TIME\tMined\t$STATUS\t$CONFIRMATIONS\t$AMOUNT\t$ADDR\t$TXID\n"
            fi
			;;

		receive)
            if [ -z "$SCRIPT" ]; then
                printf "${COLOR:-$BLUE}$HUMANTIME\tReceived\t$AMOUNT\tAt\t$ADDR\n"
            else
                printf "$TIME\tReceived\t$STATUS\t$CONFIRMATIONS\t$AMOUNT\t$ADDR\t$TXID\n"
            fi
			;;

		send)
			unset NAME
			if [ "$(bc<<<"!($AMOUNT%20)&&(-100<=$AMOUNT)&&($AMOUNT<=-20)")" -gt 0 ]; then
				#might be part of an ID registration
				NAME="$($VEPATH/fetchtx.sh "$TXID" | jq -r '.vout[0].scriptPubKey.identityprimary.name')"
			fi

			if [ "$NAME" != "null" ] && [ -n "$NAME" ]; then
				#is a name registration
				if [ -z "$SCRIPT" ]; then
				    printf "${COLOR:-$PURPLE}$HUMANTIME\tNameReg\t$AMOUNT\tName\t$NAME@\n"
				else
				    printf "$TIME\tNameReg\t$STATUS\t$CONFIRMATIONS\t$AMOUNT\t$NAME@\t$TXID\n"
				fi
			elif [ "$ADDR" == "null" ]; then
				if [ -z "$SCRIPT" ]; then
				    printf "${COLOR:-$ORANGE}$HUMANTIME\tSent\t$AMOUNT\tTo\tPrivateAddress(Probably)\n"
				else
				    printf "$TIME\tSent\t$STATUS\t$CONFIRMATIONS\t$AMOUNT\tPrivateAddress\t$TXID\n"
				fi
			else
				if [ -z "$SCRIPT" ]; then
				    printf "${COLOR:-$ORANGE}$HUMANTIME\tSent\t$AMOUNT\tTo\t$ADDR\n"
				else
				    printf "$TIME\tSent\t$STATUS\t$CONFIRMATIONS\t$AMOUNT\t$ADDR\t$TXID\n"
				fi
			fi
			;;

		*)
			printf "$TIME\tUnhandledTXType\t$AMOUNT\tOn\t$ADDR\n"
			;;
	esac

    if [ -z "$SCRIPT" ]; then
        printf "$STATUS\tConfs\t$CONFIRMATIONS\tTXID\t$TXID$NOFORMAT\n"
    fi
done | cols $COLS
