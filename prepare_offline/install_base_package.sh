echo "Installing base package"
yum install -y wget git unzip net-tools bind bind-utils iptables-services bridge-utils bash-completion yum-utils createrepo

echo "installing docker $DOCKER_VERSION"
yum install -y docker-1.13.1
systemctl start docker 
systemctl enable docker 

echo "installing centos-openshift-origin repo"
yum install -y centos-release-openshift-origin 
 
echo "installing epel repo"
yum install -y epel-release

echo "installing glusterfs"
 yum install -y centos-release-gluster310