#!/bin/env zsh
#Copyright Alex English May 2019
#This script comes with no warranty whatsoever. Use at your own risk.
#Updated March 2023

#source this file in your .zshrc or run "source verus-completion.zsh" from your zsh shell
#your .zshrc must contain these lines before sourcing this script
#autoload -Uz compinit
#compinit

pushd "${0:a:h}" 

source completion_vars

function _verus {
    _arguments -C "1: :($CONTROL $NETWORK $BLOCKCHAIN $CROSSCHAIN $MINING $GENERATING $RAWTRANSACTIONS $ADDRESSINDEX $UTIL $WALLET $DISCLOSURE $PBAAS $IDENTITY $VDXF $MARKETPLACE $MULTICHAIN)"
}

compdef _verus verus

popd
