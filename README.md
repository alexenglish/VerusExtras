# VerusExtras
Misc scripts for working with Verus Coin

All of these scripts have been at least lightly tested, but come with no warranty whatsoever for any purpose. Use at your own risk.

See comments at the top of each script for usage information.

**Important:** The config file in this repo is now named config.example, which will allow you to easily pull updates to the repo without worrying about any changes to your config file. To use the tools in this repo you'll need to copy config.example to config and make any customizations needed. The most common item that needs to be updated is the path you your Verus CLI RPC executable (verus) and optionally any parameters you want to call the verus RPC client with, such as -chain=vrsctest for working on testnet. Some scripts depend on bc (command-line calculator), jq (command-line json parser, constructor, pretty-printer), or xxd (command-line hex-dumps and reverse hex-dumps), you should get notices about these if you try to run scripts that depend on them but can't find them.

## Environment

### verus-completion.bash
Gives tab-completion for the verus and komodo-cli RPC commands in a bash shell. At the moment it only auto-completes commands, but I intend to add support for a few dynamic types. To make use of it run `source verus-completion.bash` in your shell, or add that to your .bashrc (you may have to adjust paths).

### verus-completion.zsh
Gives tab-completion for the verus and komodo-cli RPC commands in a zsh shell. Same instructions as for the bash version, substituting zsh as appropriate.

## External

### getVRSCprice.sh
Fetches the crurent CoinGecko VRSC price. Takes an optional argument for the currency to get the price in, or `list` to get a list of supported currencies. Defaults to USD.

### fetchbootstrap.sh
Fetch a recent bootstrap file with blockchain data to get up and running quickly on a new install or fix a broken instance without re-syncing the whole chain.

## Private Messaging

### sendmessage.sh
Sendmessage will send an encrypted private message using the memo field of a private transaction. It costs a fee to send, and sends a small amount of Verus to the receipient, both of these amounts are configurable.

### getmessages.sh
Getmessages lists memo fields of all transactions received at a particular private address. It's simple and bare-bones, but does the job.

## Formatted Output

### listaddressbalances.sh
List the balance for all addresses that have one, as determined through results of listunspent from the RPC.

### integratedbalance.sh
Presents a nicely structured and pretty-printed json output of current balance information, combining the output of getwalletinfo and z_gettotalbalance to present these balances: transparent, unconfirmed, immature, private, and total (all combined). Also presents private balance as a number, rather than text, unlike z_gettotalbalance.

I have this set as an entry in my .profile on a number of staking systems so the balance is presented on login.

### walletactivity.sh
Shows recent wallet transactions printed in an easy-to-read columnized format, with color coding. There are two optional arguments. The first is the number of transactions to view - the default is 100. The second will create output intended for script parsing if there is any value - colors will be dropped and the output will be plain tab-delimited without column formatting. 

## Scripting Control

### doeachblock.sh
Pass a command and its arguments as arguments to doeachblock.sh and it will execute once each time a new block is found, at a maximum of once a second.

### doeachmempool.sh
Pass a command and its arguments as arguments to doeachmempool.sh and it will execute for each mempool TXID found, appending that TXID to the arguments of the command passed. This will not catch all transactions, since some transactions may make it into blocks without reaching your local mempool, and since there is a 100ms delay between queries to keep system resource usage in check and to prevent flooding the verus daemon. You will also receive duplicates in the case where a transaction in your local mempool is not in the next block you receive - this will run your command once per mempool TXID per block.

### waitforblockheight.sh
Blocks execution (waits/sleeps) until the specified block height is reached. Does nothing on its own other than wait, so it's best used in conjunction with another command, separated by ; or &&.

### waitforverusdexit.sh
Blocks execution (waits/sleeps) until no more instances of verusd are running. Useful when scripting processes that require shutting down verusd. This will wait for any and all instances regardless of their parameters, so testnet, PBaaS chains, etc., will also keep it from exiting.

### waitforblock.sh
Blocks execution until a new block is found. Because multiple blocks in a row can be found quickly from staking, and because this only checks once per second, this cannot be used to guarantee only one block has passed by the time execution resumes.

Typical usage might be something like: `./waitforblock.sh; echo "Found a block."`

## Network Statistics

