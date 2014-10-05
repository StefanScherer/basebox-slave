#!/bin/bash

# from http://c-nergy.be/blog/?p=5305
echo "Installing RDP server ..."
sudo apt-get install -y xrdp
sudo apt-get install -y xfce4
echo xfce4-session >~/.xsession
sudo service xrdp restart
