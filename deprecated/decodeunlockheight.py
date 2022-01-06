#!/usr/bin/python
#Copyright Alex English September 2018
#This script comes with no warranty whatsoever. Use at your own risk.

#This script takes as a first (and only) argument the complete script hex string for a CLTV OP_RETURN script as was used for locking the VRSC mining rewards above 192

#There is NO ERROR CHECKING - this assumes well-formed input

#Example use - ./decodeunlockheight.py 6a2a010381cd0cb1752103a6c289dbed0e8dce5c90109989a6443f7ad990facc0ec5db58576c48cb5b5c36ac
#Prints 839041 to standard output

import sys

script=sys.argv[1]
heightbytes=script[6:8]

heighthex = ''

for count in range(1, int(heightbytes,16)+1):
    offset=6+2*count
    heighthex=script[offset:(offset+2)] + heighthex

print int(heighthex,16)
