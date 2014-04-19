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
      vcloud.vdc_edge_gateway_ip = "10.100.50.4"
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

The output should look like this:

```
b:\GitHub\basebox-slave\test\windows_2012_r2 [master*]>vagrant up --provider=vcloud --no-provision
Bringing machine 'dc' up with 'vcloud' provider...
Bringing machine 'web' up with 'vcloud' provider...
==> dc: Building vApp...
==> dc: vApp multiboxes-windows-stefan.scherer-roenb014-f04d9a27 successfully created.
==> dc: Booting VM...
==> dc: Fixed port collision for 22 => 2222. Now on port 2202.
==> dc: Forwarding Ports: VM port 5985 -> vShield Edge port 5985
==> dc: Forwarding Ports: VM port 22 -> vShield Edge port 2202
==> dc: Creating NAT rules on [SS-EDGE] for IP [10.100.50.4] port 5985.
==> dc: Creating NAT rules on [SS-EDGE] for IP [10.100.50.4] port 2202.
==> dc: Warning! Folder sync disabled because the rsync binary is missing.
==> dc: Make sure rsync is installed and the binary can be found in the PATH.
==> web: Adding VM to existing vApp...
==> web: Booting VM...
==> web: Fixed port collision for 5985 => 5985. Now on port 2203.
==> web: Fixed port collision for 80 => 8080. Now on port 2204.
==> web: Fixed port collision for 22 => 2222. Now on port 2205.
==> web: Forwarding Ports: VM port 5985 -> vShield Edge port 2203
==> web: Forwarding Ports: VM port 80 -> vShield Edge port 2204
==> web: Forwarding Ports: VM port 22 -> vShield Edge port 2205
==> web: Creating NAT rules on [SS-EDGE] for IP [10.100.50.4] port 2203.
==> web: Creating NAT rules on [SS-EDGE] for IP [10.100.50.4] port 2204.
==> web: Creating NAT rules on [SS-EDGE] for IP [10.100.50.4] port 2205.
==> web: Warning! Folder sync disabled because the rsync binary is missing.
==> web: Make sure rsync is installed and the binary can be found in the PATH.
```

After the boxes are rebooted and ready, then you can do the provisioning with

```
vagrant provision
```

The output should look like this:

```
b:\GitHub\basebox-slave\test\windows_2012_r2 [master*]>vagrant provision
==> dc: Warning! Folder sync disabled because the rsync binary is missing.
==> dc: Make sure rsync is installed and the binary can be found in the PATH.
==> dc: Running provisioner: shell...
Provisioning  DC  =  dc  ...

Do a little self-check
Running script  + vagrant-shell.ps1
Directory c:\vagrant does not exist
==> web: Warning! Folder sync disabled because the rsync binary is missing.
==> web: Make sure rsync is installed and the binary can be found in the PATH.
==> web: Running provisioner: shell...
Provisioning  DC  =  dc  ...

Do a little self-check
Running script  + vagrant-shell.ps1
Directory c:\vagrant does not exist
```

## vCloud Status
With the command

`vagrant vcloud-status --all`

you can see all details of the running vApp.

```
b:\GitHub\basebox-slave\test\windows_2012_r2 [master*]>vagrant vcloud-status -
-all
+------------------------------------+-----------------------------------------------------+
|                   Vagrant vCloud Director Status : https://roecloud001                   |
+------------------------------------+-----------------------------------------------------+
| Organization Name                  | SS                                                  |
| Organization vDC Name              | SS-VDC                                              |
| Organization vDC ID                | ea5a7837-1f8f-4e5b-8b75-511a7869995f                |
| Organization vDC Network Name      | SS-INTERNAL                                         |
| Organization vDC Edge Gateway Name | SS-EDGE                                             |
| Organization vDC Edge IP           | 10.100.50.4                                         |
+------------------------------------+-----------------------------------------------------+
| vApp Name                          | multiboxes-windows-stefan.scherer-roenb014-f04d9a27 |
| vAppID                             | 09b590d8-4aae-41c9-b774-ec8529696633                |
| -> dc                              | ea676c25-214a-49be-a502-2046d22f06f6                |
| -> web                             | 8cd57825-be93-490b-9f4d-3c7c7b766d5d                |
+------------------------------------+-----------------------------------------------------+

+------------------------------------+-----------------------------------------------------------+---------+
|                                   Vagrant vCloud Director Network Map                                    |
+------------------------------------+-----------------------------------------------------------+---------+
| VM Name                            | Destination NAT Mapping                                   | Enabled |
+------------------------------------+-----------------------------------------------------------+---------+
| web                                | 10.100.50.4:2203 -> 10.115.4.4:2203 -> 172.16.32.115:5985 | true    |
| web                                | 10.100.50.4:2204 -> 10.115.4.4:2204 -> 172.16.32.115:80   | true    |
| web                                | 10.100.50.4:2205 -> 10.115.4.4:2205 -> 172.16.32.115:22   | true    |
| dc                                 | 10.100.50.4:5985 -> 10.115.4.4:5985 -> 172.16.32.114:5985 | true    |
| dc                                 | 10.100.50.4:2202 -> 10.115.4.4:2202 -> 172.16.32.114:22   | true    |
+------------------------------------+-----------------------------------------------------------+---------+
| Network Name                       | Source NAT Mapping                                        | Enabled |
+------------------------------------+-----------------------------------------------------------+---------+
| VM1-extern                         | 10.115.4.4 -> 10.100.50.4                                 | true    |
+------------------------------------+-----------------------------------------------------------+---------+
| Rule# - Description                | Firewall Rules                                            | Enabled |
+------------------------------------+-----------------------------------------------------------+---------+
| 1 - (Allow Vagrant Communications) | allow SRC:Any:Any to DST:10.100.50.4:Any                  | true    |
+------------------------------------+-----------------------------------------------------------+---------+
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
I should install rsync.exe on my Windows host to test the synced folder as well. Propably a SSH connection is needed for this step.
The vagrant-windows plugin is then not needed as we always need an OpenSSH service on the windows guests.
