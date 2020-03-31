@Echo off
rem Copyright Frank van den Brink February 2020
rem Released under MIT license
rem This script comes with no warranty whatsoever. Use at your own risk.
rem Tested on windows 10 Pro version 1903 build 18362.592

rem This script downloads the bootstrap and its sha256sum hash file, compares it
rem and if validated checks if Verus daemon is not running. If not running it extracts
rem the bootstrap to the standard chain location on disk if no location is specified
rem on the command line.

rem *********************************************************************
rem ******                 COMMAND LINE usage:                     ******
rem *********************************************************************
rem ****** VRSC-bootstrap-win.bat <path>                           ******
rem ******                                                         ******
rem ****** The <path> parameter is optional, if not specified      ******
rem ****** the batch file will extract to the standard chain       ******
rem ****** location for the current user.                          ******
rem *********************************************************************


rem This script only uses OS native commands, without any external dependencies.

@call :GET_CURRENT_DIR
cls
Echo *******************************************************************
Echo ***                                                             ***
Echo *** This script downloads the bootstrap and checksum files from ***
Echo ***   https://bootstrap.veruscoin.io                            ***
Echo *** and checks the download checksum for validity.              ***
Echo *** If no targetlocation is specified, this script will         ***
Echo *** automaticaly extract the contents of the bootstrap to       ***
Echo ***   %AppData%\Komodo\VRSC ***
Echo *** and removes the bootstrap archives to free drive space      ***
Echo ***                                                             ***
Echo *** USAGE:                                                      ***
Echo *** VRSC-bootstrap-win <Drive>:<Path>                           ***
Echo ***                                                             ***
Echo *** The optional parameter <Drive>:<Path> will cause the        ***
Echo *** bootstrap to be extracted in the location specified.        ***
Echo ***                                                             ***
Echo *******************************************************************
Echo ***                                                             ***
Echo ***   Please make sure Agama, Verus Desktop or Verus-CLI        ***
Echo ***                                                             ***
Echo ***                       is NOT running                        ***
Echo ***                                                             ***
Echo *******************************************************************
pause
rem *********************************************************************
rem ******                 setting parameters                      ******
rem *********************************************************************

set URL=https://bootstrap.veruscoin.io
set bootstrapName=VRSC-bootstrap.tar.gz
set ChainDir=%AppData%\komodo\VRSC

rem *** Do NOT change the variable below ***
popd
set THIS_DIR=%~dp0
set bootstrapURL=%URL%/%bootstrapName%
set bootstrapchecksumName=%bootstrapName%.sha256sum
set bootstrapchecksumURL=%URL%/%bootstrapchecksumName%
set "checksum="

rem *********************************************************************
rem ******              reading CMD-line options                   ******
rem *********************************************************************
IF "%1"=="" GOTO EndCmdOptions
set ChainDir=%1

:EndCmdOptions
IF EXIST %ChainDir% (
  Echo *******************************************************************
  Echo ***                                                             ***
  Echo ***              Chaindata folder does exist                    ***
  Echo ***                                                             ***
  Echo *******************************************************************
  ) ELSE (
  Echo *******************************************************************
  Echo ***                                                             ***
  Echo ***           Chaindata folder does not exist yet               ***
  Echo ***             Creating folder and continuing                  ***
  Echo ***                                                             ***
  Echo *******************************************************************
  md %ChainDir%
  )

Echo ***                                                             ***
Echo ***                    downloading files                        ***
Echo ***                                                             ***
Echo *******************************************************************

cd %ChainDir%
curl -# -O %bootstrapchecksumURL%
curl -# -O %bootstrapURL%

Echo ***                                                             ***
Echo ***                Checking download integrity                  ***
Echo ***                                                             ***
Echo *******************************************************************

CertUtil -hashfile %bootstrapName% sha256 > checksum.txt
for /f "skip=1 delims=," %%i in (checksum.txt) do if not defined checksum set "checksum=%%i"
find /c "%checksum%" %bootstrapchecksumName%
if %errorlevel% equ 1 goto CheckSumInvalid

cls
Echo *******************************************************************
Echo ***                                                             ***
Echo ***                Integrity check valid...                     ***
Echo ***                                                             ***
Echo *******************************************************************
goto CheckSumValid

:not CheckSumInvalid
Echo ***                                                             ***
Echo ***               Integrity check invalid...                    ***
Echo ***                                                             ***
Echo *******************************************************************
goto :FAILED

:CheckSumValid
Echo ***                                                             ***
Echo ***            Checking if Coindaemon is running                ***
Echo ***                                                             ***
Echo *******************************************************************

tasklist /FI "IMAGENAME eq verusd.exe" 2>NUL | find /I /N "verusd.exe">NUL
rem if "%ERRORLEVEL%"=="0" goto :DeamonRunning
 Echo ***                                                             ***
Echo ***                Coindaemon is NOT running                    ***
Echo ***                                                             ***
Echo *******************************************************************
Echo ***                                                             ***
Echo ***                   Extracting Bootstrap                      ***
Echo ***                                                             ***
Echo *******************************************************************

tar -xf %bootstrapName%
del %bootstrapName%
del %bootstrapchecksumName%
del checksum.txt

goto :SUCCESS

:SUCCESS
Echo *******************************************************************
Echo ***                                                             ***
Echo ***                Bootstrap installation SUCCESS               ***
Echo ***                                                             ***
Echo *******************************************************************
goto :END

:DeamonRunning
cls
Echo *******************************************************************
Echo ***                                                             ***
Echo ***                    Coindaemon is running                    ***
Echo ***                                                             ***
Echo *******************************************************************
Echo ***                                                             ***
Echo ***           Please close Agama and/or Verus-CLI and           ***
Echo ***                  run this script again!!!                   ***
Echo ***                                                             ***
Echo *******************************************************************
:FAILED
Echo ***                                                             ***
Echo ***                Bootstrap installation FAILED                ***
Echo ***                                                             ***
Echo *******************************************************************

:END
@echo off
cd %THIS_DIR%
pause
:EOF
