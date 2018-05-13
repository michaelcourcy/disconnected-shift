echo "Copy Ca cetificate on $(hostname)" 

#We add it also at the level system to have api trusting it 
cp /vagrant/offline/conf_to_copy/certs/CA.crt /etc/pki/tls/certs/workstationCA.crt
update-ca-trust

#We add it in docker to have docker client trust it
mkdir -p /etc/docker/certs.d/workstation.lab.example.com
cp /vagrant/offline/conf_to_copy/certs/CA.crt /etc/docker/certs.d/workstation.lab.example.com/
echo "restart docker to load the new authority"
systemctl daemon-reload
systemctl restart docker
