echo "copie du certificat CA de workstation dans le truststore docker de $(hostname)" 
mkdir -p /etc/docker/certs.d/workstation.lab.example.com
cp /vagrant/offline/conf_to_copy/certs/CA.crt /etc/docker/certs.d/workstation.lab.example.com/
echo "redémarage de docker pour prendre en compte les certificats"
systemctl daemon-reload
systemctl restart docker
