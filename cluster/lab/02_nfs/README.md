# NFS Lab

The goal is to realise the shared strorage example described on the redhat site : https://docs.openshift.org/3.9/install_config/storage_examples/shared_storage.html

## Already installed

An nfs mount point is already created during install : review install_nfs_server.sh and install_nfs_client.sh

The user nfsnobody is the owner of the directory /var/nfsshare on the server and /mnt/nfs/share on the client 

## Steps : 
*   Create the project nfs, nfs become automatically your current project 
*   Create a pv : review lab/02_nfs/nfs-pv.yaml then oc create -f  nfs-pv.yaml
*   Check : oc get pv
*   Create a pvc : review lab/02_nfs/nfs-pvc.yaml oc create -f  nfs-pv.yaml
*   Check : oc get pvc (it should be bound)
*   Create an image compatible with open-shift 
	*   cd openshift-nginx
	*   docker build . -t openshift-nginx (you need to be online)
	*   test it : 
	    *   docker run -d -p 8080:8080 --name nginx openshift-nginx 
		*   curl localhost:8080 (you should see <p>If you see this page, the nginx web server is successfully installed ...)	
*   push the image to the internal registry 
    *   if not already done add the openshift registry CA cert in workstation: sh /vagrant/get_openshift_CAcert.sh
	*   make sure you are connected to the registry : sh /vagrant/log_to_the_openshift_registry.sh
	*   review push_nginx_to_openshift_registry.sh 
	*   run it and check : oc get is (you should see one line: openshift-nginx) 
	*   test it 
	    *   deploy it: oc new-app --image-stream=openshift-nginx
		*   expose a route to test it from workstation : oc expose svc openshift-nginx
		*   curl $(oc get route openshift-nginx -n nfs --template='{{ .spec.host }}') (equivalent to : curl openshift-nginx-nfs.cloudapps.lab.example.com, you should see the same message: <p>If you see this page, the nginx web server is successfully installed ...) 
	* cleaning : oc delete all -l app=openshift-nginx it delete the deploymentConfig, route, pod and service but not the is
*   Create a pod that use a pvc 
    *    Review lab/02_nfs/nginx-nfs-pod.yaml
	*    change the value in supplementalGroups: [65534] by the gid of nfsnobody (try the command id nfsnobody)
	*    oc create -f nfs-pv.yaml
	*    Now add a file in the nfs share : echo "<html><body><h1>hello word</h1></body></html>" > /var/nfsshare/index.html
	*    Check what the pod see it in its mount point: oc exec nginx-nfs-pod cat /usr/share/nginx/html/index.html
*   Create the service to expose the pod 
    *    oc create -f /vagrant/lab/02_nfs/nginx-nfs-service.yaml
	*    check the service : oc get endpoints 
	*    check it works anywhere in the cluster :  SERVICE_IP=$(oc get service nginx-nfs-service --template='{{ .spec.clusterIP }}'); ssh root@node1.lab.example.com  "curl $SERVICE_IP:8080" 
	*    expose the service to create a root from outside the cluster: oc expose service nginx-nfs-service
	*    See the complete name of the route : oc get route 
	*    Try it : curl nginx-nfs-service-nfs.cloudapps.lab.example.com
	
## Impovement 

*   Autoprovisionning : try to build your own class

