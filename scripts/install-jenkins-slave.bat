@echo off
rem this echo off is essential for the heredoc code below

rem set timezone to German timezone
tzutil /s "W. Europe Standard Time"

if exist c:\jenkins\swarm-client.jar goto :EOF
set hypervisor=%1
if "%1x"=="x" set hypervisor=vmware

if exist %WinDir%\microsoft.net\framework\v4.0.30319 goto :have_net
echo Ensuring .NET 4.0 is installed
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.github.com/StefanScherer/arduino-ide/install/InstallNet4.ps1'))"
:have_net
if "%ChocolateyInstall%x"=="x" set ChocolateyInstall=%ALLUSERSPROFILE%\Chocolatey
if exist %ChocolateyInstall% goto :have_choc
echo Installing Chocolatey
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
:have_choc

where cinst
if ERRORLEVEL 1 goto set_chocolatey
goto inst
:set_chocolatey
set ChocolateyInstall=%ALLUSERSPROFILE%\Chocolatey
set PATH=%PATH%;%ChocolateyInstall%\bin
:inst

where java
if ERRORLEVEL 1 call cinst java.jdk

where wget
if ERRORLEVEL 1 call cinst wget

if not exist c:\jenkins mkdir c:\jenkins

if not exist c:\jenkins\swarm-client.jar (
  if exist c:\vagrant\resources\swarm-client.jar (
    copy c:\vagrant\resources\swarm-client.jar c:\jenkins\swarm-client.jar
  ) else (
    call wget --no-verbose -O c:\jenkins\swarm-client.jar http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/1.15/swarm-client-1.15-jar-with-dependencies.jar
  )
)

call :heredoc html >%TEMP%\JenkinsSwarmClient.xml && goto next2
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2014-03-09T01:02:10</Date>
    <Author>vagrant</Author>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <StartBoundary>2014-03-09T01:02:00</StartBoundary>
      <Enabled>true</Enabled>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>vagrant</UserId>
      <LogonType>Password</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
    <RestartOnFailure>
      <Interval>PT1M</Interval>
      <Count>3</Count>
    </RestartOnFailure>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>java.exe</Command>
      <Arguments>-jar c:\jenkins\swarm-client.jar -autoDiscoveryAddress 172.16.32.255 -executors 1 -labels windows -labels !hypervisor! -fsroot c:\jenkins</Arguments>
    </Exec>
  </Actions>
</Task>
:next2

rem Schedule start of swarm client at start of the machine (after next reboot)
rem

schtasks /CREATE /TN JenkinsSwarmClient /RU vagrant /RP vagrant /XML "%TEMP%\JenkinsSwarmClient.xml"

goto :done_jenkins_slave


::########################################
::## Here's the heredoc processing code ##
::########################################
:heredoc <uniqueIDX>
setlocal enabledelayedexpansion
set go=
for /f "delims=" %%A in ('findstr /n "^" "%~f0"') do (
  set "line=%%A" && set "line=!line:*:=!"
  if defined go (if #!line:~1!==#!go::=! (goto :EOF) else echo(!line!)
  if "!line:~0,13!"=="call :heredoc" (
    for /f "tokens=3 delims=>^ " %%i in ("!line!") do (
      if #%%i==#%1 (
        for /f "tokens=2 delims=&" %%I in ("!line!") do (
          for /f "tokens=2" %%x in ("%%I") do set "go=%%x"
        )
      )
    )
  )
)
goto :done_jenkins_slave
:done_jenkins_slave
