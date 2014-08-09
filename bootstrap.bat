if not exist resources (
  mkdir resources
)
if not exist resources\Vagrantfile-global (
  if exist C:\vagrant\resources\basebox-slave\Vagrantfile-global (
    echo Deploying Vagrantfile-global from Host to vApp sync folder
    copy /Y C:\vagrant\resources\basebox-slave\Vagrantfile-global resources\Vagrantfile-global
  )
)
if not exist resources\test-box-vcloud-credentials.bat (
  if exist C:\vagrant\resources\basebox-slave\test-box-vcloud-credentials.bat (
    echo Deploying test-box-vcloud-credentials.bat from Host to vApp sync folder
    copy /Y C:\vagrant\resources\basebox-slave\test-box-vcloud-credentials.bat resources\test-box-vcloud-credentials.bat
  )
)
if not exist resources\upload-vcloud-credentials.bat (
  if exist C:\vagrant\resources\basebox-slave\upload-vcloud-credentials.bat (
    echo Deploying upload-vcloud-credentials.bat from Host to vApp sync folder
    copy /Y C:\vagrant\resources\basebox-slave\upload-vcloud-credentials.bat resources\upload-vcloud-credentials.bat
  )
)
if not exist resources\hosts (
  if exist C:\vagrant\resources\basebox-slave\hosts (
    echo Deploying additional hosts entries
    copy /Y C:\vagrant\resources\basebox-slave\hosts resources\hosts
  )
)
if not exist resources\license.lic (
  if exist C:\vagrant\resources\basebox-slave\license.lic (
    echo Deploying Vagrant VMware Workstation license.lic
    copy /Y C:\vagrant\resources\basebox-slave\license.lic resources\license.lic
  )
)
