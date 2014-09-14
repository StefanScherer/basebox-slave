#!/bin/bash
echo "Downloading Vagrant 1.6.5 ..."
wget --no-verbose -O /tmp/vagrant.deb https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.5_x86_64.deb
echo "Installing Vagrant 1.6.5 ..."
sudo dpkg -i /tmp/vagrant.deb
rm /tmp/vagrant.deb
