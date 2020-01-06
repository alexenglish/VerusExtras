#!/bin/bash
#Copyright Alex English January 2020
#This script comes with no warranty whatsoever. Use at your own risk.

#Mined coinbases can now stake without having been shielded. Shielded coinbases still aren't able to stake until they've at least been spent to a normal TX.
#This script looks for unspent minted (staked) coinbases and spends them back to the same address. If there are multiple on an address, this consolidates them into one output. Privacy is preserved because this doesn't comingle any addresses. Furthermore, the option is given to allow for a random delay of 5 to 15 minutes between transaction submissions, so the transactions don't show up as a burst, but are metered over time, likely no more than one per block.

#Usage: ./stakepusher.sh [false]
#1st arg is either "false" or anything else (or omitted). Unless false is given, a delay is used between addresses to increase privacy. If false is passed, all actions will be performed without delay, finishing quickly, but also creating the possibility of correlating the addresses based on time.
#You might also consider setting this up as a cronjob to execute automatically

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

#Dependencies: jq (command-line json parser/editor), bc (command-line calculator)
if ! command -v jq &>/dev/null ; then
    echo "jq not found. please install using your package manager."
    exit 1
fi

if ! command -v bc &>/dev/null ; then
    echo "bc not found. please install using your package manager."
    exit 1
fi

DB=$(mktemp -d)

BLOCKS=$($VERUS getblockcount)
#only consider blocks since the verus 0.6 fork
CONFS=$((BLOCKS-800200))

if [ "$1" == "false" ]; then
	USEDELAY=""
else
	USEDELAY=true
fi

#listunspent, filter for generated true
$VERUS listunspent 1 $CONFS | jq -cr '.[]|select(.generated==true)|.address+"\t"+(.confirmations|tostring)+"\t"+.txid+"\t"+(.vout|tostring)+"\t"+(.amount|tostring)' | \
	while read L; do
	#for each, look up the block - if it is minted the utxo is staked
		CONF=$(awk '{print $2}' <<< "$L")
		BLOCK="$($VERUS getblock $((BLOCKS-CONF+1)) | jq -c '.')"
		TYPE="$(jq -r '.blocktype' <<< "$BLOCK")"
		if [ "$TYPE" == "minted" ]; then
			#append txid and vout to file named for the address in $DB/
			ADDR=$(awk '{print $1}' <<<"$L")
			printf "$L\n" >> "$DB/$ADDR"
		fi
	done

	#format of lines in address files is address, confirmations, txid, vout
for F in `ls -1A $DB`; do
	#random delay from 5 minutes to 15 minutes
	ADDR="$F"
	INPUTS='['
	AMOUNT=0
	
	while read L; do
		#build transaction inputs
		TXID=$(awk '{print $3}' <<<"$L")
		VOUT=$(awk '{print $4}' <<<"$L")
		INPUTS="$INPUTS{\"txid\":\"$TXID\",\"vout\":$VOUT},"	

		INAMOUNT=$(awk '{print $5}' <<<"$L")
		AMOUNT=$(bc<<<"$AMOUNT+$INAMOUNT")
	done < "$DB/$F"
	INPUTS="${INPUTS%,}]"

	#build transaction output
	OUTAMOUNT=$(bc<<<"$AMOUNT-$DEFAULT_FEE")
	OUTPUT="{\"$ADDR\":$OUTAMOUNT}"

	#echo "ADDRESS: $ADDR"
	#echo "INPUTS: $INPUTS"
	#echo "OUTPUT: $OUTPUT"

	echo "Consolidating and moving $OUTAMOUNT on address $ADDR"

	#createrawtransaction
	TXHEX="$($VERUS createrawtransaction "$INPUTS" "$OUTPUT")"
	#signrawtransaction
	SIGNEDTXHEX="$($VERUS signrawtransaction "$TXHEX" | jq -r '.hex')"
	#sendrawtransaction
	SENTTXID="$($VERUS sendrawtransaction "$SIGNEDTXHEX")"
    echo "TXID: $SENTTXID"

	if [ "$USEDELAY" ]; then
		DELAY=$((300+RANDOM%600))
		date
		echo "Using delay for privacy - sleeping $DELAY seconds"
		sleep $DELAY
	fi
done

rm -rf "$DB"

echo "Stake push completed"
