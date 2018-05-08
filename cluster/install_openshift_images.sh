echo "Install the openshift origin images"
docker load -i /vagrant/offline/images/origin-v3.9.0-images.tar

# To delete 
#echo "retag des images en latest"
#docker tag docker.io/openshift/origin-docker-registry:v3.7.1 			docker.io/openshift/origin-docker-registry:latest
#docker tag docker.io/openshift/origin-haproxy-router:v3.7.1 			docker.io/openshift/origin-haproxy-router:latest
#docker tag docker.io/openshift/origin-sti-builder:v3.7.1 				docker.io/openshift/origin-sti-builder:latest
#docker tag docker.io/openshift/origin-deployer:v3.7.1 					docker.io/openshift/origin-deployer:latest
#docker tag docker.io/openshift/origin-template-service-broker:v3.7.1 	docker.io/openshift/origin-template-service-broker:latest
#docker tag docker.io/openshift/origin-service-catalog:v3.7.1 			docker.io/openshift/origin-service-catalog:latest
#docker tag docker.io/openshift/origin-pod:v3.7.1 						docker.io/openshift/origin-pod:latest
#docker tag docker.io/openshift/origin-docker-registry:v3.7.1 			docker.io/openshift/origin-docker-registry:latest
#docker tag docker.io/openshift/origin-web-console:v3.7.1 				docker.io/openshift/origin-web-console:latest

echo "retag cockpit otherwise it will be pulled"
docker tag docker.io/cockpit/kubernetes:latest 							docker.io/cockpit/kubernetes:v3.9.0
