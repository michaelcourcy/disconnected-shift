cd /vagrant/offline/conf_to_copy/certs
rm -f *
echo "Create an authorithy auto-signed (we need a starting point)"
openssl genrsa -out CA.key 2048
openssl req -x509 -new -nodes -key CA.key -sha256 -subj '/CN=almighty.lab.example.com/O=SopraSteria/C=FR' -days 1024 -out CA.crt
echo "create a signed certificate for the registry signed by this authority" 
openssl genrsa -out registry.key 2048 #create the key to be signed
openssl req -new -key registry.key -subj '/CN=workstation.lab.example.com/O=SopraSteria/C=FR' -out registry.csr #Create the signature request 
openssl x509 -req -in registry.csr -CA CA.crt -CAkey CA.key -CAcreateserial -out registry.crt -days 1024 -sha256 #authority sign the request 
