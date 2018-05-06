echo "Installation des certificats de la registry openshift sur $(hostname)"
REGISTRY_HOST=$(oc get route docker-registry -n default --template='{{ .spec.host }}')
mkdir -p /etc/docker/certs.d/$REGISTRY_HOST
scp root@master.lab.example.com:/etc/origin/master/ca.crt /etc/docker/certs.d/$REGISTRY_HOST/
echo "redémarage de docker pour prendre en compte les certificats"
systemctl daemon-reload
systemctl restart docker
