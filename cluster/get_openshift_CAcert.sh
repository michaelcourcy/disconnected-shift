echo "Installating openshift registry certificate on $(hostname)"
REGISTRY_HOST=$(oc get route docker-registry -n default --template='{{ .spec.host }}')
mkdir -p /etc/docker/certs.d/$REGISTRY_HOST
scp root@master.lab.example.com:/etc/origin/master/ca.crt /etc/docker/certs.d/$REGISTRY_HOST/
echo "restart docker to take in account the certificate"
systemctl daemon-reload
systemctl restart docker
