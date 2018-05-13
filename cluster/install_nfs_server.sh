#echo "create an xfs file system on sdc"
#mkfs.xfs /dev/sdc

#echo "mounting the file system to /var/nfsshare and adding to fstab"
mkdir -p /var/nfsshare
#mount /dev/sdc /var/nfsshare
#echo "/dev/sdc /var/nfsshare xfs defaults 0 0" > /etc/fstab

chmod -R 700 /var/nfsshare


echo "Install and start utilities for nfs"
yum -y install nfs-utils
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap

chown nfsnobody:nfsnobody /var/nfsshare
echo "Add /var/nfsshare to the export file allowing any machine from 172.25.250.0/24"
echo "We allow read-write access and we squash any uid to nfsnobody. We use async for better performances"
echo "/var/nfsshare    172.25.250.0/24(rw,async,all_squash)" >> /etc/exports

systemctl restart nfs-server

echo "Adding the nfs client"
ssh root@node1.lab.example.com  'sh /vagrant/install_nfs_client.sh'
ssh root@node2.lab.example.com  'sh /vagrant/install_nfs_client.sh'
ssh root@master.lab.example.com 'sh /vagrant/install_nfs_client.sh'