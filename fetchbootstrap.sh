#!/bin/bash

wget &> /dev/null

if [ "$?" -ne "127" ]; then
    wget https://bootstrap.0x03.services/veruscoin/VRSC-bootstrap.tar.gz
else
    curl https://bootstrap.0x03.services/veruscoin/VRSC-bootstrap.tar.gz > VRSC-bootstrap.tar.gz
fi
