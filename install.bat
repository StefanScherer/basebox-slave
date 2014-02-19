@echo off
echo Ensuring .NET 4.0 is installed
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.github.com/StefanScherer/arduino-ide/install/InstallNet4.ps1'))"
echo Installing Chocolatey
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin

where cinst
if ERRORLEVEL 1 goto set_chocolatey
goto inst
:set_chocolatey
set ChocolateyInstall=%SystemDrive%\Chocolatey
set PATH=%PATH%;%ChocolateyInstall%\bin
:inst

call cinst vagrant
set PATH=%PATH%;%SystemDrive%\hashicorp\vagrant\bin
cd /D %USERPROFILE%\Documents

call cinst wget
call cinst 7zip
set PATH=%PATH%;C:\Program Files\7-Zip
call cinst vim
where gvim.exe
if ERRORLEVEL 1 call :addVimToUserPath
goto VIM_DONE
:addVimToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;C:\Program Fiels (x86)\vim\vim74" /f
set PATH=%PATH%;C:\Program Files (x86)\vim\vim74
exit /b
:VIM_DONE

call cinst msysgit
set PATH=%PATH%;C:\Program Files (x86)\Git\cmd

call cinst firefox

set WORKDRIVE=D:

rem Install packer 0.5.1
if not exist %WORKDRIVE%\Packer\cache mkdir %WORKDRIVE%\Packer\cache
setx PACKER_CACHE_DIR %WORKDRIVE%\Packer\cache
set PACKER_CACHE_DIR=%WORKDRIVE%\Packer\cache
if not exist %WORKDRIVE%\Packer\temp mkdir %WORKDRIVE%\Packer\temp
setx PACKER_TEMP_DIR %WORKDRIVE%\Packer\temp
set PACKER_TEMP_DIR=%WORKDRIVE%\Packer\temp

rem call cinst packer
if exist C:\hashicorp\packer\packer.exe goto PACKER_INSTALLED
call wget --no-check-certificate https://dl.bintray.com/mitchellh/packer/0.5.1_windows_amd64.zip -O %TEMP%\0.5.1_windows_amd64.zip
mkdir C:\hashicorp\packer
cd /D C:\hashicorp\packer
7z x %TEMP%\0.5.1_windows_amd64.zip
cd /D %USERPROFILE%
rem :PACKER_INSTALLED
where packer
if ERRORLEVEL 1 call :addPackerToUserPath
goto PACKER_DONE
:addPackerToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;C:\hashicorp\packer" /f
set PATH=%PATH%;C:\hashicorp\packer
exit /b
:PACKER_DONE


rem Install VirtualBox 4.3.6
if not exist "%USERPROFILE%\.VirtualBox\VirtualBox.xml" (
  mkdir "%USERPROFILE%\.VirtualBox"
  call wget --no-check-certificate https://github.com/StefanScherer/basebox-slave/raw/master/VirtualBox.xml -O "%USERPROFILE%\.VirtualBox\VirtualBox.xml"
)
call cinst virtualbox
if not exist %WORKDRIVE%\VirtualBox mkdir %WORKDRIVE%\VirtualBox
rem if exist "C:\program files\oracle\virtualbox\vboxmanage.exe" goto VIRTUALBOX_INSTALLED
rem wget http://download.virtualbox.org/virtualbox/4.3.6/VirtualBox-4.3.6-91406-Win.exe -O %TEMP%\VirtualBox-4.3.6-91406-Win.exe
rem %TEMP%\VirtualBox-4.3.6-91406-Win.exe -s
:VIRTUALBOX_INSTALLED
where vboxmanage
if ERRORLEVEL 1 call :addVirtualBoxToUserPath
goto VIRTUALBOX_DONE
:addVirtualBoxToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;C:\program files\oracle\virtualbox" /f
set PATH=%PATH%;C:\program files\oracle\virtualbox
exit /b
:VIRTUALBOX_DONE

rem Install Jenkins
rem wget http://mirrors.jenkins-ci.org/windows/latest -O %TEMP%\jenkins.zip
rem cd /D %TEMP%
rem unzip jenkins.zip
rem setup.exe -s

