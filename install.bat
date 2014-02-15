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

call cinst curl
call cinst 7zip
set PATH=%PATH%;c:\Program Files\7-Zip
call cinst vim
call cinst msysgit
call cinst firefox

rem Install packer 0.5.1
if not exist D:\Packer\cache mkdir D:\Packer\cache
setx PACKER_CACHE_DIR D:\Packer\cache
set PACKER_CACHE_DIR=D:\Packer\cache
if not exist D:\Packer\temp mkdir D:\Packer\temp
setx PACKER_TEMP_DIR D:\Packer\temp
set PACKER_TEMP_DIR=D:\Packer\temp

rem call cinst packer
if exist C:\hashicorp\packer\packer.exe goto PACKER_INSTALLED
curl -J -k https://dl.bintray.com/mitchellh/packer/0.5.1_windows_amd64.zip -O %TEMP%\0.5.1_windows_amd64.zip
mkdir C:\hashicorp\packer
cd /D C:\hashicorp\packer
7z x %TEMP%\0.5.1_windows_amd64.zip
rem cd /D %USERPROFILE%
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
  call curl -L -k https://github.com/StefanScherer/basebox-slave/raw/master/VirtualBox.xml -O "%USERPROFILE%\.VirtualBox\VirtualBox.xml"
)
call cinst virtualbox
if not exist D:\VirtualBox mkdir D:\VirtualBox
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

if not exist D:\GitHub mkdir D:\GitHub
cd /D D:\GitHub
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

echo Copy ISO files...
if not exist D:\ISO\san\windows\licensed\datacenter_san mkdir D:\ISO\san\windows\licensed\datacenter_san
if not exist D:\ISO\san\windows\licensed\datacenter_san\win2008r2sp1_datacenter_en mkdir D:\ISO\san\windows\licensed\datacenter_san\win2008r2sp1_datacenter_en
if not exist D:\ISO\san\windows\licensed\datacenter_san\win2008r2sp1_datacenter_en\SW_DVD5_Windows_Svr_DC_EE_SE_Web_2008_R2_64Bit_English_w_SP1_MLF_X17-22580.ISO (
  copy \\adminlin01\iso\windows\licensed\datacenter_san\win2008r2sp1_datacenter_en\SW_DVD5_Windows_Svr_DC_EE_SE_Web_2008_R2_64Bit_English_w_SP1_MLF_X17-22580.ISO D:\ISO\san\windows\licensed\datacenter_san\win2008r2sp1_datacenter_en
)

if not exist D:\ISO\san\windows\licensed\datacenter_san\win2012_datacenter_en mkdir D:\ISO\san\windows\licensed\datacenter_san\win2012_datacenter_en
if not exist D:\ISO\san\windows\licensed\datacenter_san\win2012_datacenter_en\SW_DVD5_Win_Svr_Std_and_DataCtr_2012_64Bit_English_Core_MLF_X18-27588.ISO (
  copy \\adminlin01\iso\windows\licensed\datacenter_san\win2012_datacenter_en\SW_DVD5_Win_Svr_Std_and_DataCtr_2012_64Bit_English_Core_MLF_X18-27588.ISO D:\ISO\san\windows\licensed\datacenter_san\win2012_datacenter_en
)

if not exist D:\ISO\san\windows\licensed\datacenter_san\win2012r2_datacenter_en mkdir D:\ISO\san\windows\licensed\datacenter_san\win2012r2_datacenter_en
if not exist D:\ISO\san\windows\licensed\datacenter_san\win2012r2_datacenter_en\SW_DVD9_Windows_Svr_Std_and_DataCtr_2012_R2_64Bit_English_-2_Core_MLF_X19-31419.ISO (
  copy \\adminlin01\iso\windows\licensed\datacenter_san\win2012r2_datacenter_en\SW_DVD9_Windows_Svr_Std_and_DataCtr_2012_R2_64Bit_English_-2_Core_MLF_X19-31419.ISO D:\ISO\san\windows\licensed\datacenter_san\win2012r2_datacenter_en
 )

echo Install VMware PowerCLI...
if not exist "c:\Program Files (x86)\VMware\VMware VIX" (
  if not exist "%USERPROFILE%\Downloads\VMware-PowerCLI-5.5.0-1295336.exe" (
    copy "\\roettfs1\scratch\keep\VMware\VMware-PowerCLI-5.5.0-1295336.exe" %USERPROFILE%\Downloads
  )
  powershell -Command "Import-Module ServerManager; Add-WindowsFeature NET-Framework-Features"
  "%USERPROFILE%\Downloads\VMware-PowerCLI-5.5.0-1295336.exe" /s /v/qn
)

echo Install VMware Workstation...
rem Install VMware Workstation
if not exist "c:\Program Files (x86)\VMware\VMware Workstation" (
  if not exist "%USERPROFILE%\Downloads\VMware-workstation-full-10.0.0-1295980.exe" (
    copy \\adminlin01\iso\vmware\workstation10\VMware-workstation-full-10.0.0-1295980.exe %USERPROFILE%\Downloads
  )
  rem "%USERPROFILE%\Downloads\VMware-workstation-full-10.0.0-1295980.exe" /s /nsr /v EULAS_AGREED=1 SERIALNUMBER="xxxxx-xxxxx-xxxxx-xxxxx-xxxxx"
  "%USERPROFILE%\Downloads\VMware-workstation-full-10.0.0-1295980.exe" /s /nsr /v EULAS_AGREED=1 
)

