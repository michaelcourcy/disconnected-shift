echo "Create the secure registry workstation.lab.example.com"

echo "install of the registry:2 image"
docker load -i /vagrant/offline/images/repository-2-images.tar

echo "lancement de la registry sur workstation"
cp -r /vagrant/offline/conf_to_copy/certs /root/
docker run -d \
  --restart=always \
  --name registry \
  -v /root/certs:/certs:z \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
  -p 443:443 \
  registry:2
  
echo "Adding CA certificate on all the nodes"
ssh root@node1.lab.example.com  'sh /vagrant/get_workstation_CAcert.sh'
ssh root@node2.lab.example.com  'sh /vagrant/get_workstation_CAcert.sh'
ssh root@master.lab.example.com 'sh /vagrant/get_workstation_CAcert.sh'
echo "And himself "
sh /vagrant/get_workstation_CAcert.sh

 
 
 
