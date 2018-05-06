#on installe le repos ansible 
#yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
# yum -y --enablerepo=epel install ansible pyOpenSSL
yum -y install ansible pyOpenSSL

#install et configuration du projet openshift ansible 
ANSIBLE_DIR=/opt/ansible
mkdir -p $ANSIBLE_DIR

cp -r /vagrant/offline/conf_to_copy/openshift-ansible $ANSIBLE_DIR/

#cd openshift-ansible
#on checkout la version 3.7
#git ls-remote --heads origin 
#git checkout -b origin/release-3.7

#on modifie le fichier origin-dns.conf.j2 qui sera utilisé par dnsmask
cp -f /vagrant/offline/conf_to_copy/origin-dns.conf.j2 $ANSIBLE_DIR/openshift-ansible/roles/openshift_node/templates/origin-dns.conf.j2


#on crée le fichier inventory
cp -f /vagrant/offline/conf_to_copy/inventory $ANSIBLE_DIR/inventory 

#Et on lance l'install 
cd $ANSIBLE_DIR/openshift-ansible

ansible-playbook -i $ANSIBLE_DIR/inventory $ANSIBLE_DIR/openshift-ansible/playbooks/deploy_cluster.yml


