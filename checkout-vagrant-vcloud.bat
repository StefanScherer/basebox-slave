if "%VAGRANT_HOME%x"=="x" (
  set VAGRANT_HOME=%USERPROFILE%\.vagrant.d
)
if not exist %VAGRANT_HOME%\gems\gems (
  echo No vagrant gems dir found! Abort.
  goto :EOF
)
cd /D %VAGRANT_HOME%\gems\gems
set version=0.2.2
if exist vagrant-vcloud-%version% (
  ren vagrant-vcloud-%version% vagrant-vcloud-%version%-off
)

if exist b:\GitHub\vagrant-vcloud (
  sudo cmd /c mklink /D %VAGRANT_HOME%\gems\gems\vagrant-vcloud-0.2.2 b:\GitHub\vagrant-vcloud
) else (
  git clone git@github.com:StefanScherer/vagrant-vcloud.git
  ren vagrant-vcloud vagrant-vcloud-%version%
  if ERRORLEVEL 1 (
    echo Error renaming original directory! Abort.
    goto :EOF
  )
  cd vagrant-vcloud-%version%
  git checkout develop
)

