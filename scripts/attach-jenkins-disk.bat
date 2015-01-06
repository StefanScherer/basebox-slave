setlocal

set DP=%TEMP%\diskpart.txt
set MOUNTPOINT=c:\jenkins
mkdir %MOUNTPOINT%
echo select disk 1 >%DP%
echo attributes disk clear readonly >>%DP%
echo online disk >>%DP%
echo create partition primary >>%DP%
echo format quick >>%DP%
echo assign mount=%MOUNTPOINT% >>%DP%
echo select disk 1 >>%DP%

diskpart /s %DP%

del %DP%