# Hello world in openshift 

The goal of this lab is to make a simple hello world container deployed in openshift. As you're going to see a lot of things are going on under the cover.

This image is going to listen for request and output the value you set in the environment variable content. The world "bouchon" come from the french where "bouchon" means a mock. 

## Build the image  

Review the Dockerfile 
    
    FROM ubuntu:16.04
    EXPOSE 8080
    RUN apt-get update
    RUN apt-get install -y netcat && rm -rf /var/lib/apt/lists/*
    COPY start.sh start.sh
    CMD ["./start.sh"]
	
Review start.sh, it use netcat to act as a basic server 

	#!/bin/sh 
	echo `pwd`
	while true; do nc -l -p 8080 -c 'echo "HTTP/1.1 200 OK\n\n$content"'; done
	
Now from workstation, let's build the image 

	$> cd /vagrant/tp/bouchon 
	$> docker build . -t bouchon
	
Let's test it locally 
    
	$> docker run -d -p 8080:8080 -e content="hello world" --name helloworld bouchon 
	$> curl localhost:8080 # hello world 
	$> docker stop helloworld 
	
## Push this image in openshift 

First we create a project 
   
    $> oc new-project hello-world

We make sure our docker-client see the openshift registry as a secure registry 

    $> sh /vagrant/get_openshift_CAcert.sh
 
And we log to the openshift registry 

    $> sh /vagrant/log_to_the_openshift_registry.sh
   
Retag the the image bouchon and push it 

    $> REGISTRY_HOST=$(oc get route docker-registry -n default --template='{{ .spec.host }}')
    $> docker tag bouchon $REGISTRY_HOST/hello-world/bouchon 
    $> docker push $REGISTRY_HOST/hello-world/bouchon
   
We can see now we have a new image-stream in the project 

    $> oc get is 
    NAME      DOCKER REPO                                            TAGS      UPDATED
    bouchon   docker-registry.default.svc:5000/hello-world/bouchon   latest    10 seconds ago  

## Deploy the image in openshift 
   
Now we are able to deploy this imagestream in openshift 

    $> oc new-app --image-stream=hello-world/bouchon --env=content="Hello World"
    --> Found image 2d4063f (10 minutes old) in image stream "hello-world/bouchon" under tag "latest" for "hello-world/bouchon"
    
        * This image will be deployed in deployment config "bouchon"
        * Port 8080/tcp will be load balanced by service "bouchon"
          * Other containers can access this service through the hostname "bouchon"
        * WARNING: Image "hello-world/bouchon:latest" runs as the 'root' user which may not be permitted by your cluster administrator
    
    --> Creating resources ...
        deploymentconfig "bouchon" created
        service "bouchon" created
    --> Success
        Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
         'oc expose svc/bouchon'
        Run 'oc status' to view your app.
		
Let's see what we have  

    $> oc get all 
	NAME                        REVISION   DESIRED   CURRENT   TRIGGERED BY
    deploymentconfigs/bouchon   1          1         1         config,image(bouchon:latest)
    
    NAME                   DOCKER REPO                                            TAGS      UPDATED
    imagestreams/bouchon   docker-registry.default.svc:5000/hello-world/bouchon   latest    7 minutes ago
    
    NAME                 READY     STATUS    RESTARTS   AGE
    po/bouchon-1-2dgwx   1/1       Running   0          1m
    
    NAME           DESIRED   CURRENT   READY     AGE
    rc/bouchon-1   1         1         1         1m
    
    NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
    svc/bouchon   ClusterIP   172.30.200.187   <none>        8080/TCP   1m
	
We have a lot of thing ! But all are very important and you should spend time in the doc to understand their role 

*  A pod wich is a bit like a container. Try : edit pod bouchon-xxx
*  An image-stream that keep a reference to the to the image in the pod 
*  A deployment-config that watch the image-stream to detect changes, try : oc edit dc bouchon and look at the triggers section
*  A service wich give a unique ip in the cluster to the pod, if a pod is detroyed and recreated the pod ip change but not the service ip nor it's dns name. Beside the service load balance the requests to the pods if you increase the number of pod with the replication controller. Try edit svc bouchon and look at selector
*  A replication controller that make sure the number of pod  expected is the actual try : 
   *   oc scale --replicas=3 dc bouchon 
   *   oc get pods 
   *   oc edit rc bouchon 

## Expose the service 

From the outside world the service is not reachable for instance from workstation 

    $> SERVICE_IP=$(oc get service bouchon --template='{{ .spec.clusterIP }}')
	$> echo "Trying to curl $SERVICE_IP:8080"
    $> curl $SERVICE_IP:8080
	timeout ....
	
But from a node of the cluster, for instance node2 

    $> curl 172.30.200.187:8080 
	Hello world 
	
Thus the service is accessible from the cluster but not from the outer word 

Comeback to workstation and expose the service 

    $> oc expose svc bouchon
    $> oc get all 
	.......
	NAME             HOST/PORT                                       PATH      SERVICES   PORT       TERMINATION   WILDCARD
    routes/bouchon   bouchon-hello-world.cloudapps.lab.example.com             bouchon    8080-tcp                 None
	.......
	
A route has been added let's try it 

    $> curl bouchon-hello-world.cloudapps.lab.example.com
	Hello world
	




	




	

	
