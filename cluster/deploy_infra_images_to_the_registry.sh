#installing and pushing the images to the registries 
echo "installing origin-infra-v3.9.0.tar"
docker load -i /vagrant/offline/images/origin-infra-v3.9.0.tar

# Override image version, defaults to latest for origin, vX.Y product version for enterprise
#In the registry-console template there's no imagePullPolicy defined then this rules apply
#https://docs.openshift.com/enterprise/3.0/architecture/core_concepts/builds_and_image_streams.html#image-pull-policy). 
#As my tag was latest the imagePullPolicy became "Always" which lead to a risk of ImagePullBackOff if the external
#registry die on workstation 
#echo "retag docker.io/cockpit/kubernetes:latest to workstation.lab.example.com/cockpit/kubernetes:3.9"
#docker tag docker.io/cockpit/kubernetes:latest workstation.lab.example.com/cockpit/kubernetes:3.9

for image in $(docker images --format "{{.Repository}}:{{.Tag}}"); do docker tag $image workstation.lab.example.com/${image#*/}; done
for image in $(docker images --filter=reference='workstation.lab.example.com/*/*' --format "{{.Repository}}:{{.Tag}}"); do docker push $image; done