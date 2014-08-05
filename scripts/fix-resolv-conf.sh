# this script is only needed until vCloud supports Ubuntu 14.04
# guest customization does not write these values into resolv.conf, 
# so we have to do it as first provisioning script.
if [ ! -f /etc/resolvconf/resolv.conf.d/tail ]; then
  echo "nameserver 10.100.20.2" | tee -a /etc/resolvconf/resolv.conf.d/tail
  echo "nameserver 8.8.8.8" | tee -a /etc/resolvconf/resolv.conf.d/tail
  resolvconf -u
fi