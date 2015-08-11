if exist c:\vagrant\resources\provisionfirst.bat call c:\vagrant\resources\provisionfirst.bat

call c:\vagrant\scripts\attach-jenkins-disk.bat

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

cinst -y curl

cinst -y msysgit
where git
if ERRORLEVEL 1 call :addGitToUserPath
goto GIT_DONE
:addGitToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;C:\Program Files (x86)\Git\cmd" /f
set PATH=%PATH%;C:\Program Files (x86)\Git\cmd
exit /b
:GIT_DONE


rem echo Install unreleased packer from GitHub sources
rem call C:\vagrant\scripts\install-packer-from-source.bat
rem goto packer_firewall

echo Installing official packer version from Chocolatey Package
cinst -y packer -version 0.8.5
where packer
if ERRORLEVEL 1 call :addPackerToSystemPath
goto PACKER_DONE
:addPackerToSystemPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v Path ^| findstr /i path') do set OLD_SYSTEM_PATH=%%g
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v Path /d "%OLD_SYSTEM_PATH%;C:\hashicorp\packer" /f
set PATH=%PATH%;C:\hashicorp\packer
exit /b
:PACKER_DONE
cinst -y packer-post-processor-vagrant-vmware-ovf -version 0.2.1.20150603

rem Windows 2012 R2 will start jenkins slave as user vagrant, but with USERPROFILE=C:\Users\Default, so write it there, too.
if not exist C:\Users\Default\AppData\Roaming\packer.config (
  if exist C:\Users\vagrant\AppData\Roaming\packer.config (
    copy C:\Users\vagrant\AppData\Roaming\packer.config C:\Users\Default\AppData\Roaming\packer.config
  )
)

:packer_firewall
netsh advfirewall firewall add rule name="packer-builder-vmware-iso" dir=in program="%ChocolateyInstall%\lib\packer\tools\packer-builder-vmware-iso.exe" action=allow
netsh advfirewall firewall add rule name="packer-builder-virtualbox-iso" dir=in program="%ChocolateyInstall%\lib\packer\tools\packer-builder-virtualbox-iso.exe" action=allow
netsh advfirewall firewall add rule name="packer-builder-vmware-iso" dir=in program="c:\Users\vagrant\go\bin\packer-builder-vmware-iso.exe" action=allow
netsh advfirewall firewall add rule name="packer-builder-virtualbox-iso" dir=in program="c:\Users\vagrant\go\bin\packer-builder-virtualbox-iso.exe" action=allow

if exist c:\hashicorp\vagrant goto :have_vagrant
echo Installing Vagrant ...
cinst -y vagrant
set PATH=%PATH%;C:\hashicorp\vagrant\bin
:have_vagrant

echo Installing vagrant-serverspec ...
vagrant plugin install vagrant-serverspec

echo Installing Stefan's vagrant-vcloud plugin 0.4.4 ...
curl -Lk -o vagrant-vcloud-0.4.4.gem https://github.com/StefanScherer/vagrant-vcloud/releases/download/v0.4.4/vagrant-vcloud-0.4.4.gem
vagrant plugin install vagrant-vcloud-0.4.4.gem

if exist C:\Users\vagrant\.vagrant.d\Vagrantfile goto :have_vagrantfile
if exist C:\vagrant\resources\Vagrantfile-global (
  copy C:\vagrant\resources\Vagrantfile-global C:\Users\vagrant\.vagrant.d\Vagrantfile
  if exist C:\Users\Default (
    mkdir C:\Users\Default\.vagrant.d
    copy C:\vagrant\resources\Vagrantfile-global C:\Users\Default\.vagrant.d\Vagrantfile
  )
)
:have_vagrantfile

rem Install VMware Workstation
choco install -y vmwareworkstation

rem put ovftool in path (not necessary for packer, but for jenkins test-box-vcloud.bat)
where ovftool
if ERRORLEVEL 1 call :addOvfToolToSystemPath
goto OVFTOOL_DONE
:addOvfToolToSystemPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v Path ^| findstr /i path') do set OLD_SYSTEM_PATH=%%g
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v Path /d "%OLD_SYSTEM_PATH%;C:\Program Files (x86)\VMware\VMware Workstation\OVFTool" /f
set PATH=%PATH%;C:\Program Files (x86)\VMware\VMware Workstation\OVFTool
exit /b
:OVFTOOL_DONE

if exist C:\vagrant\resources\hosts (
  echo Appending additional hosts entries
  copy C:\Windows\System32\drivers\etc\hosts + C:\vagrant\resources\hosts C:\Windows\System32\drivers\etc\hosts
)

echo Installing TightVNC to watch headless VMs
cinst -y tightvnc

call C:\vagrant\scripts\install-jenkins-slave.bat

echo Reboot the vmware-slave to have all tools in PATH and then start the swarm client
call C:\vagrant\scripts\reboot-to-slave.bat
