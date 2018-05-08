yum install -y docker-1.13.1
rpm -V docker-1.13.1
docker version
# The disck you created is probably sdb to be sure run :
fdisk –l 
#Check no logical volume docker-pool exist 
lvdisplay

#
cat <<EOF > /etc/sysconfig/docker-storage-setup
DEVS=/dev/sdb
VG=docker-vg
DATA_SIZE="100%FREE"
EOF
docker-storage-setup
#now check the docker storage 
lvdisplay
#Check docker storage now point to the lv created 
cat /etc/sysconfig/docker-storage
systemctl status docker
systemctl enable docker
systemctl start docker
