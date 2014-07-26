#!/bin/bash
if [ ! -d resources/ ]; then
  mkdir -p resources
fi
if [ ! -f resources/Vagrantfile-global ]; then
  if [ -f /vagrant/resources/basebox-slave/Vagrantfile-global ]; then
    echo "Deploying Vagrantfile-global from Host to vApp sync folder"
    cp /vagrant/resources/basebox-slave/Vagrantfile-global resources/Vagrantfile-global
  fi
fi
if [ ! -f resources/test-box-vcloud-credentials.bat ]; then
  if [ -f /vagrant/resources/basebox-slave/test-box-vcloud-credentials.bat ]; then
    echo "Deploying test-box-vcloud-credentials.bat from Host to vApp sync folder"
    cp /vagrant/resources/basebox-slave/test-box-vcloud-credentials.bat resources/test-box-vcloud-credentials.bat
  fi
fi
