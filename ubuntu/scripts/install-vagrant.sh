#!/bin/bash
echo "Downloading Vagrant 1.6.3 ..."
wget --no-verbose -O /tmp/vagrant.deb https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.deb
echo "Installing Vagrant 1.6.3 ..."
sudo dpkg -i /tmp/vagrant.deb
rm /tmp/vagrant.deb
