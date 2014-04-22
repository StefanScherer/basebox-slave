# precise32 box in vCloud
This is only a the for the vagrant-vcloud plugin. This will build two VM's in a vApp based on precise32 baseboxes.

## Installation
1. Install Vagrant 1.5.3 on Windows
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
Vagrant 1.5.3

C:\Users\vagrant\code\basebox-slave\test\precise32>vagrant plugin list
vagrant-login (1.0.1, system)
vagrant-share (1.0.1, system)
vagrant-vcloud (0.2.2)
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


## Run
To start the example `multiboxes-precise32` vApp, just enter

```
vagrant up --provider=vcloud
```

I you don't already have the `precise32` box for the vcloud provider, it will be downloaded and cached on your local computer.
It also will be uploaded to the vCloud catalog for faster reuse.

```
b:\GitHub\basebox-slave\test\precise32 [master]>vagrant up --provider=vcloud
Bringing machine 'web-vm' up with 'vcloud' provider...
Bringing machine 'db-vm' up with 'vcloud' provider...
==> web-vm: Building vApp...
==> web-vm: vApp multiboxes-precise32-stefan.scherer-roenb014-511a8a45 successfully created.
==> web-vm: Booting VM...
==> web-vm: Fixed port collision for 80 => 8080. Now on port 2200.
==> web-vm: Forwarding Ports: VM port 80 -> vShield Edge port 2200
==> web-vm: Forwarding Ports: VM port 22 -> vShield Edge port 2222
==> web-vm: Creating NAT rules on [SS-EDGE] for IP [10.100.50.4] port 2200.
==> web-vm: Creating NAT rules on [SS-EDGE] for IP [10.100.50.4] port 2222.
==> web-vm: Warning! Folder sync disabled because the rsync binary is missing.
==> web-vm: Make sure rsync is installed and the binary can be found in the PATH.
==> web-vm: Running provisioner: shell...
    web-vm: Running: C:/Users/STEFAN~1.SCH/AppData/Local/Temp/vagrant-shell20140419-10972-s5b191
stdin: is not a tty
Provisioning web-vm ...

Do a little self-check
Running script /tmp/vagrant-shell
-rwxrwxr-x 1 vagrant vagrant 236 Apr 19 17:01 /tmp/vagrant-shell
Directory /vagrant does not exist
==> db-vm: Adding VM to existing vApp...
==> db-vm: Booting VM...
==> db-vm: Fixed port collision for 22 => 2222. Now on port 2201.
==> db-vm: Forwarding Ports: VM port 5432 -> vShield Edge port 5432
==> db-vm: Forwarding Ports: VM port 22 -> vShield Edge port 2201
==> db-vm: Creating NAT rules on [SS-EDGE] for IP [10.100.50.4] port 5432.
==> db-vm: Creating NAT rules on [SS-EDGE] for IP [10.100.50.4] port 2201.
==> db-vm: Warning! Folder sync disabled because the rsync binary is missing.
==> db-vm: Make sure rsync is installed and the binary can be found in the PATH.
==> db-vm: Running provisioner: shell...
    db-vm: Running: C:/Users/STEFAN~1.SCH/AppData/Local/Temp/vagrant-shell20140419-10972-1tr04f8
stdin: is not a tty
Provisioning db-vm ...

Do a little self-check
Running script /tmp/vagrant-shell
-rwxrwxr-x 1 vagrant vagrant 236 Apr 19 17:03 /tmp/vagrant-shell
Directory /vagrant does not exist
```

## vCloud Status
With the command

`vagrant vcloud-status --all`

you can see all details of the running vApp.

```
b:\GitHub\basebox-slave\test\precise32 [master*]>vagrant vcloud-status --all
+------------------------------------+-------------------------------------------------------+
|                    Vagrant vCloud Director Status : https://roecloud001                    |
+------------------------------------+-------------------------------------------------------+
| Organization Name                  | SS                                                    |
| Organization vDC Name              | SS-VDC                                                |
| Organization vDC ID                | ea5a7837-1f8f-4e5b-8b75-511a7869995f                  |
| Organization vDC Network Name      | SS-INTERNAL                                           |
| Organization vDC Edge Gateway Name | SS-EDGE                                               |
| Organization vDC Edge IP           | 10.100.50.4                                           |
+------------------------------------+-------------------------------------------------------+
| vApp Name                          | multiboxes-precise32-stefan.scherer-roenb014-511a8a45 |
| vAppID                             | 04633d70-f50e-40fc-8331-0a4b4dbd2312                  |
| -> web-vm                          | a15df82a-d605-457d-8c50-190eed23b83f                  |
| -> db-vm                           | 957b9be9-f193-4d68-bf2a-c6be4b2b12a9                  |
+------------------------------------+-------------------------------------------------------+

+------------------------------------+-----------------------------------------------------------+---------+
|                                   Vagrant vCloud Director Network Map                                    |
+------------------------------------+-----------------------------------------------------------+---------+
| VM Name                            | Destination NAT Mapping                                   | Enabled |
+------------------------------------+-----------------------------------------------------------+---------+
| db-vm                              | 10.100.50.4:5432 -> 10.115.4.2:5432 -> 172.16.32.115:5432 | true    |
| db-vm                              | 10.100.50.4:2201 -> 10.115.4.2:2201 -> 172.16.32.115:22   | true    |
| web-vm                             | 10.100.50.4:2200 -> 10.115.4.2:2200 -> 172.16.32.114:80   | true    |
| web-vm                             | 10.100.50.4:2222 -> 10.115.4.2:2222 -> 172.16.32.114:22   | true    |
+------------------------------------+-----------------------------------------------------------+---------+
| Network Name                       | Source NAT Mapping                                        | Enabled |
+------------------------------------+-----------------------------------------------------------+---------+
| VM1-extern                         | 10.115.4.2 -> 10.100.50.4                                 | true    |
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
Install rsync.exe on my Windows host to test the synced folder as well.
