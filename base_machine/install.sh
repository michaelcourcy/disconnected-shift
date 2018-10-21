# Prepa des packages de bases 
# https://docs.openshift.org/latest/install_config/install/host_preparation.html#install-config-install-host-preparation : 
echo "common dependecies"
yum clean all

yum install -y deltarpm
yum install -y dkms
yum install -y wget git unzip net-tools bind bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct yum-utils device-mapper-persistent-data lvm2 sshpass
yum update -y
yum install -y gcc python-virtualenv atomic yum-utils

yum install -y origin-clients 

#install vbox tools
cd /opt/VBox*/init
./vboxadd setup

#install ntp
#TODO 
#this part is a bit annoying if you are planning to be really offline. Test showed it works but the good pattern is to make workstation a ntpserver and have all the machine pointing to it
yum install -y ntp
systemctl enable ntpdate
systemctl start ntpdate
#visual check of the date 
date

# desactivate firewall
# TODO harden this for production use. Firewall rules are differents for master or nodes 
systemctl stop firewalld
systemctl disable firewalld

#reduce the size of the machine
yum clean all
