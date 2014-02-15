
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

call cinst wget
call cinst javaruntime

set jenkinshost=10.115.4.8
set jenkinsuser=admin
set jenkinspass=vagrant

if not exist C:\jenkins mkdir C:\jenkins
cd /D C:\jenkins
call wget http://%jenkinshost%/jnlpJars/jenkins-cli.jar


# force read update list
call wget -O default.js http://updates.jenkins-ci.org/update-center.json
call cinst curl
call cinst devbox-sed
"c:\Program Files\Tools\bin\sed.exe"  "1d;$d" default.js >default.json
call curl -u %jenkinsuser%:%jenkinspass% -X POST -H "Accept: application/json" -d @default.json http://%jenkinshost%/updateCenter/byId/default/postBack --verbose
java -jar jenkins-cli.jar -s http://%jenkinshost% install-plugin git --username %jenkinsuser% --password %jenkinspass% 
java -jar jenkins-cli.jar -s http://%jenkinshost% install-plugin checkstyle --username %jenkinsuser% --password %jenkinspass% 
java -jar jenkins-cli.jar -s http://%jenkinshost% install-plugin swarm --username %jenkinsuser% --password %jenkinspass% 

# restart jenkins to activate all plugins
java -jar jenkins-cli.jar -s http://%jenkinshost%/ safe-restart --username %jenkinsuser% --password %jenkinspass% 
