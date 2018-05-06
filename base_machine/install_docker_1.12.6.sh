yum install -y docker-1.12.6
rpm -V docker-1.12.6
docker version
# pour connaitre le disk libre pour docker probablement sdb mais a adapter
fdisk –l 
#verifier vos lv on ne voit pas docker-pool
lvdisplay
#mettre a jour le fichier de configuration du script de création du volume-group qui sera utiliser par docker 
cat <<EOF > /etc/sysconfig/docker-storage-setup
DEVS=/dev/sdb
VG=docker-vg
DATA_SIZE="100%FREE"
EOF
#executer 
docker-storage-setup
#verifier vos lv on voit docker-pool appartenat à docker vg 
lvdisplay
#vérifier que docker est bien configuré sur ce stockage
cat /etc/sysconfig/docker-storage
systemctl status docker
systemctl enable docker
systemctl start docker
echo "****************************************************"
echo "* INSTALL TERMINEE                                 *"
echo "*                                                  *"
echo "* Modifier le mot de passe root avant de packager  *"
echo "*                                                  *"
echo "****************************************************"