# VerusExtras
Misc scripts for working with Verus Coin

All of these scripts have been at least lightly tested, but come with no warranty whatsoever for any purpose. Use at your own risk.

See comments at the top of each script for usage information.

Update the config file (named 'config') with the path to your Verus CLI RPC executable. Some scripts depend on bc (command-line calculator) or jq (command-line json parser, constructor, pretty-printer).

## simple-staker.sh
Simple staker shields coinbases to a private address, then moves available private address balances to public addresses (randomly selected from those available, creating new addresses if necessary) for staking. This script can be run manually, set up as a cron job, or used with the blocknotify parameter to execute every X blocks (not recommended if you're still syncing the chain).

## verus-completion.bash
Gives tab-completion for the verus and komodo-cli RPC commands in a bash shell. At the moment it only auto-completes commands, but I intend to add support for a few dynamic types. To make use of it run `source verus-completion.bash` in your shell, or add that to your .bashrc (you may have to adjust paths).

## verus-completion.zsh
Gives tab-completion for the verus and komodo-cli RPC commands in a zsh shell. Same instructions as for the bash version, substituting zsh as appropriate.

## sendmessage.sh
Sendmessage will send an encrypted private message using the memo field of a private transaction. It costs a fee to send, and sends a small amount of Verus to the receipient, both of these amounts are configurable.

## getmessages.sh
Getmessages lists memo fields of all transactions received at a particular private address. It's simple and bare-bones, but does the job.

## chunksend.sh
Send funds to the specified address in separate transactions of the desired size - useful for managing the size of UTXOs, such as for staking.

## decodeunlockheight.py
Takes the script hex for a timelocked transaction and returns the block number at which that TX will unlock.

## fetchtx.sh
Takes a TXID as the first argument and returns full TX data, including for transactions that aren't associated with addresses in the local wallet. This is just a wrapper for RPC functions.

## fetchutxos.sh
Takes an address as the first argument and returns all UTXOs for that address. Just used to simplify syntax of the corresponding RPC call.

## getVRSCprice.sh
Fetches the crurent CoinGecko VRSC price. Takes an optional argument for the currency to get the price in, or `list` to get a list of supported currencies. Defaults to USD.

## fetchbootstrap.sh
Fetch a recent bootstrap file with blockchain data to get up and running quickly on a new install or fix a broken instance without re-syncing the whole chain.

## listaddressbalances.sh
List the balance for all addresses that have one, as determined through results of listunspent from the RPC. Tab delimited for easy use in scripting. 

## Misc Notes
If you're working with wallet files, particularly dumps containing plain-text private keys, I highly recommend [tomb](https://www.dyne.org/software/tomb/) for keeping your work safe.
