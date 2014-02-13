
rem Install packer 0.5.1
if not exist D:\Packer\cache mkdir D:\Packer\cache
setx PACKER_CACHE_DIR D:\Packer\cache
set PACKER_CACHE_DIR=D:\Packer\cache
if not exist D:\Packer\temp mkdir D:\Packer\temp
setx PACKER_TEMP_DIR D:\Packer\temp
set PACKER_TEMP_DIR=D:\Packer\temp

if exist c:\hashicorp\packer\packer.exe goto PACKER_INSTALLED
wget --no-check-certificate https://dl.bintray.com/mitchellh/packer/0.5.1_windows_amd64.zip -O %TEMP%\0.5.1_windows_amd64.zip
mkdir c:\hashicorp\packer
cd /D c:\hashicorp\packer
unzip %TEMP%\0.5.1_windows_amd64.zip
cd /D %USERPROFILE%
:PACKER_INSTALLED
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
  wget --no-check-certificate https://github.com/StefanScherer/basebox-slave/raw/master/VirtualBox.xml -O "%USERPROFILE%\.VirtualBox\VirtualBox.xml"
)
if not exist D:\VirtualBox mkdir D:\VirtualBox
if exist "c:\program files\oracle\virtualbox\vboxmanage.exe" goto VIRTUALBOX_INSTALLED
wget http://download.virtualbox.org/virtualbox/4.3.6/VirtualBox-4.3.6-91406-Win.exe -O %TEMP%\VirtualBox-4.3.6-91406-Win.exe
%TEMP%\VirtualBox-4.3.6-91406-Win.exe -s
:VIRTUALBOX_INSTALLED
where vboxmanage
if ERRORLEVEL 1 call :addVirtualBoxToUserPath
goto VIRTUALBOX_DONE
:addVirtualBoxToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;c:\program files\oracle\virtualbox" /f
set PATH=%PATH%;c:\program files\oracle\virtualbox
exit /b
:VIRTUALBOX_DONE

rem Install Jenkins
rem wget http://mirrors.jenkins-ci.org/windows/latest -O %TEMP%\jenkins.zip
rem cd /D %TEMP%
rem unzip jenkins.zip
rem setup.exe -s

rem Install git for Windows
if exist "c:\Program Files (x86)\Git\bin" goto GIT_INSTALLED
dir "c:\Program Files (x86)\Git\bin
wget --no-check-certificate https://msysgit.googlecode.com/files/Git-1.8.5.2-preview20131230.exe -O %TEMP%\gitsetup.exe
%TEMP%\gitsetup.exe /VERYSILENT
:GIT_INSTALLED
where git
if ERRORLEVEL 1 call :addGitToUserPath
goto GIT_DONE
:addGitToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;c:\Program Files (x86)\Git\bin" /f
set PATH=%PATH%;c:\Program Files (x86)\Git\bin
exit /b
:GIT_DONE

if not exist D:\GitHub mkdir D:\GitHub
cd /D D:\GitHub
if not exist basebox-packer (
  git clone https://github.com/StefanScherer/basebox-packer.git
) else (
  cd basebox-packer
  git pull
  cd ..
)


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

