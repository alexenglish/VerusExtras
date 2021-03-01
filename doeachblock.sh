#!/bin/bash
#Copyright Alex English February 2021
#This script comes with no warranty whatsoever. Use at your own risk.

#Executes a given command (and any arguments that follow) once for each block that's found, or every 1 seconds, whichever is longer (1 second polling interval), also executes once immediately when launched
#If you need something that actually executes once for each block use the blocknotify parameter on verusd or in VRSC.conf, this script is intended to keep from piling up when consecutive staking blocks flood in.

#The arguments are run with no checks whatsoever, and is forked to the background
#example: ./doeachblock.sh echo "Found new block"

if ! source "$( dirname "${BASH_SOURCE[0]}" )"/config; then
    echo "Failed to source config file. Please make sure you have the whole VerusExtras repo or at least also have the config file."
    exit 1
fi

LASTHEIGHT=$($VERUS getblockcount)
#make sure the test is executed on the first loop
LASTHEIGHT=$((LASTHEIGHT - 1))

echo "Entering loop, you'll have to kill this process (CTRL-C or kill from another terminal) to end"
sleep 1

while true; do
    HEIGHT=$($VERUS getblockcount)
    if [ $HEIGHT -gt $LASTHEIGHT ]; then
        $@ &
    fi
    #there might be a new block by the time all of that finishes running
    LASTHEIGHT=$($VERUS getblockcount)
    sleep 1
done
