@echo off
setlocal EnableDelayedExpansion
set Num=1
if exist counter.txt (
  for /f "delims=" %%x in (counter.txt) do set /A Num=%%x+1
)
echo %Num% >counter.txt
set "formattedNum=00%Num%"
set Num=!formattedNum:~-2!

echo vagrant %* --debug >%Num%-vagrant-%1.log 2>&1
call vagrant %* --debug >%Num%-vagrant-%1.log 2>&1
