# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-vcloud")
    config.vm.provider :vcloud do |vcloud|
      vcloud.vapp_prefix = "basebox-slave"
      vcloud.ip_dns = ["10.100.20.2", "8.8.8.8"]  # dc + Google
    end
  end

  config.vm.define :"basebox-slave" do |slave|
    slave.vm.box = "windows_2008_r2"
    slave.vm.hostname = "basebox-slave"

    slave.vm.communicator = "winrm"
    slave.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    slave.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
    slave.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true

    slave.vm.provision "shell", path: "provision-basebox-slave.bat"
    slave.vm.provider "vcloud" do |v|
      v.memory = 4096
      v.cpus = 2
      v.nested_hypervisor = true
    end

  end

end
