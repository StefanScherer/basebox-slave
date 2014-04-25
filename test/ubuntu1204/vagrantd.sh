#!/bin/bash
if [ "$1" == "" ]; then
  echo "Usage: vagrantd command ..."
  echo "Writes a vagrant debug log file while running a vagrant command."
  echo "The log files have a counter prefix for easier sorting."
  exit
fi

Num=1
if [ -f "counter.txt" ]; then
  Num=$[$(cat counter.txt) + 1]
fi
echo $Num >counter.txt

Num=$(printf %02d ${Num})

echo $formattedNum

Name=$*
Name=${Name// /-}
Name=${Name//---/-}
Name=${Name//--/-}
Name=${Name//=/-}
logfile=$Num-vagrant-${Name}.log

echo Writing debug log file $logfile
echo Calling vagrant $* --debug
vagrant $* --debug >$logfile 2>&1
vagrantexitcode=$?
grep "INFO interface:" $logfile
echo ""
echo Vagrant exited with $vagrantexitcode. See $logfile for more details
