#on installe le repos ansible 
#yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
# yum -y --enablerepo=epel install ansible pyOpenSSL
yum -y install ansible pyOpenSSL

#install et configuration du projet openshift ansible 
ANSIBLE_DIR=/opt/ansible
mkdir -p $ANSIBLE_DIR

cp -r /vagrant/offline/conf_to_copy/openshift-ansible $ANSIBLE_DIR/

#openshift_examples_modify_imagestreams has no effect on origin install https://github.com/openshift/openshift-ansible/issues/8315
#I had to change manually the file openshift-ansible/roles/openshift_examples/files/examples/v3.9/image-streams/image-streams-centos7.json
#to have the image streams to point to the workstation.lab.example.com registry
cp /vagrant/offline/conf_to_copy/image-streams-centos7_modified_for_workstation.json $ANSIBLE_DIR/openshift-ansible/roles/openshift_examples/files/examples/v3.9/image-streams/image-streams-centos7.json

#we change the origin-dns.conf.j2 that will be used by dnsmask because we have in vagrant 2 interface the nat and the 172.25.250.0/24 
#we didn't make named a recursive named server because the upstream dns server depend of the connection we have on the laptop 
#thus we instruct dnsmask to query both dns 172.25.250.254 plus the one coming from the nat interface  
cp -f /vagrant/offline/conf_to_copy/origin-dns.conf.j2 $ANSIBLE_DIR/openshift-ansible/roles/openshift_node/templates/origin-dns.conf.j2

#on crée le fichier inventory
cp -f /vagrant/offline/conf_to_copy/inventory $ANSIBLE_DIR/inventory 

#Et on lance l'install 
cd $ANSIBLE_DIR/openshift-ansible

ansible-playbook -i $ANSIBLE_DIR/inventory $ANSIBLE_DIR/openshift-ansible/playbooks/deploy_cluster.yml


