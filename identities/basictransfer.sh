#!/bin/bash
#Copyright Alex English January 2020 
#This script comes with no warranty whatsoever. Use at your own risk.                                                        
#This script is for simple ID transfers, where the Revocation and Recovery Authorities are itself, and where there is a single primaryaddress.

#TODO - test checks against IDs that have authorities set
#TODO - test checks against IDs that have multiple primaryaddresses

#Arg1 is name to transfer, with or without trailing @
#Arg2 is the new primary address 
#Arg3 is the new private address

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/../config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

#depends on jq
if ! command -v jq > /dev/null ; then
	echo "jq not installed - please install jq, command line json tool"
	exit 1
fi

#check for the correct number of arguments. Bad values for any of them should simply fail validation by the RPC.
if [ "$#" -ne 3 ]; then
	echo "Three arguments are needed."
	echo "Usage: ./basictransfer.sh <identityname> <newprimaryaddress> <newprivateaddress>"
	exit 1
fi

#check to see that the identity specified exists
IDENT="${1%@}@"
if ! DATA=$($VERUS getidentity "$IDENT" 2>/dev/null); then
	echo "$IDENT - Identity doesn't appear to be registered. Can't transfer it."
	exit 1
else
	#make sure we have the ability to update ownership
	if [ "$(jq -r '.cansignfor' <<< "$DATA")" != "true" ]; then
		echo "$IDENT - Identity can't be signed for. Can't transfer it."
		exit 1
	fi
fi

#check to see that we're updating the ONLY primary address
if [ "$(jq -r '.identity.primaryaddresses | length' <<<"$DATA")" -ne 1 ]; then
	echo "It appears there are more than one primaryaddresses on this identity, which is not supported by this script, as it only updates primaryaddress[0]."
	exit 1
fi

IDADDR=$(jq -r '.identity.identityaddress' <<<"$DATA")
RECADDR=$(jq -r '.identity.recoveryauthority' <<<"$DATA")
REVADDR=$(jq -r '.identity.revocationauthority' <<<"$DATA")
#check to see that the identity is its own revocation and recovery authority
#TODO - consider adding a flag to force the transfer to happen, updating the authorities to itself if permitted
if [ "$IDADDR" != "$RECADDR" ] || [ "$IDADDR" != "$REVADDR" ]; then
	echo "This script is intended to only transfer IDs that have themselves as the recovery and revocation authorities. This is not a technical limitation, but is constrained for clarity to make sure transfers aren't incomplete."
	exit 1
fi

UPDATED="$(jq -c ".identity | .primaryaddresses[0]=\"$2\" | .privateaddress=\"$3\"" <<<"$DATA")"

echo -n "$IDENT - "
$VERUS updateidentity "$UPDATED"
