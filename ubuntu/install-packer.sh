#!/bin/bash
sudo mkdir /opt/packer
cd /opt/packer
sudo wget https://dl.bintray.com/mitchellh/packer/0.6.0_linux_amd64.zip
sudo unzip 0.6.0_linux_amd64.zip
sudo rm 0.6.0_linux_amd64.zip
cd /usr/bin
sudo ln -s /opt/packer/* .
