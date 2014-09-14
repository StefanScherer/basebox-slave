#!/bin/bash
wget -O VMware-Workstation.bundle --no-check-certificate http://www.vmware.com/go/tryworkstation-linux-64
sudo sh ./VMware-Workstation.bundle --console --required --eulas-agreed
rm ./VMware-Workstation.bundle
