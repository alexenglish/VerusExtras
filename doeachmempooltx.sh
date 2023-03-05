#!/bin/bash
#Copyright Alex (Lex) English, March 2023
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Debian 11

#Executes a given command (and any arguments that follow) once for each mempool TX discovered while waiting for each block. That means you will get duplicates when mempool transactions arrive before a new block that doesn't include them, and that you'll miss transactions if they don't reach you before they're committed to a block. There is a 100ms delay between queries to prevent flooding the verus daemon.

#The arguments are executed with no checks whatsoever, with the TXID appended to the arguments. It is forked to the background.
#example: ./doeachmempooltx.sh ./mymempoolscript.sh somearg

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

containsElement () {
  local E MATCH="$1"
  shift
  for E; do [[ "$E" == "$MATCH" ]] && return 0; done
  return 1
}

#loop forever
while true; do
	#get block height
	BLOCKS=$($VERUS getblockcount)

	ALREADYSEEN=( )

	#this loop and check could be replaced by blocking on doeachblock.sh
	#while the block height doesn't change
	while [ $BLOCKS -eq $($VERUS getblockcount) ]; do
		MEMTXES=( $( verus getrawmempool | jq -r '.[]' ) )

		#for each TX in mempool
		for TXID in ${MEMTXES[@]}; do
			#bail if we've already considered this one this block
			if containsElement $TXID "${ALREADYSEEN[@]}"; then
				continue
			fi

			$@ "$TXID" &

			#Add mempool TXID to list to ignore
			ALREADYSEEN+=( "$TXID" )
		done
		sleep 0.1
	done
done
