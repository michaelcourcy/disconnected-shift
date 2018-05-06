#Creation d'une autoritée auto-signée (il nous faut un point de départ)
openssl genrsa -out CA.key 2048
openssl req -x509 -new -nodes -key CA.key -sha256 -days 1024 -out CA.pem
cp CA.pem CA.crt
#creation d'un certificat registry signé par cette autorité 
openssl genrsa -out registry.key 2048 #creation de la clé à signer
echo "Attention ici bien répondre CN=workstation.lab.example.com"
openssl req -new -key registry.key -out registry.csr #creation de la demande de signature de la clé
openssl x509 -req -in registry.csr -CA CA.pem -CAkey CA.key -CAcreateserial -out registry.crt -days 1024 -sha256 #signature
