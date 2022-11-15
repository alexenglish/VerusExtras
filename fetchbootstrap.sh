#!/bin/bash

if command -v wget &>/dev/null ; then
    wget https://bootstrap.verus.io/VRSC-bootstrap.tar.gz
else
    curl https://bootstrap.verus.io/VRSC-bootstrap.tar.gz --output VRSC-bootstrap.tar.gz
fi
