echo Extend drive C to maximum 
echo select volume 2 >%TEMP%\extendC.txt
echo extend >>%TEMP%\extendC.txt
diskpart.exe /s %TEMP%\extendC.txt
set WORKDRIVE=C:

echo Ensuring .NET 4.0 is installed
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.github.com/StefanScherer/arduino-ide/install/InstallNet4.ps1'))"
echo Installing Chocolatey
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin

if "%ChocolateyInstall%x"=="x" set ChocolateyInstall=%SystemDrive%\Chocolatey
where cinst
if ERRORLEVEL 1 goto set_chocolatey
goto inst
:set_chocolatey
set PATH=%PATH%;%ChocolateyInstall%\bin
:inst

call cinst wget

rem workaround until chocolatey has a vagrant 1.6 package
rem call cinst vagrant
echo Downloading Vagrant 1.6.3
call wget --no-check-certificate --no-verbose https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3.msi -O %TEMP%\vagrant.msi
echo Installing Vagrant 1.6.3
msiexec /i %TEMP%\vagrant.msi /quiet
echo Vagrant 1.6.3 installed
set PATH=%PATH%;%SystemDrive%\hashicorp\vagrant\bin
cd /D %USERPROFILE%\Documents
vagrant plugin install vagrant-vcloud

call cinst msysgit
set PATH=%PATH%;C:\Program Files (x86)\Git\cmd

set ROECLOUDSRV001=roecloudsrv001.sealsystems.local
set ROECLOUDSRV001=10.100.100.101

call cinst packer
where packer
if ERRORLEVEL 1 call :addPackerToUserPath
goto PACKER_DONE
:addPackerToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;C:\hashicorp\packer" /f
set PATH=%PATH%;C:\hashicorp\packer
exit /b
:PACKER_DONE
call cinst packer-post-processor-vagrant-vmware-ovf

call cinst SublimeText3.app

if not exist %WORKDRIVE%\GitHub mkdir %WORKDRIVE%\GitHub
cd /D %WORKDRIVE%\GitHub
if not exist ubuntu-vm (
  git clone -b my https://github.com/StefanScherer/ubuntu-vm.git
) else (
  cd ubuntu-vm
  git pull
  cd ..
)

if not exist packer-windows (
  git clone -b my https://github.com/StefanScherer/packer-windows.git
) else (
  cd packer-windows
  git pull
  cd ..
)

echo Install VMware Workstation...
rem Install VMware Workstation
if not exist "%USERPROFILE%\AppData\Roaming\VMWare\preferences.ini" (
  if not exist "%USERPROFILE%\AppData\Roaming\VMWare" mkdir "%USERPROFILE%\AppData\Roaming\VMWare"
  call wget --no-check-certificate -O "%USERPROFILE%\AppData\Roaming\VMWare\preferences.ini" https://raw.github.com/StefanScherer/basebox-slave/master/preferences.ini
)
if not exist "c:\Program Files (x86)\VMware\VMware Workstation" (
  if not exist "%TEMP%\VMware-workstation-full-10.0.0-1295980.exe" (
    call wget -O "%TEMP%\VMware-workstation-full-10.0.0-1295980.exe" http://%ROECLOUDSRV001%/vmware/workstation10/VMware-workstation-full-10.0.0-1295980.exe
  )
  rem "%TEMP%\VMware-workstation-full-10.0.0-1295980.exe" /s /nsr /v EULAS_AGREED=1 SERIALNUMBER="xxxxx-xxxxx-xxxxx-xxxxx-xxxxx"
  "%TEMP%\VMware-workstation-full-10.0.0-1295980.exe" /s /nsr /v EULAS_AGREED=1 
  del "%TEMP%\VMware-workstation-full-10.0.0-1295980.exe"
)


cd %WORKDRIVE%\GitHub\packer-windows
vagrant --version
packer --version

