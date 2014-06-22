#!/bin/bash

# install git
sudo apt-get install -y git

# install packer
sudo mkdir /opt/packer
cd /opt/packer
echo "Downloading packer 0.6.0..."
sudo wget --no-verbose https://dl.bintray.com/mitchellh/packer/0.6.0_linux_amd64.zip
echo "Installing packer 0.6.0..."
sudo unzip 0.6.0_linux_amd64.zip
sudo rm 0.6.0_linux_amd64.zip
cd /usr/bin
sudo ln -s /opt/packer/* .


echo "Intalling VirtualBox 4.3.12 ..."
sudo apt-get install -y dkms
echo "deb http://download.virtualbox.org/virtualbox/debian precise contrib" | sudo tee -a /etc/apt/sources.list
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y virtualbox-4.3


echo "Downloading Vagrant 1.6.3 ..."
wget --no-verbose -O /tmp/vagrant.deb https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.deb
echo "Installing Vagrant 1.6.3 ..."
sudo dpkg -i /tmp/vagrant.deb
rm /tmp/vagrant.deb

