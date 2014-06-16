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
call wget --no-check-certificate https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3.msi -O %TEMP%\vagrant.msi
https://github.com/StefanScherer/basebox-slave/raw/master/VirtualBox.xml -O "%USERPROFILE%\.VirtualBox\VirtualBox.xml"
msiexec /i %TEMP%\vagrant.msi /quiet

set PATH=%PATH%;%SystemDrive%\hashicorp\vagrant\bin
cd /D %USERPROFILE%\Documents
vagrant plugin install vagrant-vcloud

call cinst 7zip
set PATH=%PATH%;C:\Program Files\7-Zip
call cinst vim
where gvim.exe
if ERRORLEVEL 1 call :addVimToUserPath
goto VIM_DONE
:addVimToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;C:\Program Files (x86)\vim\vim74" /f
set PATH=%PATH%;C:\Program Files (x86)\vim\vim74
exit /b
:VIM_DONE

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

rem Install VirtualBox 4.3
if not exist "%USERPROFILE%\.VirtualBox\VirtualBox.xml" (
  mkdir "%USERPROFILE%\.VirtualBox"
  call wget --no-check-certificate https://github.com/StefanScherer/basebox-slave/raw/master/VirtualBox.xml -O "%USERPROFILE%\.VirtualBox\VirtualBox.xml"
)
call cinst virtualbox
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
vboxmanage -version

