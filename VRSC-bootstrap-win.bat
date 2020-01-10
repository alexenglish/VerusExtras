@Echo off
rem Copyright Frank van den Brink October 2019
rem Released under MIT license
rem This script comes with no warranty whatsoever. Use at your own risk.
rem Tested on windows 10 Pro version 1709 build 16299.125

rem This script downloads the bootstrap and its sha256sum hash file, compares it
rem and if validated checks if Verus daemon is not running. If not running it extracts
rem the bootstrap to the standard chain location on disk.

rem This script only uses OS native commands, without any external dependencies.

@call :GET_CURRENT_DIR
cls
Echo *******************************************************************
Echo ***                                                             ***
Echo *** This script downloads the bootstrap and checksum files from ***
Echo ***   https://bootstrap.0x03.services/veruscoin                 ***
Echo *** and checks the download checksum for validity.              ***
Echo *** It automaticaly extracts the contents of the bootstrap to   ***
Echo ***   %AppData%\Komodo\VRSC ***
Echo *** and removes the bootstrap archives to free drive space      ***
Echo ***                                                             ***
Echo *******************************************************************
Echo ***                                                             ***
Echo ***   Please make sure Agama, Verus Desktop or Verus-CLI        ***
Echo ***                                                             ***
Echo ***                       is NOT running                        ***
Echo ***                                                             ***
Echo *******************************************************************
pause
cls
Echo *******************************************************************
Echo ***                                                             ***
Echo ***                    downloading files                        ***
Echo ***                                                             ***
Echo *******************************************************************

cd %Appdata%/komodo/VRSC
bitsadmin /transfer BOOTSTRAP /download /priority foreground https://bootstrap.veruscoin.io/VRSC-bootstrap.tar.gz %THIS_DIR%\VRSC-bootstrap.tar.gz
bitsadmin /transfer CHECKSUM /download /priority foreground https://bootstrap.veruscoin.io/VRSC-bootstrap.tar.gz.sha256sum %THIS_DIR%\VRSC-bootstrap.tar.gz.sha256sum

cls
Echo *******************************************************************
Echo ***                                                             ***
Echo ***                Checking download integrity                  ***
Echo ***                                                             ***
Echo *******************************************************************

CertUtil -hashfile VRSC-bootstrap.tar.gz sha256 > checksum.txt
set "checksum="
for /f "skip=1 delims=," %%i in (checksum.txt) do if not defined checksum set "checksum=%%i"
find /c "%checksum%" VRSC-bootstrap.tar.gz.sha256sum
if %errorlevel% equ 1 goto notfound
cls
Echo *******************************************************************
Echo ***                                                             ***
Echo ***                Integrity check valid...                     ***
Echo ***                                                             ***
Echo *******************************************************************
goto done

:notfound
cls
Echo *******************************************************************
Echo ***                                                             ***
Echo ***               Integrity check invalid...                    ***
Echo ***                                                             ***
Echo *******************************************************************
goto :FAILED
:done

cls
Echo *******************************************************************
Echo ***                                                             ***
Echo ***            Checking if Coindaemon is running                ***
Echo ***                                                             ***
Echo *******************************************************************

tasklist /FI "IMAGENAME eq verusd.exe" 2>NUL | find /I /N "verusd.exe">NUL
if "%ERRORLEVEL%"=="0" goto :DeamonRunning
cls
Echo *******************************************************************
Echo ***                                                             ***
Echo ***                Coindaemon is NOT running                    ***
Echo ***                                                             ***
Echo *******************************************************************
pause

cls
Echo *******************************************************************
Echo ***                                                             ***
Echo ***                   Extracting Bootstrap                      ***
Echo ***                                                             ***
Echo *******************************************************************

tar -xf %VRSC-bootstrap.tar.gz
del VRSC-bootstrap.tar.gz
del VRSC-bootstrap.tar.gz.sha256
del checksum.txt

goto :SUCCESS

:GET_CURRENT_DIR
@pushd %~dp0
@set THIS_DIR=%CD%
@popd

:SUCCESS
Echo *******************************************************************
Echo ***                                                             ***
Echo ***                Bootstrap installation SUCCESS               ***
Echo ***                                                             ***
Echo *******************************************************************
goto :EOF

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
goto :EOF

:EOF
cd %THIS_DIR%
pause
