#!/usr/bin/env bash
#Copyright Alex English May 2019
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Ubuntu 18.04

pushd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null

#source verus-completions.bash in your bash shell to make use of it. ( run "source verus-completions.bash" )
#or source this file in your .bashrc file
source lib/completion_vars

complete -W "$CONTROL $NETWORK $BLOCKCHAIN $CROSSCHAIN $MINING $GENERATING $RAWTRANSACTIONS $ADDRESSINDEX $UTIL $WALLET $DISCLOSURE $PBAAS $IDENTITY $VDXF $MARKETPLACE $MULTICHAIN" verus

popd &>/dev/null
