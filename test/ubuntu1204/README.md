# Ubuntu 12.04.4 LTS 64bit Vagrant example for vCloud
This shows the first Ubuntu boxes controlled by Vagrant in the vCloud.

## Global Vagrantfile
Put the following lines into your global `Vagrantfile`. This is in
`$HOME/.vagrant.d/Vagrantfile` or `%USERPROFILE%\.vagrant.d\Vagrantfile` or below your `VAGRANT_HOME` environment variable.

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-vcloud")
    # vCloud Director provider settings
    config.vm.provider :vcloud do |vcloud|
      vcloud.hostname = "https://your-vcloud-hostname"
      vcloud.username = "your-vcloud-username"
      vcloud.password = 'your-vcloud-password'
      vcloud.org_name = "your-org-name"
      vcloud.vdc_name = "your-vdc-name"
      vcloud.catalog_name = "Vagrant"
      vcloud.ip_subnet = "172.16.32.125/255.255.255.240"
      vcloud.vdc_network_name = "your-vdc-network-name"

      # vcloud.vdc_edge_gateway = "your-egde-gateway"
      # vcloud.vdc_edge_gateway_ip = "your-edge-gateway-ip"
    end
  end
end
```

### Working on a real host
If you are running vagrant from a real computer outside of the vCloud, then you also need the two values for the vdc_edge_gateway.

### Working from a VM in vCloud
If your ar running vagrant from a VM inside the vCloud, then comment out the edge_gateway values, because you don't have to talk over the edge gateway.

## Preparation of a Windows host
Working from a Windows host needs some preparation.

* Vagrant 1.5.3
* vagrant-vcloud plugin 0.2.2 + PR#38
* cygwin shell
* ssh from cygwin
* rsync from cygwin
* git from cygwin

## Start the vApp

```
vagrant up --provider=vcloud
```

## Shared folder?
In vCloud, there is no shared folder as in VirtualBox or VMware desktop versions. But vagrant uses `rsync` to synchronize the folder into the guest boxes at startup. So the guest boxes also have `/vagrant` or `c:\vagrant` with all the files from the host. But they are only a copy and no live synced folder.

