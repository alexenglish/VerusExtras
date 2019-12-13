#!/bin/bash
#Copyright Frank van den Brink Ocober 2019
#Released under MIT license
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Ubuntu 18.04

#This script downloads the bootstrap and its sha256sum hash file, compares it
#and if validated checks if Verus daemon is not running. If not running it extracts
#the bootstrap to the standard chain location on disk.

#This script only uses OS native commands, without any external dependencies.

cd ~
mkdir ~/bootstrap
cd ~/bootstrap
clear
echo "*******************************************************************"
echo "***                                                             ***"
echo "*** This script downloads the bootstrap and checksum files from ***"
echo "***   https://bootstrap.0x03.services/veruscoin                 ***"
echo "*** and checks the download checksum for validity.              ***"
echo "*** It automaticaly extracts the contents of the bootstrap to   ***"
echo "***   ~/.komodo/VRSC                                            ***"
echo "*** and removes the bootstrap archives to free drive space      ***"
echo "***                                                             ***"
echo "*******************************************************************"
echo "***                                                             ***"
echo "***   Please make sure Agama or Verus-CLI is NOT running        ***"
echo "***                                                             ***"
echo "*******************************************************************"
echo " "
echo "*******************************************************************"
echo "***                                                             ***"
echo "***                    downloading files                        ***"
echo "***                                                             ***"
echo "*******************************************************************"


wget --progress=dot:mega --continue --retry-connrefused --waitretry=3 --timeout=30 https://bootstrap.veruscoin.io/veruscoin/VRSC-bootstrap.tar.gz
wget --progress=dot:mega --continue --retry-connrefused --waitretry=3 --timeout=30 https://bootstrap.veruscoin.io/veruscoin/VRSC-bootstrap.tar.gz.sha256sum

clear
echo "*******************************************************************"
echo "***                                                             ***"
echo "***                Checking download integrity                  ***"
echo "***                                                             ***"
echo "*******************************************************************"

sha256sum -c VRSC-bootstrap.tar.gz.sha256sum > checkresult
if grep -q OK "checkresult"; then
	cls
	echo "*******************************************************************"
	echo "***                                                             ***"
	echo "***                Integrity check valid...                     ***"
	echo "***                                                             ***"
	echo "*******************************************************************"
else
	cls
	echo "*******************************************************************"
	echo "***                                                             ***"
	echo "***               Integrity check invalid...                    ***"
	echo "***                                                             ***"
	echo "*******************************************************************"
	exit
fi

clear
echo "*******************************************************************"
echo "***                                                             ***"
echo "***            Checking if Coindaemon is running                ***"
echo "***                                                             ***"
echo "*******************************************************************"

pgrep -x verusd >/dev/null && export found=1 || export found=0

if [ "$found" == "1" ];
then
        echo "*******************************************************************"
        echo "***                                                             ***"
        echo "***                   Coindaemon IS running                     ***"
        echo "***                          EXITING                            ***"
        echo "***                                                             ***"
        echo "*******************************************************************"
        exit
fi
echo "*******************************************************************"
echo "***                                                             ***"
echo "***                Coindaemon is NOT running                    ***"
echo "***                                                             ***"
echo "*******************************************************************"
echo "*******************************************************************"
echo "***                                                             ***"
echo "***                   Extracting Bootstrap                      ***"
echo "***                                                             ***"
echo "*******************************************************************"

cd ~/.komodo/VRSC
tar -xf ~/bootstrap/VRSC-bootstrap.tar.gz
rm -R ~/bootstrap
