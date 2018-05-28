# Gluster FS LAB

The goal is to realise dynamic volume provisionning with glusterfs and heketi it's directly inspired from https://medium.com/@wilson.wilson/install-heketi-and-glusterfs-with-openshift-to-allow-dynamic-persistent-volume-management-89156340b2bd

## Install glusterfs on each node 

Execute this actions on the 3 nodes master node1 and node2 

### Create the gluster device 

We do not want to use lvm to create a new partition or to add another disk for this tutorial we're going to use a loop device (https://en.wikipedia.org/wiki/Loop_device)

Create a loop device of 5gb : 

     dd if=/dev/zero of=/var/glusterdisk bs=1G count=5
	 losetup /dev/loop0 /var/glusterdisk
	 #check the device is attached 
	 losetup -a #you should see something like /dev/loop0: [64768]:101059834 (/var/glusterdisk)
	 #execute this at every reboot 
	 chmod u+x /etc/rc.d/rc.local
	 systemctl start rc-local
	 systemctl enable rc-local
	 echo "losetup /dev/loop0 /var/glusterdisk" >> /etc/rc.d/rc.local
	 
Add them to lvm, this install is very very fragile you should use a real disk instead of a loopback

	pvcreate /dev/loop0
	vgcreate vggluster /dev/loop0
	lvcreate -L 4G -n lvgluster  vggluster
	
Hence the logical volume created is /dev/vggluster/lvgluster
	 
### Install gluster fs 

     yum search centos-release-gluster
	 yum install centos-release-gluster310
	 yum install glusterfs-server
	 systemctl start glusterd
	 systemctl enable glusterd
	 #Allow write on mounted GlusterFS volume with SELinux
	 setsebool -P virt_sandbox_use_fusefs on
	 
## Install heketi on master 

This action must be done on  master 

     cd /vagrant/lab/03_glusterfs/rpms/
	 
download heketi-cli and heketi-server from epel (I'm not completly offline ...) 

	 wget http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/h/heketi-client-5.0.1-1.el7.x86_64.rpm
	 wget http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/h/heketi-5.0.1-1.el7.x86_64.rpm

Install the rpm

	 rpm -Uvh heketi-5.0.1-1.el7.x86_64.rpm
     rpm -Uvh heketi-client-5.0.1-1.el7.x86_64.rpm

master must be able to connect to node1 and node2 with a ssh-key that will be used also by heketi 

	 ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
	 ssh-copy-id -o StrictHostKeyChecking=no root@node1.lab.example.com
	 ssh-copy-id -o StrictHostKeyChecking=no root@node2.lab.example.com
	 #I have a doubt on this one :=|
	 ssh-copy-id -o StrictHostKeyChecking=no root@master.lab.example.com
	 cp /root/.ssh/id_rsa /etc/heketi/heketi_key
	 chown heketi: /etc/heketi/heketi_key
	 
Edit /etc/heketi/heketi.json config file 
	 
	 {
       "_port_comment": "Heketi Server Port Number",
       "port": "8080",
       "_use_auth": "Enable JWT authorization. Please enable for deployment",
       "use_auth": true,
       "_jwt": "Private keys for access",
       "jwt": {
        "_admin": "HeketiAdmin",
        "admin": {
         "key": "HeketiAdminPassword"
        },
        "_user": "HeketiUser",
        "user": {
         "key": "HeketiUserPassword"
        }
       },
       "_glusterfs_comment": "GlusterFS Configuration",
       "glusterfs": {
        "executor": "ssh",
        "sshexec": {
          "keyfile": "/etc/heketi/heketi_key",
          "user": "root",
          "port": "22",
          "fstab": "/etc/fstab"
        }
       },
       "_db_comment": "Database file name",
       "db": "/var/lib/heketi/heketi.db",
       "loglevel" : "debug"
       }
     }
	 

Create the GlusterFS Cluster topology in file /usr/share/heketi/topology-sample.json


    {
        "clusters": [
            {
                "nodes": [
                    {
                        "node": {
                            "hostnames": {
                                "manage": [
                                    "172.25.250.10"
                                ],
                                "storage": [
                                    "172.25.250.10"
                                ]
                            },
                            "zone": 1
                        },
                        "devices": [
                            "/dev/vggluster/lvgluster"
                        ]
                    },
                    {
                        "node": {
                            "hostnames": {
                                "manage": [
                                    "172.25.250.11"
                                ],
                                "storage": [
                                    "172.25.250.11"
                                ]
                            },
                            "zone": 1
                        },
                        "devices": [
                            "/dev/vggluster/lvgluster"
                        ]
                    },
                    {
                        "node": {
                            "hostnames": {
                                "manage": [
                                    "172.25.250.12"
                                ],
                                "storage": [
                                    "172.25.250.12"
                                ]
                            },
                            "zone": 1
                        },
                        "devices": [
                            "/dev/vggluster/lvgluster"
                        ]
                    }                    
                ]
            }
        ]
    }
	
Start Heketi 

    #launch the service
    systemctl start heketi
	#Load topology json file
	heketi-cli --user=admin --secret HeketiAdminPassword  topology load  --json=/usr/share/heketi/topology-sample.json

The command list that all the device on each node that had been added, man heketi-cli is very useful 

Now check the cluster you created

	heketi-cli --user=admin --secret HeketiAdminPassword cluster list
	heketi-cli --user=admin --secret HeketiAdminPassword cluster info <Cluster ID obtained from list>
	
Enable and restart Heketi

    systemctl enable heketi
	systemctl restart heketi
	
Check if Heketi is responding

    curl http://master.lab.example.com:8080/hello 
	Hello from Heketi
	
## Connect Openshift with Heketi

__This operation must be done also on the master 

Review the file StorageClass_Heketi.yml 

    kind: StorageClass  
    apiVersion: storage.k8s.io/v1
    metadata:
      name: heketi  
    provisioner: kubernetes.io/glusterfs   
    parameters:
      resturl: "http://master.lab.example.com:8080"  
      restuser: "admin"  
      restuserkey: "HeketiAdminPassword"

create the object from the file 

    oc create -f /vagrant/lab/03_glusterfs/StorageClass_Heketi.yml
	#check the sc (storage class) has been properly created
	#note this command is global and do not depend on the project you are
    oc get sc
	
__Now you can comeback on  workstation 

Create a new project 
    
	oc new-project test 
	#you are automatically on the new project test
	
Create a PVC : review PVC_Heketi.yml using the StorageCLass

    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: gluster1
    spec:
      accessModes:
        - ReadWriteMany
      resources:
        requests:
          storage: 1Gi
      storageClassName: heketi
	  
Create the pvc from the file

	oc create -f /vagrant/lab/03_glusterfs/PVC_Heketi.yml
	
You should see that it has been automatically provisionned without the need to create a PV before like in the lab nfs

    [root@workstation vagrant]# oc get pvc
    NAME       STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    gluster1   Bound     pvc-418e8a33-61f3-11e8-abe5-08002776f3cf   1Gi        RWX            heketi         23s
	
Check the existing pv you can see that it has the exact name of the gluster volume created


    [root@workstation vagrant]# oc get pv
    NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM           STORAGECLASS   REASON    AGE
    nfs-pv                                     1Gi        RWX            Retain           Released   test/nfs-pvc                             14d
    pvc-418e8a33-61f3-11e8-abe5-08002776f3cf   1Gi        RWX            Delete           Bound      test/gluster1   heketi                   3m


    


    

    
	
	
	