### avgblocktime.sh
Returns the average block time in seconds for the last N blocks where N is the first and only argument.

### dateofheight.sh
Finds the date/time of a past block height, or makes a reasonable guess about when a future block height will occur.

The first argument is the target block height. The optional second argument will increase verbosity if set (to any value).

### stakingminingratio.sh
Returns the number of mined blocks and staked blocks out of the last N, as well as the ratio between the two.

### timesincelastblock.sh
Provides information about the time since the last block. This was developed with the intention that it would be useful as a frequently updated monitor, such as running it with `watch -n1 ./timesincelastblock.sh`.

### targetheight.sh
Given a UNIX-epoch-formatted timestamp (the first and only argument), estimate the block height at that time.

## Sending/Spending

### chunksend.sh
Send funds to the specified address in separate transactions of the desired size - useful for managing the size of UTXOs, such as for staking.

### spendutxos.sh
Simple wrapper script that automates the signing and broadcasting of a transaction built from a list of input UTXOs (TXID/VOUT) and a list of outputs (addresses/amounts). Be careful to do your math correctly, whatever portion of the sum of the inputs you don't spend to outputs becomes your fee, so it's very easy to send much more than you intend to the miners/stakers. Useage is basically the same as the RPC command createrawtransaction, it just also signs and broadcasts it for you.

### spendsingleutxo.sh
Spend a single, specific UTXO to a given address, minus the fee. Specify the UTXO TXID and VOUT, and the address to send to. Uses spendutxos.sh to do most of the work.

### sweepaddres.sh
Sweeps all funds from an address to another address, less a transaction fee. First argument is the address to sweep, second address is the destination. The funds are all sent in a single transaction and generate a single UTXO (not chunked for staking considerations, etc.). Any address can be used for the source or destination - a private address, transparent address, or an ID referenced by i-address or name (with @); if using an ID name, make sure to use quotes if it contains any whitespace or non-alphanumeric characters to be safe, especially on the destination.

### utxodefrag.sh
Spend all the funds (and all UTXOs) on an address back to the same address in chunks. The first argument is the address, which may be an R-address, an i-address, or an ID name (with @). The optional second argument is the chunk size, which defaults to 5000

## Identities

### identities/vaultcheck.sh
Call with a list (one or more) of IDs to check as arguments. For each the script will report the ID's vault status - unlocked, time lock, delay lock, or revoked. Make sure to put quotes around ID names containing shell special characters or spaces.

## Transaction Data

### fetchtx.sh
Takes a TXID as the first argument and returns full TX data, including for transactions that aren't associated with addresses in the local wallet. This is just a wrapper for RPC functions.

### fetchutxos.sh
Takes an address as the first argument and returns all UTXOs for that address. Just used to simplify syntax of the corresponding RPC call.

### findsmallutxos.sh
Lists the number of UTXOs below the specified size for each address on which there are any. The size is optionally specified as the first(only) argument, and defaults to 5000.

## Wallet Gen

### bip39gen.sh
Generate a random bip39-compatible seed phrase. Please see comments in file for more detailed information on trust. Please take the time to understand how it works so you understand any risks. Use at your own risk! I make no claim of safety, or suitability for any purpose.

## Deprecated
Scripts that are no longer recommended or are less relevant
### simple-staker.sh
Simple staker shields coinbases to a private address, then moves available private address balances to public addresses (randomly selected from those available, creating new addresses if necessary) for staking. This script can be run manually, set up as a cron job, or used with the blocknotify parameter to execute every X blocks (not recommended if you're still syncing the chain).

Deprecated because shielding and unshielding is no longer required and is known to reduce privacy by correlating addresses. Mined coinbases can now be spent or staked directly. Minted (staked) coinbases can be spent directly, but not staked - please see stakepusher.sh for an option to consolidate and spend minted coinbases so they're stakeable.

### decodeunlockheight.py
Takes the script hex for a timelocked transaction and returns the block number at which that TX will unlock. This is no longer relevant on the Verus Chain because all of the initial rewards have unlocked long ago.

### stakepusher.sh
Finds unspent minted (staked) coinbases and spends them forward to the same address to allow them to stake. Preserves privacy by not comingling addresses, and optionally allows the use of a delay to reduce the chances of time-correlation. Now deprecated because this is no longer a requirement for staking coinbases.
