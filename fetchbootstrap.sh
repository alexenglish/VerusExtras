#!/bin/bash

wget &> /dev/null

if [ "$?" -ne "127" ]; then
    wget https://bootstrap.veruscoin.io/VRSC-bootstrap.tar.gz
else
    curl https://bootstrap.veruscoin.io/VRSC-bootstrap.tar.gz
fi
