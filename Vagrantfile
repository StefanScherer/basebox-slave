# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-vcloud")
    config.vm.provider :vcloud do |vcloud|
      vcloud.vapp_prefix = "basebox"
      vcloud.ip_subnet = "172.16.32.1/255.255.255.0" # our test subnet with fixed IP adresses for everyone      
      vcloud.ip_dns = ["10.100.20.2", "8.8.8.8"]  # dc + Google
    end
  end

  # the Jenkins CI server
  config.vm.define "basebox-jenkins", primary: true do |ci|
    ci.vm.box = "ubuntu1204"
  
    ci.vm.hostname = "basebox-jenkins"
    ci.vm.network :private_network, ip: "172.16.32.2" # VirtualBox
    ci.vm.network :forwarded_port, guest: 80, host: 80, id: "http", auto_correct: true
  
    ci.vm.provision "shell", privileged: false, path: "scripts/install-jenkins-server.sh"
  
    ci.vm.provider "vcloud" do |v|
      v.memory = 1024
      v.cpus = 1
    end
    ci.vm.provider :virtualbox do |v|
      v.memory = 1024
      v.cpus = 1
    end
  end

  config.vm.define :"vmware-slave" do |slave|
    slave.vm.box = "windows_2008_r2-100gb"
    slave.vm.hostname = "vmware-slave"

    slave.vm.communicator = "winrm"
    slave.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    slave.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
    slave.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true

    slave.vm.network :private_network, ip: "172.16.32.3" # VirtualBox

    slave.vm.provision "shell", path: "scripts/provision-vmware-slave.bat"
    slave.vm.provision "shell", path: "scripts/install-jenkins-slave.bat"
    # reboot the vmware-slave to have all tools in PATH and then start the swarm client
    slave.vm.provision "shell", path: "scripts/reboot-to-slave.bat"
    slave.vm.provider "vcloud" do |v|
      v.memory = 4096
      v.cpus = 2
      v.nested_hypervisor = true
    end
    slave.vm.provider :virtualbox do |v|
      v.gui = true
      v.memory = 2048
      v.cpus = 2
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      v.customize ["modifyvm", :id, "--vram", "32"]
    end
  end


  config.vm.define :"vbox-slave" do |slave|
    slave.vm.box = "windows_2008_r2-100gb"
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
    end
    slave.vm.provider :virtualbox do |v|
      v.gui = true
      v.memory = 2048
      v.cpus = 2
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      v.customize ["modifyvm", :id, "--vram", "32"]
    end
  end

end
