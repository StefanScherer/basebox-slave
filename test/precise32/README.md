# precise32 box in vCloud
This is only a the for the vagrant-vcloud plugin

## Installation
1. Install vagrant 1.5.2 on windows
2. Open a CMD shell
3. Install vagrant-vcloud plugin with `vagrant plugin install vagrant-vcloud`

Check your settings with

```
vagrant --version
vagrant plugin list
```

It should show something like this

```
C:\Users\vagrant\code\basebox-slave\test\precise32>vagrant --version
Vagrant 1.5.2

C:\Users\vagrant\code\basebox-slave\test\precise32>vagrant plugin list
vagrant-login (1.0.1, system)
vagrant-share (1.0.1, system)
vagrant-vcloud (0.2.1)
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
      vcloud.username = "your_user_name"
      vcloud.password = "XXXXXXX"

      vcloud.org_name = "SS"
      vcloud.vdc_name = "SS-VDC"

      vcloud.catalog_name = "Vagrant"
      vcloud.ip_subnet = "10.115.4.0/255.255.255.0"

      vcloud.vdc_network_name = "SS-INTERNAL"

      vcloud.vdc_edge_gateway = "SS-EDGE"
      vcloud.vdc_edge_gateway_ip = "10.100.52.4"
    end
  end

end
```


## Run
To start the example `precise32` box, just enter

```
vagrant up --provider=vcloud
```

I you don't already have the `precise32` box for the vcloud provider, the output looks like this.
The box will be downloaded and cached on your local computer.

```
C:\Users\vagrant\code\basebox-slave\test\precise32>vagrant up --provider=vcloud
Bringing machine 'web-vm' up with 'vcloud' provider...
==> web-vm: Box 'precise32' could not be found. Attempting to find and install..
.
    web-vm: Box Provider: vcloud
    web-vm: Box Version: >= 0
==> web-vm: Adding box 'precise32' (v0) for provider: vcloud
    web-vm: Downloading: http://vagrant.tsugliani.fr/precise32.box
    web-vm: Progress: 100% (Rate: 3360k/s, Estimated time remaining: --:--:--)
==> web-vm: Successfully added box 'precise32' (v0) for 'vcloud'!
==> web-vm: Building vApp...
==> web-vm: vApp Vagrant-vagrant-vpn-win7-7a8141b3 successfully created.
==> web-vm: Booting VM...
==> web-vm: Removing NAT rules on [SS-EDGE] for IP [10.100.52.4].
==> web-vm: Creating NAT rules on [SS-EDGE] for IP [10.100.52.4].
```


## Debugging
If you encounter problems, use the vagrant debug logging by setting the environment `VAGRANT_LOG=debug`

Example:

```
set VAGRANT_LOG=debug
vagrant up --provider=vcloud
```
