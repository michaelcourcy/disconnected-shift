# Prepa des packages de bases 
# https://docs.openshift.org/latest/install_config/install/host_preparation.html#install-config-install-host-preparation : 
echo "Installation des dépendances communes"
yum clean all
# yum --enablerepo=extras install -y epel-release
yum install -y deltarpm
yum install -y dkms
yum install -y wget git unzip net-tools bind bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct yum-utils device-mapper-persistent-data lvm2 sshpass
yum update -y
yum install -y gcc python-virtualenv atomic yum-utils
# yum install -y centos-release-openshift-origin 
yum install -y origin-clients 
cd /opt/VBox*/init
./vboxadd setup

#install du serveur de temps 
yum install -y ntp
systemctl enable ntpdate
systemctl start ntpdate
# desactivation du firewall
systemctl stop firewalld
systemctl disable firewalld
#controle de la date
date
yum clean all
