if exist c:\jenkins\swarm-client.jar goto :startslave
if not exist c:\jenkins mkdir c:\jenkins

if not exist c:\jenkins\swarm-client.jar (
  if exist c:\vagrant\resources\swarm-client.jar (
    copy c:\vagrant\resources\swarm-client.jar c:\jenkins\swarm-client.jar
  ) else (
    call wget --no-verbose -O c:\jenkins\swarm-client.jar http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/1.16/swarm-client-1.16-jar-with-dependencies.jar
  )
)

:startslave
set labels="windows"

if exist "c:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" (
  set labels="%labels%,vmware"
)
if exist "c:\Program Files\Oracle\VirtualBox\VBoxManage.exe" (
  set labels="%labels%,virtualbox"
)

start java -jar c:\jenkins\swarm-client.jar -autoDiscoveryAddress 172.16.32.255 -executors 1 -labels %labels% -fsroot c:\jenkins
