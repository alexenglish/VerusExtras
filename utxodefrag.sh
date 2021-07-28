#!/bin/bash
#Copyright Alex English June 2021
#This script comes with no warranty whatsoever. Use at your own risk.

#This script just spends all the funds on an address back to itself in chunks of the predetermined size.
#First arg is the address to operate on (no z-addresses)
#Second (optional) arg is the desired chunk size, which defaults to 5000

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

set -e

ADDR=$1
CHUNK=${2-5000}

AC=${#ADDR}

if [ "${ADDR:AC-1:1}" != "@" ] && ( [ "$AC" -ne 34 ] || ( [ "${ADDR:0:1}" != "R" ] && [ "${ADDR:0:1}" != "i" ] )) ; then
	echo "Missing address or the address given is not valid or not supported." >&2
	echo "Supported address types are:" >&2
	echo "	Transparent addresses (R-addresses)" >&2
	echo "	Identity addresses (i-addresses)" >&2
	echo "	Identity names (ending in @)" >&2
	exit 1
fi

BAL="$($VERUS z_getbalance "$1")"
AMT="$(bc<<<"$BAL-$DEFAULT_FEE")"
CHUNKS="$(bc<<<"$AMT/$CHUNK")"
#REM="$(bc<<<"$AMT-($CHUNKS*$CHUNK)")"
#REM="$(printf "%.8f\n" "$REM")"
REM="$(printf "%.8f\n" "$(bc<<<"$AMT-($CHUNKS*$CHUNK)")")"

echo "Address: $ADDR"
echo "Breaking balance of $BAL into $CHUNKS of $CHUNK plus $REM"
echo

DESTS='['

while [ "$CHUNKS" -gt 0 ] ; do
	CHUNKS=$((CHUNKS-1))
	DESTS="$DESTS"'{"address":"'"$ADDR"'","amount":'"$CHUNK"'},'
done

if [ "$(bc<<<"$REM < 0")" -ge 0 ]; then
	DESTS="$DESTS"'{"address":"'"$ADDR"'","amount":'"$REM"'}]'
else
	DESTS="${DESTS%,}]"
fi

echo Running: verus sendcurrency "$ADDR" "$DESTS" >&2
echo
$VERUS sendcurrency "$ADDR" "$DESTS"
