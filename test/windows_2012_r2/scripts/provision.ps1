$box = Get-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName -Name "ComputerName"
$box = $box.ComputerName.ToString().ToLower()

Write-Host 'Provisioning ' $env:COMPUTERNAME ' = ' $box ' ...'
Write-Host ''
Write-Host 'Do a little self-check'
Write-Host 'Running script ' + $MyInvocation.MyCommand.Name

if (Test-Path c:\vagrant) {
    Write-Host 'Directory c:\vagrant exists'
    $items = Get-ChildItem -Path "c:\vagrant"
    foreach ($item in $items) {
        Write-Host $item.Name
    }
} else {
    Write-Host 'Directory c:\vagrant does not exist'
}
