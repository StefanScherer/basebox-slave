@echo off
if "%1x"=="x" (
  echo Usage: %~n0 boxname
) else (
  if "%VAGRANT_HOME%x"=="x" (
    set VAGRANT_HOME=%USERPROFILE%\.vagrant.d
  )
  if not exist "%VAGRANT_HOME%\boxes" (
    echo No Vagrant boxes directory found!
    exit 1
  )
  if not exist "%VAGRANT_HOME%\boxes\%1\0\vcloud" (
    echo Creating fake vcloud box for %1
    mkdir "%VAGRANT_HOME%\boxes\%1\0\vcloud"
    echo {"provider": "vcloud"} >%VAGRANT_HOME%\boxes\%1\0\vcloud\metadata.json
    echo #fake >%VAGRANT_HOME%\boxes\%1\0\vcloud\Vagrantfile
  ) else (
    echo Fake vcloud box for %1 already exists.
  )
)
