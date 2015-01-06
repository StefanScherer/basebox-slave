# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-vcloud")
    config.vm.provider "vcloud" do |vcloud|
      vcloud.vapp_name = "basebox"
      vcloud.ip_subnet = "172.16.32.1/255.255.255.0" # our test subnet with fixed IP adresses for everyone
      vcloud.ip_dns = ["10.100.20.2", "8.8.8.8"]  # dc + Google
    end
  end

  # the Jenkins CI server
  config.vm.define "basebox-jenkins", primary: true do |ci|
    ci.vm.box = "ubuntu1404"

    ci.vm.hostname = "basebox-jenkins"
    ci.vm.network :private_network, ip: "172.16.32.2" # VirtualBox
    ci.vm.network :forwarded_port, guest: 80, host: 80, id: "http", auto_correct: true

    ci.vm.provision "shell", privileged: false, path: "scripts/install-jenkins-server.sh"

    ci.vm.provider "vcloud" do |v|
      v.memory = 1024
      v.cpus = 1
    end
    ci.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 1
    end
    ["vmware_fusion", "vmware_workstation"].each do |provider|
      ci.vm.provider provider do |v, override|
        v.vmx["memsize"] = "1024"
        v.vmx["numvcpus"] = "1"
      end
    end
  end

  config.vm.define "vmware-slave" do |slave|
    slave.vm.box = "windows_2008_r2"
    slave.vm.hostname = "vmware-slave"

    slave.vm.communicator = "winrm"
    slave.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    slave.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
    slave.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true

    slave.vm.network :private_network, ip: "172.16.32.3" # VirtualBox

    slave.vm.provision "shell", path: "scripts/provision-vmware-slave.bat"
    slave.vm.provider "vcloud" do |v|
      v.memory = 4096
      v.cpus = 2
      v.nested_hypervisor = true
      v.add_hdds = [ 131072 ] # add 128GByte disk
    end
    slave.vm.provider "virtualbox" do |v|
      v.gui = true
      v.memory = 4096
      v.cpus = 2
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      v.customize ["modifyvm", :id, "--vram", "32"]
    end
    ["vmware_fusion", "vmware_workstation"].each do |provider|
      slave.vm.provider provider do |v, override|
        v.gui = true
        v.vmx["memsize"] = "4096"
        v.vmx["numvcpus"] = "2"
        v.vmx["vhv.enable"] = "TRUE"
      end
    end
  end

  config.vm.define "vbox-slave" do |slave|
    slave.vm.box = "windows_2008_r2"
    slave.vm.hostname = "vbox-slave"

    slave.vm.communicator = "winrm"
    slave.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    slave.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
    slave.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true

    slave.vm.network :private_network, ip: "172.16.32.4" # VirtualBox

    slave.vm.provision "shell", path: "scripts/provision-virtualbox-slave.bat"
    slave.vm.provider "vcloud" do |v|
      v.memory = 4096
      v.cpus = 2
      v.nested_hypervisor = true
      v.add_hdds = [ 131072 ] # add 128GByte disk
    end
    slave.vm.provider "virtualbox" do |v|
      v.gui = true
      v.memory = 4096
      v.cpus = 2
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      v.customize ["modifyvm", :id, "--vram", "32"]
    end
    ["vmware_fusion", "vmware_workstation"].each do |provider|
      slave.vm.provider provider do |v, override|
        v.gui = true
        v.vmx["memsize"] = "4096"
        v.vmx["numvcpus"] = "2"
        v.vmx["vhv.enable"] = "TRUE"
      end
    end
  end

  config.vm.define "wsus", autostart: false do |wsus|
    wsus.vm.box = "windows_2012_r2"
    wsus.vm.hostname = "wsus"

    wsus.vm.communicator = "winrm"
    wsus.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    wsus.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
    wsus.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
    wsus.vm.network :forwarded_port, guest: 8530, host: 8530, id: "wsus-http", auto_correct: true
    wsus.vm.network :forwarded_port, guest: 8531, host: 8531, id: "wsus-https", auto_correct: true

    wsus.vm.network :private_network, ip: "172.16.32.5" # VirtualBox

    wsus.vm.provision "shell", path: "scripts/provision-wsus.ps1"

    wsus.vm.provider "vcloud" do |vb, override|
      vb.memory = 2048
      vb.cpus = 2
    end

    wsus.vm.provider :virtualbox do |vb, override|
      vb.gui = true
      vb.memory = 2048
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--vram", "32"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end
    ["vmware_fusion", "vmware_workstation"].each do |provider|
      wsus.vm.provider provider do |v, override|
        v.gui = true
        v.vmx["memsize"] = "2048"
        v.vmx["numvcpus"] = "2"
      end
    end
  end

  config.vm.define "vmware-slave-lin", autostart: false do |slave|
    slave.vm.box = "ubuntu1404"
    slave.vm.hostname = "vmware-slave"

    slave.vm.network :private_network, ip: "172.16.32.6" # VirtualBox
    slave.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true

    slave.vm.provision "shell", path: "scripts/provision-vmware-slave.sh"
    slave.vm.provision "shell", path: "scripts/install-jenkins-slave.sh"
    slave.vm.provision "shell", path: "scripts/install-xrdp.sh"
    slave.vm.provider "vcloud" do |v|
      v.memory = 4096
      v.cpus = 2
      v.nested_hypervisor = true
      v.add_hdds = [ 131072 ] # add 128GByte disk
    end
    slave.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 2
    end
    ["vmware_fusion", "vmware_workstation"].each do |provider|
      slave.vm.provider provider do |v, override|
        v.gui = true
        v.vmx["memsize"] = "4096"
        v.vmx["numvcpus"] = "2"
        v.vmx["vhv.enable"] = "TRUE"
      end
    end
  end

  # disabled: slow packer / virtualbox performance on ubuntu in vcloud
  config.vm.define "vbox-slave-lin", autostart: false do |slave|
    slave.vm.box = "ubuntu1404"
    slave.vm.hostname = "vbox-slave"

    slave.vm.network :private_network, ip: "172.16.32.7" # VirtualBox
    slave.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true

    slave.vm.provision "shell", path: "scripts/provision-virtualbox-slave.sh"
    slave.vm.provision "shell", path: "scripts/install-jenkins-slave.sh"
    slave.vm.provision "shell", path: "scripts/install-xrdp.sh"
    slave.vm.provider "vcloud" do |v|
      v.memory = 4096
      v.cpus = 3
      v.nested_hypervisor = true
      v.add_hdds = [ 131072 ] # add 128GByte disk
    end
    slave.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end
    ["vmware_fusion", "vmware_workstation"].each do |provider|
      slave.vm.provider provider do |v, override|
        v.vmx["memsize"] = "2048"
        v.vmx["numvcpus"] = "2"
        v.vmx["vhv.enable"] = "TRUE"
      end
    end
  end

end
