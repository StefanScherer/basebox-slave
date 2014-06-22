#!/bin/bash
sudo mkdir /opt/packer
cd /opt/packer
echo "Downloading packer 0.6.0..."
sudo wget --no-verbose https://dl.bintray.com/mitchellh/packer/0.6.0_linux_amd64.zip
echo "Installing packer 0.6.0..."
sudo unzip 0.6.0_linux_amd64.zip
sudo rm 0.6.0_linux_amd64.zip
cd /usr/bin
sudo ln -s /opt/packer/* .
