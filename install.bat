
rem Install packer 0.5.1
if exist c:\hashicorp\packer\packer.exe goto PACKER_INSTALLED
wget --no-check-certificate https://dl.bintray.com/mitchellh/packer/0.5.1_windows_amd64.zip -O %TEMP%\0.5.1_windows_amd64.zip
mkdir c:\hashicorp\packer
cd /D c:\hashicorp\packer
unzip %TEMP%\0.5.1_windows_amd64.zip
cd /D %USERPROFILE%
where packer
if ERRORLEVEL 1 call :addPackerToUserPath
goto PACKER_INSTALLED
:addPackerToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;C:\hashicorp\packer" /f
set PATH=%PATH%;C:\hashicorp\packer
exit /b
:PACKER_INSTALLED


rem Install VirtualBox 4.3.6
if exist "c:\program files\oracle\virtualbox\vboxmanage.exe" goto VIRTUALBOX_INSTALLED
wget http://download.virtualbox.org/virtualbox/4.3.6/VirtualBox-4.3.6-91406-Win.exe -O %TEMP%\VirtualBox-4.3.6-91406-Win.exe
%TEMP%\VirtualBox-4.3.6-91406-Win.exe -s
where vboxmanage
if ERRORLEVEL 1 call :addVirtualBoxToUserPath
goto VIRTUALBOX_INSTALLED
:addVirtualBoxToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;c:\program files\oracle\virtualbox" /f
set PATH=%PATH%;c:\program files\oracle\virtualbox
exit /b
:VIRTUALBOX_INSTALLED


