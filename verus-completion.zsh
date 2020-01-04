#!/bin/zsh
#Copyright Alex English May 2019
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Ubuntu 18.04

pushd "$( dirname "${BASH_SOURCE[0]}" )" 

#source this file in your .zshrc or run "source verus-completion.zsh" from your zsh shell

source completion_vars

function _verus {
    _arguments -C "1: :($CONTROL $NETWORK $BLOCKCHAIN $CROSSCHAIN $MINING $GENERATING $RAWTRANSACTIONS $ADDRESSINDEX $UTIL $HIDDEN $WALLET $DISCLOSURE $PBAAS)"
}

compdef _verus verus
compdef _verus komodo-cli

popd
