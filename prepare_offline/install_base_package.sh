echo "Installing common tool"
yum install -y wget git unzip net-tools bind bind-utils iptables-services bridge-utils bash-completion yum-utils createrepo

echo "installing docker $DOCKER_VERSION"
yum install -y install $DOCKER_VERSION

echo "installing centos-openshift-origin repo"
yum install -y centos-release-openshift-origin 
 
echo "installing epel repo"
yum install -y epel-release