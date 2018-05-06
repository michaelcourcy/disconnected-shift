#echo "on cree les latest sur le numéro le plus élevé"
#docker tag docker.io/openshift/origin-docker-registry:v3.7.2 docker.io/openshift/origin-docker-registry:latest
#docker tag docker.io/openshift/origin-haproxy-router:v3.8.0 docker.io/openshift/origin-haproxy-router:latest
#docker tag docker.io/openshift/origin-sti-builder:v3.8.0 docker.io/openshift/origin-sti-builder:latest
#docker tag docker.io/openshift/origin-deployer:v3.8.0 docker.io/openshift/origin-deployer:latest
#docker tag docker.io/openshift/origin-template-service-broker:v3.8.0 docker.io/openshift/origin-template-service-broker:latest
#docker tag docker.io/openshift/origin-service-catalog:v3.8.0 docker.io/openshift/origin-service-catalog:latest
#docker tag docker.io/openshift/origin-pod:v3.8.0 docker.io/openshift/origin-pod:latest
#docker tag docker.io/openshift/origin-web-console:v3.8.0 docker.io/openshift/origin-web-console:latest
#docker tag docker.io/ansibleplaybookbundle/origin-ansible-service-broker:v3.9 docker.io/ansibleplaybookbundle/origin-ansible-service-broker:latest


docker save -o /offline/images/origin-images.tar \
docker.io/centos/ruby-24-centos7:latest \
docker.io/centos/ruby-22-centos7:latest \
docker.io/centos/php-70-centos7:latest \
docker.io/centos/mysql-57-centos7:latest \
docker.io/openshift/jenkins-2-centos7:latest \
docker.io/cockpit/kubernetes:latest \
docker.io/openshift/origin-docker-registry:v3.7.1 \
docker.io/openshift/origin-haproxy-router:v3.7.1 \
docker.io/openshift/origin-sti-builder:v3.7.1 \
docker.io/openshift/origin-deployer:v3.7.1 \
docker.io/openshift/origin-template-service-broker:v3.7.1 \
docker.io/openshift/origin-service-catalog:v3.7.1 \
docker.io/openshift/origin-pod:v3.7.1 \
docker.io/openshift/origin-docker-registry:v3.7.1 \
docker.io/openshift/origin-web-console:v3.7.1 

chmod 777 /offline/images/origin-images.tar

docker save -o /offline/images/registry-images.tar \
docker.io/registry:2

chmod 777 /offline/images/registry-images.tar