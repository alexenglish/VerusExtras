# VerusExtras
Misc scripts for working with Verus Coin

See comments at the top of each script for usage information.

##simple-staker.sh
Simple staker shields coinbases to a private address, then moves available private address balances to public addresses (randomly selected from those available, creating new addresses if necessary) for staking. This script can be run manually, set up as a cron job, or used with the blocknotify parameter to execute every X blocks (not recommended if you're still syncing the chain).

##sendmessage.sh
Sendmessage will send an encrypted private message using the memo field of a private transaction. It costs a fee to send, and sends a small amount of Verus to the receipient, both of these amounts are configurable.

##getmessages.sh
Getmessages lists memo fields of all transactions received at a particular private address. It's simple and bare-bones, but does the job.

##Misc Notes
If you're working with wallet files, particularly dumps containing plain-text private keys, I highly recommend [tomb](https://www.dyne.org/software/tomb/) for keeping your work safe.
