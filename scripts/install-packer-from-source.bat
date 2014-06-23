
if exist %WinDir%\microsoft.net\framework\v4.0.30319 goto :have_net
echo Ensuring .NET 4.0 is installed
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.github.com/StefanScherer/arduino-ide/install/InstallNet4.ps1'))"
:have_net
if "%ChocolateyInstall%x"=="x" set ChocolateyInstall=%SystemDrive%\Chocolatey
if exist %ChocolateyInstall% goto :have_choco
echo Installing Chocolatey
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin
:have_choco

where cinst
if ERRORLEVEL 1 goto set_chocolatey
goto inst
:set_chocolatey
set PATH=%PATH%;%ChocolateyInstall%\bin
:inst

:install_packer

call cinst golang
set PATH=%PATH%;c:\go\bin

call cinst git
where git
if ERRORLEVEL 1 call :addGitToUserPath
goto GIT_DONE
:addGitToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;C:\Program Files (x86)\Git\cmd" /f
set PATH=%PATH%;C:\Program Files (x86)\Git\cmd
exit /b
:GIT_DONE

call cinst bzr
set PATH=%PATH%;c:\program files (x86)\Bazaar

call cinst hg
set PATH=%PATH%;c:\program files\Mercurial

set GOPATH=C:\users\vagrant\go
setx GOPATH C:\users\vagrant\go

mkdir %GOPATH%\bin

call :addGoPathToUserPath
goto GOPATH_DONE
:addGoPathToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;%GOPATH%\bin" /f
set PATH=%PATH%;%GOPATH%\bin
exit /b
:GOPATH_DONE


echo Downloading and compiling packer
go get github.com/mitchellh/packer
cd /D %GOPATH%\src\github.com\mitchellh\packer
go get ./...
cd /D %GOPATH%\bin
for /f "tokens=1" %%i in ('dir /b builder* command* post* provision*') DO if exist packer-%%i del packer-%%i
for /f "tokens=1" %%i in ('dir /b builder* command* post* provision*') DO ren %%i packer-%%i

echo Downloading and compiling packer-post-processor-vagrant-vmware-ovf
go get github.com/gosddc/packer-post-processor-vagrant-vmware-ovf

set packerconfig=%AppData%\packer.config
echo { > %packerconfig%
echo  "post-processors": { >> %packerconfig%
echo      "vagrant-vmware-ovf": "packer-post-processor-vagrant-vmware-ovf" >> %packerconfig%
echo  } >> %packerconfig%
echo } >> %packerconfig%

cd /D %USERPROFILE%
where packer
packer --version

