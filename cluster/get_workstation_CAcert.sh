echo "Copy Ca cetificate on $(hostname)" 
mkdir -p /etc/docker/certs.d/workstation.lab.example.com
cp /vagrant/offline/conf_to_copy/certs/CA.crt /etc/docker/certs.d/workstation.lab.example.com/
echo "restart docker to load the new authority"
systemctl daemon-reload
systemctl restart docker
