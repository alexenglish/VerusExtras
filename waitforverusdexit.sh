#!/bin/bash

#Copyright Alex English April 2021
#This script comes with no warranty whatsoever. Use at your own risk.

#This script just blocks execution until verusd exits. Use it for performing actions in a script after intentionally stopping verusd, or use for alarming if verusd fails, etc.
#If there are multiple instances of verusd running, this will not detect any of them going down, it will only exit when there are NO running instances of verusd

#passing any argument will make it run in verbose mode, telling you each time it checks

while pidof verusd &>/dev/null; do
    if [ $# -gt 0 ]; then 
        echo "verusd still running";
    fi

    sleep 2
done
