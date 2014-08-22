Write-Host "Installing WSUS"
# Install-WindowsFeature -Name UpdateServices-Services,UpdateServices-DB -IncludeManagementTools
Install-WindowsFeature -Name UpdateServices -IncludeManagementTools

cd "C:\Program Files\Update Services\Tools"
.\wsusutil.exe postinstall CONTENT_DIR=C:\WSUS

