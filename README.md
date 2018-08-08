# VerusExtras
Misc scripts for working with Verus Coin

See comments at the top of each script for usage information.

Simple staker shields coinbases to a private address, then moves available private address balances to public addresses (randomly selected from those available, creating new addresses if necessary) for staking. This script can be run manually, set up as a cron job, or used with the blocknotify parameter to execute every X blocks.

Sendmessage will send an encrypted private message using the memo field of a private transaction. It costs a fee to send, and sends a small amount of Verus to the receipient, both of these amounts are configurable.

Getmessages lists memo fields of all transactions received at a particular private address. It's simple and bare-bones, but does the job.
