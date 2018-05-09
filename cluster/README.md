# Cluster

This project build the 4 machines : 
*   Node1 and Node2 which run the containers 
*   Master which manage the etcd database and the master services, this machine is not schedulable
*   Workstation which is not part of the cluster and act as 
       *   dns server 
	   *   Ansible installer 
	   *   TODO external docker registry
	   *   TODO yum repository
	   *   Openshift client
       *   TODO NFS export point for persistent volume on the cluster	   
	   
## Launching the cluster 

1.   Copy oc_base.box from base_machine, if you already did this make sure you delete ~/.vagrant.d/boxes/oc_base directory
2.   Copy offline from base_machine or prepare_offline
3.   vargant up 

## After launching 

From workstation login and check all pods are running properly

    oc login -u admin -p redhat https://master.lab.example.com:8443/"
	oc get pods --all-namespaces

	
To access the console and the *.cloudapps.lab.example application you deploy from the machine that run virtual Box you should add this entry to your hosts file (C:\Windows\System32\drivers\etc\hosts for windows and /etc/hosts for linux). Here is an example taken from my window laptop :

    # The openshift consome can be accessed from the master 
    172.25.250.10 master.lab.example.com
    # All the other routes are reachable from
    # router1 172.25.250.11 or router2 172.25.250.12 indifferently 
    172.25.250.11 registry-console-default.cloudapps.lab.example.com
    172.25.250.12 test-ruby-app.cloudapps.lab.example.com
    172.25.250.11 nginx.cloudapps.lab.example.com
    172.25.250.12 bouchon.cloudapps.lab.example.com
    172.25.250.11 bouchon2.cloudapps.lab.example.com


