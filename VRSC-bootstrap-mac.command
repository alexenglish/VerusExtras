#!/bin/bash
#Copyright Frank van den Brink Ocober 2019
#Released under MIT licence
#This script comes with no warranty whatsoever. Use at your own risk.
#Tested on Mac OS Mojave 10.14

#This script downloads the bootstrap and its md5sum hash file, compares it
#and if validated, checks if Verus daemon is not running. If not running it extracts
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


curl -# -O https://bootstrap.veruscoin.io/VRSC-bootstrap.tar.gz
curl -# -O https://bootstrap.veruscoin.io/VRSC-bootstrap.tar.gz.md5sum

clear
echo "*******************************************************************"
echo "***                                                             ***"
echo "***                Checking download integrity                  ***"
echo "***                                                             ***"
echo "*******************************************************************"

echo "checking file VRSC-bootstrap.tar.gz"
file1=`md5 -q VRSC-bootstrap.tar.gz`
echo $file1
echo "Using md5 file VRSC-bootstrap.tar.gz.md5sum"
file2=`cut -c1-32 VRSC-bootstrap.tar.gz.md5sum`
echo $file2

if [ $file1 != $file2 ]
then
	cls
	echo "*******************************************************************"
	echo "***                                                             ***"
	echo "***               Integrity check invalid...                    ***"
	echo "***                                                             ***"
	echo "*******************************************************************"
	exit
else
	cls
	echo "*******************************************************************"
	echo "***                                                             ***"
	echo "***                Integrity check valid...                     ***"
	echo "***                                                             ***"
	echo "*******************************************************************"
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

cd ~/Library/Application\ Support/Komodo/VRSC
tar -xf ~/bootstrap/VRSC-bootstrap.tar.gz
rm -R ~/bootstrap
echo "*******************************************************************"
echo "***                                                             ***"
echo "***                Bootstrap successfully installed             ***"
echo "***                                                             ***"
echo "***        You can close this windows and start Agama now       ***"
echo "***                                                             ***"
echo "*******************************************************************"
