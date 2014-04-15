cd /D %USERPROFILE%
if not exist .vagrant.d\gems\gems (
  echo No vagrant gems dir found! Abort.
  goto :EOF
)
cd .vagrant.d\gems\gems
set version=0.2.2
if exist vagrant-vcloud-%version% (
  ren vagrant-vcloud-%version% vagrant-vcloud-%version%-off
)
git clone git@github.com:StefanScherer/vagrant-vcloud.git
ren vagrant-vcloud vagrant-vcloud-%version%
if ERRORLEVEL 1 (
  echo Error renaming original directory! Abort.
  goto :EOF
)
cd vagrant-vcloud-%version%
git checkout develop

