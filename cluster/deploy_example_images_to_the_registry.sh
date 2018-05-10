echo "cleaning the previous images to get free spaces except the running"
docker system prune -a -f

for example in "dotnet httpd jenkins mariadb mongodb mysql nginx nodejs perl php postgresql python redis ruby wildfly"
do
	echo "installing example $example"
	docker load -i /vagrant/offline/images/origin-example-$example.tar
done
	
	
for image in $(docker images --format "{{.Repository}}:{{.Tag}}"); do docker tag $image workstation.lab.example.com/${image#*/}; done
for image in $(docker images --filter=reference='workstation.lab.example.com/*/*' --format "{{.Repository}}:{{.Tag}}"); do docker push $image; done