echo Extend drive C to maximum 
echo select volume 0 >%TEMP%\extendC.txt
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

call cinst msysgit
where git
if ERRORLEVEL 1 call :addGitToUserPath
goto GIT_DONE
:addGitToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;C:\Program Files (x86)\Git\cmd" /f
set PATH=%PATH%;C:\Program Files (x86)\Git\cmd
exit /b
:GIT_DONE


call c:\vagrant\scripts\install-packer-from-source.bat
goto packer_firewall

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

:packer_firewall
netsh advfirewall firewall add rule name="packer-builder-vmware-iso" dir=in program="c:\HashiCorp\packer\packer-builder-vmware-iso.exe" action=allow
netsh advfirewall firewall add rule name="packer-builder-virtualbox-iso" dir=in program="c:\HashiCorp\packer\packer-builder-virtualbox-iso.exe" action=allow
netsh advfirewall firewall add rule name="packer-builder-vmware-iso" dir=in program="c:\Users\vagrant\go\bin\packer-builder-vmware-iso.exe" action=allow
netsh advfirewall firewall add rule name="packer-builder-virtualbox-iso" dir=in program="c:\Users\vagrant\go\bin\packer-builder-virtualbox-iso.exe" action=allow

rem Install VMware Workstation
if not exist "c:\Program Files (x86)\VMware\VMware Workstation" (
  if not exist "%TEMP%\VMware-workstation.exe" (
    echo Downloading VMware Workstation...
    call wget --no-verbose --no-check-certificate -O "%TEMP%\VMware-workstation.exe" http://www.vmware.com/go/tryworkstation-win
  )
  echo Install VMware Workstation...
  rem "%TEMP%\VMware-workstation.exe" /s /nsr /v EULAS_AGREED=1 SERIALNUMBER="xxxxx-xxxxx-xxxxx-xxxxx-xxxxx"
  "%TEMP%\VMware-workstation.exe" /s /nsr /v EULAS_AGREED=1
  del "%TEMP%\VMware-workstation.exe"
)

