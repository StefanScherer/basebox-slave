# basebox-slave

Setup a Windows Jenkins slave to build baseboxes with packer.
This slave is used to build 64bit baseboxes as well.

## Environment
An vApp with a Windows 2012 R2 will be fine.
The VM should have a second hard drive D: with plenty of disk space to build boxes on it.

## Directories
* PACKER_CACHE_DIR D:\Packer\cache
* PACKER_TEMP_DIR D:\Packer\temp
* VirtualBox D:\VirtualBox

## Installation
To install it in the preinstalled machine, you must have at least powershell installed.

Open up a command prompt by typing **Windows+R** and enter **cmd** and press enter.
Then enter following command:

    powershell -NoProfile -ExecutionPolicy unrestricted -Command "((new-object net.webclient).DownloadFile(' https://raw.github.com/StefanScherer/basebox-slave/master/install.bat', '%Temp%\install.bat'))" && %Temp%\install.bat

Afterwards you have VirtualBox 4.3.6 and Packer 0.5.1 installed and in PATH.

### Installed Software
These software will be installed

* Chocolatey package manager
* Curl
* Firefox 27
* Git 1.8.5 commandline
* Packer 0.5.1
* VMware PowerCLI 5.5
* VMware Workstation 10
* Vagrant 1.4.3
* Vim 7.4
* VirtualBox 4.3.6

# Licensing
Copyright (c) 2014 Stefan Scherer

MIT License, see LICENSE for more details.
    
