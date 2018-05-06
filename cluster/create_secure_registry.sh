echo "creation de la secure registry workstation.lab.example.com"

echo "installation de l'image registry"
docker load -i /vagrant/offline/images/registry-images.tar

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
  
echo "Ajout des certificats CA sur les noeuds"
ssh root@node1.lab.example.com  'sh /vagrant/get_workstation_CAcert.sh'
ssh root@node2.lab.example.com  'sh /vagrant/get_workstation_CAcert.sh'
ssh root@master.lab.example.com 'sh /vagrant/get_workstation_CAcert.sh'
 

echo "push de cockpit/kubernetes vers la registry workstation"
ssh root@node1.lab.example.com  'sh /vagrant/push_cockpit_vers_workstation.sh'

#Todo gérer une registry complete pour l'install au lieu de préinstaller les images sur les noeuds 
 
 
