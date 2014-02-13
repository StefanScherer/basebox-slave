# basebox-slave

Setup a Windows Jenkins slave to build baseboxes with packer.
This slave is on real hardware to build 64bit baseboxes as well.

## Environment

* Windows Server 2003 R2 64bit SP2
* VMware Workstation 10
* VirtualBox 4.3.6
* packer 0.5.1
* wget.exe
* unzip.exe

## Installation
To install it in the preinstalled machine without PowerShell, you must
have at least wget.exe and unzip.exe to download a file and extract ZIP files.

Open up a command prompt by typing **Windows+R** and enter **cmd** and press enter.
Then enter following command:

    wget --no-check-certificate https://github.com/StefanScherer/basebox-slave/raw/master/install.bat -O %TEMP%\install.bat && %TEMP%\install.bat

Afterwards you have VirtualBox 4.3.6 and Packer 0.5.1 installed and in PATH.

# Licensing
Copyright (c) 2014 Stefan Scherer

MIT License, see LICENSE for more details.


    
