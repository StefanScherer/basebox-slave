echo Extend drive C to maximum
echo select volume 0 >%TEMP%\extendC.txt
echo extend >>%TEMP%\extendC.txt
diskpart.exe /s %TEMP%\extendC.txt

if exist c:\vagrant\resources\activate.bat call c:\vagrant\resources\activate.bat

if exist %WinDir%\microsoft.net\framework\v4.0.30319 goto :have_net
echo Ensuring .NET 4.0 is installed
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.github.com/StefanScherer/arduino-ide/install/InstallNet4.ps1'))"
:have_net
if "%ChocolateyInstall%x"=="x" set ChocolateyInstall=%ALLUSERSPROFILE%\Chocolatey
if exist %ChocolateyInstall% goto :have_chocolatey
echo Installing Chocolatey
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
:have_chocolatey

where cinst
if ERRORLEVEL 1 goto set_chocolatey
goto inst
:set_chocolatey
set PATH=%PATH%;%ChocolateyInstall%\bin
:inst

cinst wget

cinst msysgit
where git
if ERRORLEVEL 1 call :addGitToUserPath
goto GIT_DONE
:addGitToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;C:\Program Files (x86)\Git\cmd" /f
set PATH=%PATH%;C:\Program Files (x86)\Git\cmd
exit /b
:GIT_DONE

cinst packer
where packer
if ERRORLEVEL 1 call :addPackerToSystemPath
goto PACKER_DONE
:addPackerToSystemPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v Path ^| findstr /i path') do set OLD_SYSTEM_PATH=%%g
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v Path /d "%OLD_SYSTEM_PATH%;C:\hashicorp\packer" /f
set PATH=%PATH%;C:\hashicorp\packer
exit /b
:PACKER_DONE

:packer_firewall
netsh advfirewall firewall add rule name="packer-builder-vmware-iso" dir=in program="c:\HashiCorp\packer\packer-builder-vmware-iso.exe" action=allow
netsh advfirewall firewall add rule name="packer-builder-virtualbox-iso" dir=in program="c:\HashiCorp\packer\packer-builder-virtualbox-iso.exe" action=allow
netsh advfirewall firewall add rule name="packer-builder-vmware-iso" dir=in program="c:\Users\vagrant\go\bin\packer-builder-vmware-iso.exe" action=allow
netsh advfirewall firewall add rule name="packer-builder-virtualbox-iso" dir=in program="c:\Users\vagrant\go\bin\packer-builder-virtualbox-iso.exe" action=allow

if exist c:\hashicorp\vagrant goto :have_vagrant
echo Installing Vagrant ...
cinst vagrant
set PATH=%PATH%;C:\hashicorp\vagrant\bin
:have_vagrant

echo Installing Stefan's vagrant-serverspec 0.5.0 ...
wget --no-verbose --no-check-certificate -O vagrant-serverspec-0.5.0.gem https://github.com/StefanScherer/vagrant-serverspec/releases/download/v0.5.0/vagrant-serverspec-0.5.0.gem
vagrant plugin install vagrant-serverspec-0.5.0.gem

echo "Installing Jenkins Swarm Client"
call c:\vagrant\scripts\install-jenkins-slave.bat virtualbox

if exist "c:\Program Files\Oracle\VirtualBox" goto :have_vbox
echo Installing VirtualBox - delayed - guest will reboot
start c:\vagrant\scripts\install-virtualbox-and-reboot.bat
:have_vbox

if exist C:\vagrant\resources\hosts (
  echo Appending additional hosts entries
  copy C:\Windows\System32\drivers\etc\hosts + C:\vagrant\resources\hosts C:\Windows\System32\drivers\etc\hosts
)
