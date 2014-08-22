# open ping for packer-windows builds, this deprecated command even works on 2012 R2
netsh firewall set icmpsetting 8

. C:\vagrant\scripts\install-wsus.ps1
. C:\vagrant\scripts\configure-wsus.ps1
