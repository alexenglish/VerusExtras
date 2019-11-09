#!/bin/bash
#Copyright Alex English August 2018
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Ubuntu 16.04, 18.04
#Make sure you have a correct path set for the verus cli and that you've adjusted the variables below to suit your needs.

#This script will act on all unshielded coinbases and on all z_address balances

#Dependencies: bc (calculator)

#You can execute it manually whenever you want,
#or add the full path of the script to your VRSC.conf file
#using the parameter blocknotify=<path>
#The script needs to be run multiple times to carry funds forward through the two steps to go from block reward to staking. Recommended options are to run on a cron job every 3 to 5 minutes, or to run when new blocks are added using the blocknotify parameter to verusd as mentioned above. 
#The blocknotify method is not recommended if you are not yet synced to the chain - make sure you're in sync, or close to it before setting this up with blocknotify

source config

#Desired target size for stakes
#smaller amounts will stake in full each time
#amounts larger than TARGET_STAKE will be staked at values ranging between TARGET_STAKE and TARGET_STAKE*2
TARGET_STAKE=250
TX_FEE=0.0001

#Only run every X blocks, useful if being run via blocknotify
#Recommended values are 3 to 10, set to zero to run every time this script is called regardless of the block number, which is useful if you're running it manually or on a cron job
#Keep in mind that the private transactions used for shielding are both memory and computation intensive, for machines doing PoW mining this should be set high so it doesn't spend as much time crunching the shielding transactions relative to the time spent on PoW.
X=4

#Check for bc dependency
bc --version &> /dev/null
if [ $? -eq 127 ]; then
    echo "Please install bc (a command-line calculator)"
    exit 1
fi

HEIGHT=$($VERUS getblockcount)
if [ $X -ne 0 ]; then
    if [ $((HEIGHT % X)) -ne 0 ]; then
        #echo "It is not yet time to shield and stake"
        exit 0
    fi
fi

echo "Attempting to shield and distribute coinbases for staking"

STAT=$($VERUS z_getoperationstatus | grep status | awk '{ print $2 }' | sed -e '$!d' -e 's/^"//' -e 's/",$//')

if [ "$STAT" == 'executing' -o "$STAT" == 'queued' ]; then
    echo "Waiting until ops queue is finished"
    exit 0
fi

#Do we have any coinbase UTXOs to shield?
CB=$($VERUS listunspent | grep "generated" | grep "true" | wc -l)

if [ -z "$CB" ]; then
    echo "Could not retrieve unspent UTXO info."
    exit 1
fi

if [ $(bc<<<"$CB > 0") -gt 0 ]; then 
    echo "*******************************************************"
    echo "          Auto-shielding $CB Coinbases"
    #echo "Setting tx fee to $TX_FEE"
    $VERUS settxfee $TX_FEE > /dev/null

    #echo "Fetching first z_address"
    ZADDR=$($VERUS z_listaddresses | grep '"' | tr -d '",' | head -n 1)

    if [ -z "$ZADDR" ]; then
        #there were none, make one
        echo "Creating new z_address"
        ZADDR=$($VERUS z_getnewaddress)
    fi

    echo "Using z_address: $ZADDR"

    #Shield coinbases to the z_address
    #echo "Shielding Coinbases"
    $VERUS z_shieldcoinbase "*" "$ZADDR" "$TX_FEE" 10
fi

#Do we have any funds in private addresses to move for staking?
ZB=$($VERUS z_gettotalbalance | grep private | awk '{print $2}' | tr -d '",')

if [ -z "$ZB" ]; then
    echo "Could not retrieve balances."
    exit 1
fi

if [ $(bc<<<"$ZB > $TX_FEE") -gt 0 ]; then
    echo "*******************************************************"
    echo "          Auto-staking $ZB z_address coins"
    #echo "Set tx fee to $TX_FEE"
    $VERUS settxfee $TX_FEE > /dev/null

    declare -a ADDR
    readarray -t ADDR < <($VERUS getaddressesbyaccount "" | sed -e '1d' -e '$d' | tr -d ' ",' | sort -R) 

    #for each z_address
    for Z in $($VERUS z_listaddresses | grep '"' | tr -d '",' | head -n 1); do
        SENDS=""

        #retrieve the balance of the address
        BAL=$($VERUS z_getbalance "$Z")

        if [ $(bc<<<"$BAL == 0") -gt 0 ]; then
            continue
        fi

        echo "Operating on address: $Z"

        BAL=$(bc<<<"$BAL - $TX_FEE")
        echo "Usable Balance: $BAL"

        #skip if zero balance, balance lower than fee, or malformed
        if [ $(bc<<<"$BAL <= 0") -gt 0 ]; then
            echo "Low balance or bad data"
            continue
        fi

        N=$(bc<<<"$BAL / $TARGET_STAKE")
        if [ $N -le 0 ]; then
            N=1
        fi

        AMT=$(bc<<<"scale=8; $BAL / $N")

        echo "Building transaction with $N x $AMT outputs, totalling $BAL"


        #check to make sure there are enough addresses
        while [ ${#ADDR[@]} -lt $N ]; do
            ADDR+=$($VERUS getnewaddress)
        done

        for n in $(seq 0 $(bc<<<"($N - 1)/1")); do
            #truncate or pad AMT to 8 decimal places
            AMT=$(printf "%.8f\n" $AMT)

            if [ $(bc<<<"$AMT > 0") -gt 0 ]; then
                SENDS+="{\"address\":\"${ADDR[$n]}\",\"amount\":$AMT},"
            fi
        done

        #submit TX
        if [ -n "$SENDS" ]; then 
            SENDS="[${SENDS%,}]"
            echo "z_sendmany \"$Z\" \"$SENDS\""
            $VERUS z_sendmany "$Z" "$SENDS"
        fi
    done
else
    #echo "No stakable, unstaked funds found"
    :
fi
