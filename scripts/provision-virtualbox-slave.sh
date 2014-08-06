#!/bin/bash

# switch Ubuntu download mirror to German server
sudo sed -i 's,http://us.archive.ubuntu.com/ubuntu/,http://ftp.fau.de/ubuntu/,' /etc/apt/sources.list
sudo sed -i 's,http://security.ubuntu.com/ubuntu,http://ftp.fau.de/ubuntu,' /etc/apt/sources.list
sudo apt-get update -qq

# set timezone to German timezone
echo "Europe/Berlin" | sudo tee /etc/timezone
sudo dpkg-reconfigure -f noninteractive tzdata

# install git
sudo apt-get install -qq git unzip

# install packer
sudo mkdir /opt/packer
cd /opt/packer
echo "Downloading packer 0.6.1..."
sudo wget --no-verbose https://dl.bintray.com/mitchellh/packer/0.6.1_linux_amd64.zip
echo "Installing packer 0.6.1..."
sudo unzip 0.6.1_linux_amd64.zip
sudo rm 0.6.1_linux_amd64.zip
cd /usr/bin
sudo ln -s /opt/packer/* .


echo "Downloading Vagrant 1.6.3 ..."
wget --no-verbose -O /tmp/vagrant.deb https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.deb
echo "Installing Vagrant 1.6.3 ..."
sudo dpkg -i /tmp/vagrant.deb
rm /tmp/vagrant.deb

echo "Installing VirtualBox 4.3.14 ..."
# workaround in box-cutter/ubuntu1404's minimize.sh removes /usr/src/* but does not remove packages
sudo apt-get remove -qq linux-headers-3.13.0-32-generic
sudo apt-get remove -qq linux-headers-3.13.0-32
# sudo apt-get install -qq linux-headers-3.13.0-32
sudo apt-get install -qq linux-headers-$(uname -r)
sudo apt-get install -qq dkms
UBUNTU_VERSION=`lsb_release -c | grep -o "\S*$"`
echo "deb http://download.virtualbox.org/virtualbox/debian $UBUNTU_VERSION contrib" | sudo tee -a /etc/apt/sources.list
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
sudo apt-get update

echo "Installing VirtualBox delayed ..."
# the next command will be called
# in an asynchronous way, because installation of VirtualBox drops
# all network connections. An so a vagrant provision would hang.
# As we also want to reboot the machine to have updated PATH in all
# services this is a working workaround.
cat <<DELAY_SCRIPT >/tmp/delayed-install-virtualbox.sh
#!/bin/bash
echo "Starting $0" >>/home/vagrant/delayed-install-vagrant.log
sleep 5
sudo apt-get install -y virtualbox-4.3 >>/home/vagrant/delayed-install-vagrant.log
echo "vboxdrv setup ..." >>/home/vagrant/delayed-install-vagrant.log
sudo /etc/init.d/vboxdrv setup >>/home/vagrant/delayed-install-vagrant.log
echo "Starting Jenkins Swarm Client ..." >>/home/vagrant/delayed-install-vagrant.log
sudo service swarm-client start >>/home/vagrant/delayed-install-vagrant.log
DELAY_SCRIPT
sudo chmod +x /tmp/delayed-install-virtualbox.sh
/tmp/delayed-install-virtualbox.sh 2>&1 >/dev/null &
