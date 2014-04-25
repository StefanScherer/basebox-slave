echo "Provisioning `hostname` ..."
echo ""
echo "Do a little self-check"
echo "Running script $0"
ls -l $0

if [ -d /vagrant ]; then
  echo "Directory /vagrant exists"
  ls -l /vagrant
else
  echo "Directory /vagrant does not exist"
fi
