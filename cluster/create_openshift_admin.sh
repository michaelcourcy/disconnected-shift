htpasswd -b /etc/origin/master/htpasswd admin redhat
oc adm policy add-cluster-role-to-user cluster-admin admin

systemctl restart origin-master-api

echo "******"
echo "* Admin console is https://master.lab.example.com:8443"
echo "* Login: admin "
echo "* Passw: redhat "
echo "*"
echo "******"


