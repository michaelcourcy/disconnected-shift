# Cluster

This project build the 4 machines : 
*   Node1 and Node2 which run the containers 
*   Master which manage the etcd database and the master api services, this machine is not schedulable
*   Workstation which is not part of the cluster and act as 
       *   Dns server 
	   *   Ansible installer 
	   *   External docker registry
	   *   yum repository
	   *   Openshift client 
	   
## Launching the cluster 

1.   Copy oc_base.box from base_machine to cluster directory. If you already did this make sure you delete ~/.vagrant.d/boxes/oc_base directory, the first time you run it vagrant will unarchive ./oc_base.box to ~/.vagrant.d/boxes/oc_base and use that and not ./oc_base.box file anymore. 
2.   Copy offline directory (wich contains all the assets) from base_machine or prepare_offline to the cluster directory 

Here is how your diectory should look like before launching `vagrant up`

```
.
|-- README.md
|-- Vagrantfile
|-- check_dns.sh
|-- configure_dhcp.sh
|-- connection_admin.sh
|-- create_openshift_admin.sh
|-- create_secure_registry.sh
|-- deploy_example_images_to_the_registry.sh
|-- deploy_infra_images_to_the_registry.sh
|-- deploy_keys.sh
|-- disable_firewall.sh
|-- generate_certificate_for_external_registry.sh
|-- get_openshift_CAcert.sh
|-- get_workstation_CAcert.sh
|-- install_ansible_and_cluster.sh
|-- install_dns.sh
|-- install_nfs_client.sh
|-- install_nfs_server.sh
|-- log_to_the_openshift_registry.sh
|-- make_cluster_alias.sh
|-- oc_base.box
|-- offline
|   |-- conf_to_copy
|   |-- images
|   `-- repos
|-- pull_and_save_images.sh
`-- remove_hostname_entry_in_hosts.sh
```

3. Run 
    
    cd cluster
    vagrant up 

## After launching 

From workstation login and check all pods are running properly

    vagrant ssh workstation 
    $> oc login -u admin -p redhat https://master.lab.example.com:8443/"
	$> oc get pods --all-namespaces

	
## DNS Resolution 

To access the console and the *.cloudapps.lab.example application you deploy from the machine that run virtual Box you should add this entry to your hosts file (C:\Windows\System32\drivers\etc\hosts for windows and /etc/hosts for linux). Here is an example taken from my window laptop :

    # The web console can be accessed from the master 
    172.25.250.10 master.lab.example.com
    # All the other routes are reachable from
    # router1 172.25.250.11 or router2 172.25.250.12 indifferently     
    172.25.250.11 registry-console-default.cloudapps.lab.example.com
    172.25.250.12 test-ruby-app.cloudapps.lab.example.com
    172.25.250.11 nginx.cloudapps.lab.example.com
    172.25.250.12 bouchon.cloudapps.lab.example.com
    172.25.250.11 bouchon2.cloudapps.lab.example.com

An alternative is to change temporary the ip of your dns server to the workstation one 172.25.250.254 so you won't have change your hosts file.

