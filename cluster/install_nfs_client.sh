echo "Installing the nfs client"
yum -y install nfs-utils
mkdir -p /mnt/nfs/share
echo "Mounting the remote directory 172.25.250.254:/var/nfsshare on /mnt/nfs/share"
mount -t nfs 172.25.250.254:/var/nfsshare /mnt/nfs/share
echo "adding the mount to fstab"
echo "172.25.250.254:/var/nfsshare    /mnt/nfs/share   nfs defaults 0 0" >> /etc/fstab
echo "SELinux does not allow writing from a pod to a remote NFS server. To enable writing to NFS volumes with SELinux enforcing on each node"
setsebool -P virt_use_nfs on