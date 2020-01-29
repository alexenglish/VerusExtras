#!/bin/bash
#Copyright Alex English January 2020
#This script comes with no warranty whatsoever. Use at your own risk.

#This is simply a script to provide a concise summary of the wallet balance, including private, transparent, unconfirmed, etc.

#Usage: ./integratedbalance.sh

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

WALLET="$($VERUS getwalletinfo | jq '{"transparent":.balance,"unconfirmed":.unconfirmed_balance,"immature":.immature_balance}')"
WALLET="$WALLET$($VERUS z_gettotalbalance 0 | jq '{"private":(.private|tonumber)}')"
WALLET="$(jq -s add <<<"$WALLET")"
TOTAL="$(jq '.transparent+.unconfirmed+.immature+.private' <<<"$WALLET")"
WALLET="$(jq -s add <<<"$WALLET{\"total\":$TOTAL}")"

printf "$WALLET" | jq '.'
