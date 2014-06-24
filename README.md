# basebox-slave

This is my work in progress to setup a build environment to build baseboxes with [Packer](http://www.packer.io) for VMware vCloud
to be used with [Vagrant](http://www.vagrantup.com) and the [vagrant-vcloud](https://github.com/frapposelli/vagrant-vcloud) plugin.
The basebox build environment itself can be built with the same tools and created inside the vCloud, eating and creating its own dogfood.

![basebox-slave network diagram](pics/basebox_slave.png)

## Installation
On your host machine you will need the following tools installed:

* Vagrant 1.6.3
* vagrant-vcloud plugin 0.4.0 with the command `vagrant plugin install vagrant-vcloud`
* Your vCloud access informations in your global `~/.vagrant.d/Vagrantfile`

After that you should clone this repo and have some customizations. See below for more details.

## Create the basebox builder

Now you can build the vApp 'the Vagrant way':

```bash
vagrant up --provider=vcloud
```

This will spin up an vApp with three VMs:

### basebox-jenkins
The `basebox-jenkins` VM is an Ubuntu server with a [Jenkins server](http://jenkins-ci.org) installed. This server has the IP address `176.16.32.2` and the HTTP port of Jenkins web interface listens on port 80.
A port forwarding is done even through your vCloud edge gateway if you have to use it.

Check out for the forwarded port while spinning up the vApp, or check it later with

```bash
vagrant vcloud -n
```

So you can retrieve the correct IP address and port number to access the Jenkins web interface from your host machine.

You can login to your jenkins server with just the following command:

```bash
vagrant ssh basebox-jenkins
```

### vmware-slave
The `vmware-slave` VM is a Windows machine (I use a windows_2008_r2). This machine has the IP address `176.16.32.3` and has RDP, SSH and WinRM ports opened. This VM will build baseboxes for the vCloud provider, but could also be used to build baseboxes for the VMware Workstation/Fusion provider.

You can login to your jenkins slave with RDP with the following command:

```bash
vagrant rdp vmware-slave
```

Notice: Windows host users need Vagrant 1.6.4 or at least a patch for the bug in Vagrant 1.6.3 to make `vagrant rdp` work. There is a problem writing the rdp file for mstsc at the moment.

After creating the vmware-slave VM you have to licsense the installed VMware Workstation manually. I have added a command in the `./scripts/provision-vmware-slave.bat` script to directly enter the VMware license, but I cannot put that into the repo.

This is a good situation to test the `vagrant rdp vmware-slave` which works nice.

The software installed in the vmware-slave is:

* [Chocolatey](http://chocolatey.org) - package like installations on Windows
* [packer 0.6.1.dev](http://www.packer.io/downloads.html) - built from source until 0.6.1 is released
* [packer-post-processor-vagrant-vmware-ovf 0.1.2](https://github.com/gosddc/packer-post-processor-vagrant-vmware-ovf/releases)
* VMware Workstation 10.0.2
* [Vagrant 1.6.3](http://www.vagrantup.com/downloads.html)
* [vagrant-vcloud 0.4.0](https://github.com/frapposelli/vagrant-vcloud/releases)
* optional global Vagrantfile from host (`./resources/Vagrantfile-global`)
* msysgit
* wget
* Java + Jenkins Swarm Client (Node labels: windows + vmware)

### vbox-slave
The `vbox-slave` VM is a Windows machine (I use a windows_2008_r2). This machine has the IP address `176.16.32.4` and has RDP, SSH and WinRM ports opened. This VM will build baseboxes for the VirtualBox provider.
Notice: My intended hostname was virtualbox-slave, but that is too long for windows, and guest customizations of vCloud aborts with an error.

You can login to your jenkins slave with RDP with the following command:

```bash
vagrant rdp vbox-slave
```

Notice: Windows host users need Vagrant 1.6.4 or at least a patch for the bug in Vagrant 1.6.3 to make `vagrant rdp` work. There is a problem writing the rdp file for mstsc at the moment.

The software installed in the vbox-slave is:

* [Chocolatey](http://chocolatey.org) - package like installations on Windows
* [packer 0.6.0](http://www.packer.io/downloads.html)
* [VirtualBox 4.3.12](https://www.virtualbox.org/wiki/Linux_Downloads)
* msysgit
* wget
* Java + Jenkins Swarm Client (Node labels: windows + virtualbox)

## Customization
As I have started the project much smaller with simple shell provisioning scripts, it still has its roots in plain shell scripts. Perhaps in the future there will be some higher level solution with Chef, Puppet, Ansible, ...

### Choose the baseboxes
In the `Vagrantfile` you may adjust the boxes and box_urls used for the three VMs.
As I cannot make the Windows VM public, I will change at least the box_url of the Ubuntu VM to one pointing to the vagrantcloud soon.

### Optional global Vagrantfile
In the `vmware-slave` box also Vagrant will be installed to test and upload the generated vcloud boxes.
Your user credentials to access the vCloud org could be passed with an optional global Vagrantfile.
This file must be placed at `./resources/Vagrantfile-global` and will be copied on provisioning into `%USERPROFILE%\.vagrant.d\Vagrantfile`.

A sample Vagrantfile-global looks like this:

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-vcloud")
    # vCloud Director provider settings
    config.vm.provider :vcloud do |vcloud|
      vcloud.hostname = "https://YOUR-VCLOUD"
      vcloud.username = "vagrant"
      vcloud.password = 'S@perS$cretP1ass'
      vcloud.org_name = "YOUR-ORG"
      vcloud.vdc_name = "YOUR-VDC"
      vcloud.catalog_name = "Vagrant"
      vcloud.vdc_network_name = "YOUR-NETWORK"

      # we do not need a edge gateway as the vmware-slave already is inside the vCloud
      # vcloud.vdc_edge_gateway = "SS-EDGE"
      # vcloud.vdc_edge_gateway_ip = "10.100.50.4"
    end
  end
end
```

### Mail Server for Jenkins mails
Edit the file `./scripts/install-jenkins-server.sh` to change the `smtpHost`

### License VMware Workstation
Log into the vmware-slave machine and enter the license of VMware Workstation.


## Jenkins

I use [grunt-jenkins](https://www.npmjs.org/package/grunt-jenkins) to customize and backup the Jenkins configuration. So my Jenkins box is only a throw away product to be set up again with Jenkins job configurations from source control.

My current Jenkins jobs are stored in this repo as well in the directory `jenkins-configuration`.

### Install grunt
On your host machine, you will need node, npm and grunt:

```
brew update
brew install node
npm install -g grunt-cli
```

### Install grunt-jenkins
On you host machine, you have to call 

```
npm install
```

to install grunt-jenkins and other Node dependencies.


### Customize Jenkins URL
In the `Gruntfile.js` you have to enter the Jenkins IP address and port to connect from your host to the Jenkins VM.

In my case this is `10.100.50.4:2200` as you can see in the Gruntfile.js. With grunt-jenkins 0.5.0 or above you can backup and restore through your vCloud Edge Gateway.

### Install Jenkins jobs

You can install my prebuilt Jenkins job configuration using:

```
grunt jenkins-install
```

When you added / removed plugins you must restart Jenkins:

```
open http://10.100.50.4:2200/safeRestart
```

Have a look at the Jenkins jobs, there you can see how I build the baseboxes and from with GitHub Repos they come from. See below for more details.

### Manage Jenkins configuration
After each time you made changes to the global Jenkins configuration, plugins
or jobs just do:

```
grunt jenkins-backup
git add jenkins-configuration
git commit
```

This will backup all stuff to the jenkins-configuration folder. You may put it
under version control, yay!

So the whole Jenkins server could be destroyed and rebuilt with another `vagrant up --provider=vcloud`.

## View Jenkins Web Interface
If you just want to view into Jenkins use this command:

```
open http://10.100.50.4:2200/
```     

![jenkins jobs](pics/jenkins-jobs.png)

You also can see the automatically added Jenkins node `vmware-slave` in the list of nodes:


![jenkins nodes](pics/jenkins-nodes.png)

## Eat your own dogfood

After successfully running some Jenkins jobs to build baseboxes, vagrant-vcloud even can eat its own dogfood. The workspace of the `vmware-slave` is accessible through the Jenkins server, as shown here:


![jenkins workspace with dogfood](pics/jenkins-dogfood.png)

So pick up the URL of the generated box file and feed vagrant on your host:

```bash
vagrant box add windows_2012_r2 http://10.100.50.4:2200/job/windows_2012_r2_vcloud/ws/windows_2012_r2_vcloud.box
```

But Jenkins could also be used to test the basebox and upload it to your basebox repo or to the [Vagrant Cloud](https://vagrantcloud.com).

# Licensing
Copyright (c) 2014 Stefan Scherer

MIT License, see LICENSE for more details.