if not exist %WORKDRIVE%\GitHub mkdir %WORKDRIVE%\GitHub
cd /D %WORKDRIVE%\GitHub
if not exist basebox-packer (
  git clone https://github.com/StefanScherer/basebox-packer.git
) else (
  cd basebox-packer
  git pull
  cd ..
)

if not exist packer-windows (
  git clone -b san https://github.com/StefanScherer/packer-windows.git
) else (
  cd packer-windows
  git pull
  cd ..
)

if not exist basebox-slave (
  git clone https://github.com/StefanScherer/basebox-slave.git
) else (
  cd basebox-slave
  git pull
  cd ..
)

echo Install VMware PowerCLI...
if not exist "c:\Program Files (x86)\VMware\VMware VIX" (
  if not exist "%TEMP%\VMware-PowerCLI-5.5.0-1295336.exe" (
    call wget -O "%TEMP%\VMware-PowerCLI-5.5.0-1295336.exe" http://roecloudsrv001/vmware/powercli/VMware-PowerCLI-5.5.0-1295336.exe
  )
  powershell -Command "Import-Module ServerManager; Add-WindowsFeature NET-Framework-Features"
  "%TEMP%\VMware-PowerCLI-5.5.0-1295336.exe" /s /v/qn /vADDLOCAL=ALL
  del "%TEMP%\VMware-PowerCLI-5.5.0-1295336.exe"
)

echo Install VMware Workstation...
rem Install VMware Workstation
if not exist "c:\Program Files (x86)\VMware\VMware Workstation" (
  if not exist "%TEMP%\VMware-workstation-full-10.0.0-1295980.exe" (
    call wget -O "%TEMP%\VMware-workstation-full-10.0.0-1295980.exe" http://roecloudsrv001/vmware/workstation10/VMware-workstation-full-10.0.0-1295980.exe
  )
  rem "%TEMP%\VMware-workstation-full-10.0.0-1295980.exe" /s /nsr /v EULAS_AGREED=1 SERIALNUMBER="xxxxx-xxxxx-xxxxx-xxxxx-xxxxx"
  "%TEMP%\VMware-workstation-full-10.0.0-1295980.exe" /s /nsr /v EULAS_AGREED=1 
  del "%TEMP%\VMware-workstation-full-10.0.0-1295980.exe"
)

rem put ovftool into path
where ovftool
if ERRORLEVEL 1 call :addOvftoolToUserPath
goto OVFTOOL_DONE
:addOvftoolToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;c:\Program Files (x86)\VMware\VMware Workstation\ovftool" /f
set PATH=%PATH%;c:\Program Files (x86)\VMware\VMware Workstation\ovftool
exit /b
:OVFTOOL_DONE

rem install addtime to measure time
call cinst strawberryperl
set PATH=%PATH%;c:\strawberry\perl\bin
wget --no-check-certificate -O c:\chocolatey\bin\addtime.bat https://github.com/StefanScherer/dotfiles-windows/raw/master/bin/addtime.bat

call cinst javaruntime
if not exist %WORKDRIVE%\jenkins mkdir %WORKDRIVE%\jenkins
if not exist %WORKDRIVE%\swarmclient mkdir %WORKDRIVE%\swarmclient
cd /D %WORKDRIVE%\swarmclient
call wget -O swarm-client.jar http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/1.8/swarm-client-1.8-jar-with-dependencies.jar

set jenkinshost=10.115.4.8
net user swarmclient K8934jASD,x9  /ADD
net localgroup Administrators swarmclient /add
rem Due to problems with UDP broadcast, use the -master switch at the moment
rem Schedule start of swarm client at start of the machine (after next reboot)
schtasks /CREATE /SC ONSTART /RU swarmclient /RP K8934jASD,x9 /TN JenkinsSwarmClient /TR "java.exe -jar %WORKDRIVE%\swarmclient\swarm-client.jar -master http://%jenkinshost% -labels packer -fsroot %WORKDRIVE%\jenkins"


cd %WORKDRIVE%\GitHub\packer-windows
vagrant --version
packer --version
vboxmanage --version
ovftool -version

