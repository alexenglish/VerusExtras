#!/bin/bash

if command -v wget &>/dev/null ; then
    wget https://bootstrap.verus.io/VRSC-bootstrap.tar.gz
    wget https://bootstrap.verus.io/VRSC-bootstrap.tar.gz.sha256sum
else
    curl https://bootstrap.verus.io/VRSC-bootstrap.tar.gz --output VRSC-bootstrap.tar.gz
    curl https://bootstrap.verus.io/VRSC-bootstrap.tar.gz.sha256sum --output VRSC-bootstrap.tar.gz.sha256sum
fi
