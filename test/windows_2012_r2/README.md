# Windows boxes in vCloud
This is only a the for the vagrant-vcloud plugin. This will build two VM's in a vApp based on Windows Server 2012 R2 baseboxes.

## Installation
1. Install Vagrant 1.5.3 on Windows
2. Open a CMD shell
3. Install vagrant-vcloud plugin with `vagrant plugin install vagrant-vcloud`
3. Install vagrant-windows plugin with `vagrant plugin install vagrant-windows`

Check your settings with

```
vagrant --version
vagrant plugin list
```

It should show something like this

```
C:\Users\vagrant\code\basebox-slave\test\precise32>vagrant --version
Vagrant 1.5.3

C:\Users\vagrant\code\basebox-slave\test\precise32>vagrant plugin list
vagrant-login (1.0.1, system)
vagrant-share (1.0.1, system)
vagrant-vcloud (0.2.2)
vagrant-windows (1.6.0)
```


## Customization
Write your vCloud settings into your global `Vagrantfile`

```
notepad %USERPROFILE%\.vagrant.d\Vagrantfile
```

And enter the following lines to it

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-vcloud")
    # vCloud Director provider settings
    config.vm.provider :vcloud do |vcloud|
      vcloud.hostname = "https://roecloud001"
      vcloud.username = "your-vcloud-username"
      vcloud.password = "your-vcloud-password"

      vcloud.org_name = "SS"
      vcloud.vdc_name = "SS-VDC"

      vcloud.catalog_name = "Vagrant"
      vcloud.ip_subnet = "172.16.32.125/255.255.255.240"

      vcloud.vdc_network_name = "SS-INTERNAL"
      vcloud.vdc_edge_gateway = "SS-EDGE"
      vcloud.vdc_edge_gateway_ip = "10.100.52.4"
    end
  end

end
```


## Install basebox
You will need a basebox `windows_2012_r2` for this test. In my case this box is already uploaded to the vCloud catalog.

## Run
To start the example `multiboxes-windows` vApp, just enter

```
vagrant up --provider=vcloud --no-provision
```

The problem with windows boxes in vCloud is that they have to be rebooted more than once to set the hostname, to set the network cards etc. Therefore we have to use `--no-provision` in the first step, because of these reboots.

After the boxes are rebooted and ready, then you can do the provisioning with

```
vagrant provision
```


## Debugging
If you encounter problems, just use the `vagrantd` CMD script instead of the `vagrant` command. It will
do some convenient steps as stdout and stderr redirection into a log file, numerate the log files if
you want to play through more steps and debug all these steps afterwards.

Example:

```
vagrantd up --provider=vcloud
vagrantd halt
vagrantd up
vagrantd destroy -f
```

### Manual debugging
To turn on debug logging, you always can use the environment `VAGRANT_LOG=debug`

Example:

```
set VAGRANT_LOG=debug
vagrant up --provider=vcloud
```

## TODO
### Port forwarding collission
There is a problem with the port forwarding. It seems that the vApp NAT rules collide

```
vagrant up --provider=vcloud --no-provision

Bringing machine 'dc' up with 'vcloud' provider...
Bringing machine 'web' up with 'vcloud' provider...
==> dc: Building vApp...
==> dc: vApp multiboxes-windows-stefan.scherer-roenb014-9a76f9bb successfully created.
==> dc: Booting VM...
==> dc: Forwarding Ports: VM port 5985 -> vShield Edge port 5985
==> dc: Forwarding Ports: VM port 22 -> vShield Edge port 2222
==> dc: Warning! Folder sync disabled because the rsync binary is missing.
==> dc: Make sure rsync is installed and the binary can be found in the PATH.
==> web: Adding VM to existing vApp...
==> web: Booting VM...
==> web: Forwarding Ports: VM port 5985 -> vShield Edge port 5985
==> web: Forwarding Ports: VM port 80 -> vShield Edge port 8080
==> web: Forwarding Ports: VM port 22 -> vShield Edge port 2222
==> web: Warning! Folder sync disabled because the rsync binary is missing.
==> web: Make sure rsync is installed and the binary can be found in the PATH.
```
