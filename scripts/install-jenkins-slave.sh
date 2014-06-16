# switch Ubuntu download mirror to German server
sudo sed -i 's,http://us.archive.ubuntu.com/ubuntu/,http://ftp.fau.de/ubuntu/,' /etc/apt/sources.list
sudo sed -i 's,http://security.ubuntu.com/ubuntu,http://ftp.fau.de/ubuntu,' /etc/apt/sources.list
sudo apt-get update -y

# switch to German keyboard layout
sudo sed -i 's/"us"/"de"/g' /etc/default/keyboard
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y console-common
sudo install-keymap de

# set timezone to German timezone
echo "Europe/Berlin" | sudo tee /etc/timezone
sudo dpkg-reconfigure -f noninteractive tzdata

# install development: 
sudo apt-get install -y curl git vim

if [ ! -d /vagrant/resources ]
then
  mkdir /vagrant/resources
fi

# install Oracle JDK 7
sudo apt-get purge openjdk*
sudo apt-get install -y python-software-properties
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update -y
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo /usr/bin/debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-installer
sudo apt-get install -y oracle-java7-set-default

# install jenkins
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
echo "deb http://pkg.jenkins-ci.org/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt-get update -y

sudo useradd jenkins
sudo groupadd jenkins
sudo mkdir -p /home/jenkins
sudo chown jenkins:jenkins /home/jenkins
sudo mkdir -p /var/run/jenkins
sudo chown jenkins /var/run/jenkins
sudo mkdir -p /var/lib/jenkins
sudo chown jenkins /var/lib/jenkins
sudo mkdir -p /var/log/jenkins
sudo chown jenkins /var/log/jenkins
sudo mkdir -p /var/lock/subsys


# retrieve latest version of swarm-client
swarmClientVersion=`curl -s  http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/maven-metadata.xml | grep latest | sed 's/\s*[<>a-z/]//g'`
sudo wget -O /var/lib/jenkins/swarm-client.jar http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$swarmClientVersion/swarm-client-$swarmClientVersion-jar-with-dependencies.jar

cat <<INITD | sudo tee /etc/init.d/swarm-client
#! /bin/sh

### BEGIN INIT INFO
# Provides:		swarm-client
# Required-Start:	\$remote_fs \$syslog
# Required-Stop:	\$remote_fs \$syslog
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# Short-Description:	Jenkins Swarm Client
### END INIT INFO

set -e

# /etc/init.d/swarm-client: start and stop the Jenkins Swarm Client daemon

test -e /var/lib/jenkins/swarm-client.jar || exit 0

umask 022

if test -f /etc/default/swarm-client; then
    . /etc/default/swarm-client
fi

. /lib/lsb/init-functions

SWARM_OPTS="-jar /var/lib/jenkins/swarm-client.jar -autoDiscoveryAddress 192.168.33.255 -labels ubuntu -fsroot /var/lib/jenkins"

# Are we running from init?
run_by_init() {
    ([ "\$previous" ] && [ "\$runlevel" ]) || [ "\$runlevel" = S ]
}

check_dev_null() {
    if [ ! -c /dev/null ]; then
	if [ "\$1" = log_end_msg ]; then
	    log_end_msg 1 || true
	fi
	if ! run_by_init; then
	    log_action_msg "/dev/null is not a character device!" || true
	fi
	exit 1
    fi
}

export PATH="\${PATH:+\$PATH:}/usr/sbin:/sbin"

case "\$1" in
  start)
	check_dev_null
	log_daemon_msg "Starting Jenkins Swarm Client" "swarm-client" || true
	if start-stop-daemon --start --quiet --oknodo --make-pidfile --pidfile /var/run/swarm-client.pid --background --chuid jenkins --chdir /var/lib/jenkins --exec /bin/bash -- -c "/usr/bin/java \$SWARM_OPTS > /var/log/jenkins/swarm-client.log 2>&1"; then
	    log_end_msg 0 || true
	else
	    log_end_msg 1 || true
	fi
	;;
  stop)
	log_daemon_msg "Stopping OpenBSD Secure Shell server" "swarm-client" || true
        bashPID=`cat /var/run/swarm-client.pid`; [ -n "\$bashPID" ] && pkill -P "\$bashPID"
	if start-stop-daemon --stop --quiet --oknodo --pidfile /var/run/swarm-client.pid; then
	    log_end_msg 0 || true
	else
	    log_end_msg 1 || true
	fi
	;;

  reload|force-reload)
	log_daemon_msg "Reloading OpenBSD Secure Shell server's configuration" "swarm-client" || true
        bashPID=`cat /var/run/swarm-client.pid`; [ -n "\$bashPID" ] && pkill -P "\$bashPID"
	if start-stop-daemon --stop --signal 1 --quiet --oknodo --pidfile /var/run/swarm-client.pid; then
	    log_end_msg 0 || true
	else
	    log_end_msg 1 || true
	fi
	;;

  restart)
	log_daemon_msg "Restarting OpenBSD Secure Shell server" "swarm-client" || true
        bashPID=`cat /var/run/swarm-client.pid`; [ -n "\$bashPID" ] && pkill -P "\$bashPID"
	start-stop-daemon --stop --quiet --oknodo --retry 30 --pidfile /var/run/swarm-client.pid
	check_dev_null log_end_msg
	if start-stop-daemon --start --quiet --oknodo --make-pidfile --pidfile /var/run/swarm-client.pid --background --chuid jenkins --chdir /var/lib/jenkins --exec /bin/bash -- -c "/usr/bin/java \$SWARM_OPTS > /var/log/jenkins/swarm-client.log 2>&1"; then
	    log_end_msg 0 || true
	else
	    log_end_msg 1 || true
	fi
	;;

  try-restart)
	log_daemon_msg "Restarting OpenBSD Secure Shell server" "swarm-client" || true
	RET=0
        bashPID=`cat /var/run/swarm-client.pid`; [ -n "\$bashPID" ] && pkill -P "\$bashPID"
	start-stop-daemon --stop --quiet --retry 30 --pidfile /var/run/swarm-client.pid || RET="\$?"
	case \$RET in
	    0)
		# old daemon stopped
		check_dev_null log_end_msg
		if start-stop-daemon --start --quiet --oknodo --make-pidfile --pidfile /var/run/swarm-client.pid --background --chuid jenkins --chdir /var/lib/jenkins --exec /bin/bash -- -c "/usr/bin/java \$SWARM_OPTS > /var/log/jenkins/swarm-client.log 2>&1"; then
		    log_end_msg 0 || true
		else
		    log_end_msg 1 || true
		fi
		;;
	    1)
		# daemon not running
		log_progress_msg "(not running)" || true
		log_end_msg 0 || true
		;;
	    *)
		# failed to stop
		log_progress_msg "(failed to stop)" || true
		log_end_msg 1 || true
		;;
	esac
	;;

  status)
	status_of_proc -p /var/run/swarm-client.pid /usr/bin/java swarm-client && exit 0 || exit \$?
	;;

  *)
	log_action_msg "Usage: /etc/init.d/swarm-client {start|stop|reload|force-reload|restart|try-restart|status}" || true
	exit 1
esac

exit 0
INITD

sudo chmod +x /etc/init.d/swarm-client
sudo update-rc.d swarm-client defaults
sudo update-rc.d swarm-client enable
sudo service swarm-client start

