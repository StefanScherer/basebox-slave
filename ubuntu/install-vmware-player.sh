#!/bin/bash
if [ ! -f VMware-Player-6.0.2-1744117.x86_64.bundle ]; then
  wget https://download3.vmware.com/software/player/file/VMware-Player-6.0.2-1744117.x86_64.bundle
fi
sudo sh ./VMware-Player-6.0.2-1744117.x86_64.bundle --console --eulas-agreed --required
