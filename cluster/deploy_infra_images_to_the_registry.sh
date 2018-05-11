#installing and pushing the images to the registries 
echo "installing origin-v3.9.0-images.tar"
docker load -i /vagrant/offline/images/origin-infra-v3.9.0.tar

for image in $(docker images --format "{{.Repository}}:{{.Tag}}"); do docker tag $image workstation.lab.example.com/${image#*/}; done
for image in $(docker images --filter=reference='workstation.lab.example.com/*/*' --format "{{.Repository}}:{{.Tag}}"); do docker push $image; done