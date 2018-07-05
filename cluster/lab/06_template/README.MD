# Building a template 

Template are useful because it describes your architecture and make it reinstallable.

Template are also a special kind of object in openshift. To find more on template go to the doc https://docs.openshift.org/latest/dev_guide/templates.html

We want to build a phpmyadmin+mysql template to allow user who deploy a mysql instance to have also a phpmyadmin IHM to manage the database.

## The starting point 

We are going  to start from a mysql template and change iy. 
From openshift-ansible/roles/openshift_examples/files/examples/v3.9/db-templates copy mysql-ephemeral-template.json.
We work with ephemeral because we don not want to deal with persistent storage in this lab. For this you should read [0_nfs](../0_nfs) or [03_glusterfs](../03_glusterfs).

### Let's study this template 

*  Line 22-40 we build a secret, secret are object that store sensible operation ant that are not easy for other openshift user to read
*  Line 41-68 we have a service, the service expose the pods port, it's the communication point between pod in the cluster, a kind of VIP. We say a service and its backing pods. Here the service only serve the mysql pod. Some interesting point deserve to be noted : 
   *  Line 47 we use a go-template notation : "mysql://{.spec.clusterIP}:{.spec.ports[?(.name==\"mysql\")].port}" it's a request on itself see an explaination on how json structure could be queried using go-template visit this inspiring example : https://gowebexamples.com/templates/ 
   *  Line 54 the port the service listen to if the port in the backing pod is different specify targetPort : https://docs.openshift.org/3.9/architecture/core_concepts/pods_and_services.html#services
   *  Line 60 The label selector identifies all pods with the name=${DATABASE_SERVICE_NAME} label attached as its backing pods
*  Line 70-211 the deployment config of mysql : A deployment config explain to openshift how you deploy a pod, you scale it, you ckeck the pod health, and the rule to redeploy it. This part is big and need to be studied part by part 
   *  Line 80 the strategy, here openshift must destroy and recreate the pod 
   *  Line 83 the triggers what could launch a new roll out : 
         *   Line 85 : a change to image pointed by the imagestream 
		 *   Line 87 : automatic: true is necessary otherwise the trigger is disabled 
         * 	 Line 100 : a config change thus a change on the definition of the deployment config (if you edit or patch it)
   *  Line 103 : the replicas ie how many pod need to be created 
   *  Line 104 : the selector : the same thing for service but for deployment config : the label selector that identifies all pods which are managed by this deployment config
   *  Line 107 : the template, this part explain how we are going to make the pod managed by the deployment config, it's a kind of template in the template
         *   Line 114 we specify how the containers will be built 
		 *   Line 117 notice image is empty, it's because we let the triggers manage it
         *   Line 124 and 132 let the deployment config decide if it should or not consider the pod as dead and redeploy it
         *   Line 139 the env variable we're going to pass to the containers, notice line 150 we can use value coming from the secret
         *   Line 189 is the imagePullPolicy; ifNotPresent is a quite used option, other could be never or always
		 *   Line 197 the volume mount similar to the volume you declare in a dockerfile or in command line 
*  Line 213 to the end : the list of parameters the user will have to provide or accept. What's worth noting is that you can use parameters anywhere you want for instance line 271 we choose the version of mysql.

### Now let's try it 

In a project of your choice run the template  

	 $> oc process mysql-ephemeral -n openshift \
	 -p MYSQL_USER=michael \
	 -p MYSQL_PASSWORD=michael \
	 -p MYSQL_ROOT_PASSWORD=rootmichael \
	 | oc create -f -
	 
Notice that oc process is executed in the openshift project (where this template live) but oc create is executed in the current namespace.

The openshift project is a special project because [some role were added to allow anybody authenticated to see its templates and imagestream](../04_manage_user_and_project).

We want to try it, but the mysql service is only available on a cluster so let's connect to node1
     
	 $> ssh root@node1.lab.example.com
     $>	yum install mysql
     $> mysql -h mysql.mysql.svc -u michael -p
     Enter password:
     Welcome to the MariaDB monitor.  Commands end with ; or \g.
     Your MySQL connection id is 4047
     Server version: 5.7.20 MySQL Community Server (GPL)
     
     Copyright (c) 2000, 2017, Oracle, MariaDB Corporation Ab and others.
     
     Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
     
     MySQL [(none)]> show databases;
     +--------------------+
     | Database           |
     +--------------------+
     | information_schema |
     | sampledb           |
     +--------------------+
     2 rows in set (0.01 sec)

This let you understand how another pod can reach the database, if the pod is in the same project then the FQDN mysql is enough.


## Build a new template by testing the phpmyadmin official image

### Create a phpmyadmin imagestream

Fortunatly there's already a phpmymadmin image let's retrieve it and push it to the internal registry of openshift 

Comeback to workstation.

     $> docker pull phpmyadmin/phpmyadmin
	 #Get the certificate to see the external registry as secure and connect to the registry
     #notice we did the same thing in the lab 	 
	 $> sh /vagrant/get_openshift_CAcert.sh
     $> sh /vagrant/log_to_the_openshift_registry.sh
	 $> REGISTRY_HOST=$(oc get route docker-registry -n default --template='{{ .spec.host }}')
	 $> docker tag phpmyadmin/phpmyadmin $REGISTRY_HOST/openshift/phpmyadmin
	 $> docker push $REGISTRY_HOST/openshift/phpmyadmin	 
	 
That's it ! the phpmyadmin image stream is created inside the openshift namespace.

     $> oc describe -n openshift is phpmyadmin
	 
Reading the documentation we have many env variable available https://docs.phpmyadmin.net/en/latest/setup.html#installing-using-docker.

Especially one :  [PMA_HOST](https://docs.phpmyadmin.net/en/latest/setup.html#envvar-PMA_HOST)

Let's try 

     $> oc new-app --image-stream=openshift/phpmyadmin -e PMA_HOST=mysql
	 --> Found image 4bdc31a (6 days old) in image stream "openshift/phpmyadmin" under tag "latest" for "openshift/phpmyadmin"

         * This image will be deployed in deployment config "phpmyadmin"
         * Ports 80/tcp, 9000/tcp will be load balanced by service "phpmyadmin"
           * Other containers can access this service through the hostname "phpmyadmin"
         * WARNING: Image "openshift/phpmyadmin:latest" runs as the 'root' user which may not be permitted by your cluster administrator
     
     --> Creating resources ...
         imagestreamtag "phpmyadmin:latest" created
         deploymentconfig "phpmyadmin" created
         service "phpmyadmin" created
     --> Success
         Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
          'oc expose svc/phpmyadmin'
         Run 'oc status' to view your app.

But after a while we can see that the deployment fail we have a CrashLoopBackOff on the phpmyadmin pod 

     $> oc get pods
     NAME                  READY     STATUS             RESTARTS   AGE
     mysql-1-vh5sg         1/1       Running            0          5h
     phpmyadmin-1-deploy   1/1       Running            0          33s
     phpmyadmin-1-frd4p    0/1       CrashLoopBackOff   1          27s
	 
Checking the logs we understand the container was built to run as a root in the container : 

     $> oc logs phpmyadmin-1-frd4p
     /run.sh: line 7: can't create /etc/phpmyadmin/config.secret.inc.php: Permission denied
     touch: /etc/phpmyadmin/config.user.inc.php: Permission denied
     mkdir: can't create directory '/var/nginx/': Permission denied
     chown: /sessions: Operation not permitted
     chown: /var/nginx/client_body_temp: No such file or directory
     mkdir: can't create directory '/var/run/php/': Permission denied
     chown: /var/run/php/: No such file or directory
     touch: /var/log/php-fpm.log: Permission denied
     chown: /var/log/php-fpm.log: No such file or directory
     Error: could not read config file /etc/supervisord.conf
     For help, use /usr/bin/supervisord -h


By default, all containers that we try and launch within OpenShift, are set blocked from “RunAsAny” which basically means that they are not allowed to use a root user within the container. This prevents root actions such as chown or chmod from being run and is a sensible security precaution as, should a user be able to perform a local exploit to break out of the container, then they would not be running as root on the underlying container host. . More information [here](https://blog.openshift.com/getting-any-docker-image-running-in-your-own-openshift-cluster/)

The good practice is to fix the image to run with another user but if that's not possible we are going to add a security constraint (or rather we are going to relax a default setting which would normally prohibit containers running as root).

     $> oc adm policy add-scc-to-user anyuid -z default
	 
The -z in the command  indicates that we are going to add a capability to the service account (this is the user that by default is used to run containers within our current namespace – i.e. our project mysql) and the command add the “run as any user” capability, i.e. we are no longer prohibited from running as root.

You can check it with 
    
	 $> oc get scc anyuid -o yaml | grep -B2 -A2 mysql
       type: RunAsAny
     users:
     - system:serviceaccount:mysql:default
     volumes:
     - configMap
     
The default account of the mysql project has “run as any user” capability. Ok it works, but in the perspective of building a template that any project can use this is not handy except if we decide to give anyuid capability to all default service account, and in this case it's a serious tradeoff on security. We'll comeback on this later.

Let's restart the deployment  

     $> oc rollout latest dc/phpmyadmin
	 
After a while things are working fine 

     $> oc get pods
     NAME                 READY     STATUS    RESTARTS   AGE
     mysql-1-vh5sg        1/1       Running   0          6h
     phpmyadmin-2-884fn   1/1       Running   0          14m

Let's add a route 
	 
     $> oc expose service phpmyadmin
     route "phpmyadmin" exposed
     [root@workstation vagrant]# oc get route
     NAME         HOST/PORT                                    PATH      SERVICES     PORT      TERMINATION   WILDCARD
     phpmyadmin   phpmyadmin-mysql.cloudapps.lab.example.com             phpmyadmin   80-tcp                  None

Put the phpmyadmin-mysql.cloudapps.lab.example.com name in your C:\Windows\System32\drivers\etc\hosts file 

     172.25.250.11 phpmyadmin-mysql.cloudapps.lab.example.com
	 
And browse to this address : http://phpmyadmin-mysql.cloudapps.lab.example.com you should be able to connect to your database with michael/michael and you should see the sampledb database which is the default value in the template (Line 260).

### Let's create the template now 

We have nearly everything to build the template. Save mysql-ephemeral-template.json as mysql-ephemeral-and-phpmyadmin-template.json. 
Let's add the missing part to the template, 

The service 

     $> oc get svc phpmyadmin -o json
	 
You have to simplify things because the result give the exact state of the dc in the cluster. Use https://jsonlint.com/ to validate the json.
	 
     {
        "apiVersion": "v1",
        "kind": "Service",
        "metadata": {
		    "annotations": {			    
                "openshift.io/generated-by": "template MySQL And PHPMyAdmin"
            },
            "labels": {
                "app": "phpmyadmin-${DATABASE_SERVICE_NAME}"
            },
            "name": "phpmyadmin-${DATABASE_SERVICE_NAME}"
        },
        "spec": {
            "ports": [
                {
                    "name": "80-tcp",
                    "port": 80,
                    "protocol": "TCP",
                    "targetPort": 80
                },
                {
                    "name": "9000-tcp",
                    "port": 9000,
                    "protocol": "TCP",
                    "targetPort": 9000
                }
            ],
            "selector": {
                "app": "phpmyadmin-${DATABASE_SERVICE_NAME}"                
            }
        }
    }     

add it after the deployment config of the database. 

The deployment config : 

     $> oc get dc phpmyadmin -o json
	 
Simplification need to be handled again 

     {
        "apiVersion": "v1",
        "kind": "DeploymentConfig",
        "metadata": {
            "annotations": {
			    "openshift.io/generated-by": "template MySQL And PHPMyAdmin"
            },
            "name": "phpmyadmin-${DATABASE_SERVICE_NAME}"
        },
        "spec": {
            "replicas": 1,
            "selector": {
                "app": "phpmyadmin-${DATABASE_SERVICE_NAME}"
            },
            "strategy": {
                "type": "Rolling"
            },
            "template": {
                "metadata": {
                    "labels": {
                        "app": "phpmyadmin-${DATABASE_SERVICE_NAME}"                    
                    }
                },
                "spec": {
                    "containers": [
                        {
                            "env": [
                                {
                                    "name": "PMA_HOST",
                                    "value": "${DATABASE_SERVICE_NAME}"
                                }
                            ],
                            "image": " ",
                            "imagePullPolicy": "IfNotPresent",
                            "name": "phpmyadmin-mysql",
                            "ports": [
                                {
                                    "containerPort": 9000,
                                    "protocol": "TCP"
                                },
                                {
                                    "containerPort": 80,
                                    "protocol": "TCP"
                                }
                            ]
                        }
                    ]                
                }
            },
            "triggers": [
                {
                    "type": "ConfigChange"
                },
                {
                    "imageChangeParams": {
					     "automatic": true,
                        "containerNames": [
                            "phpmyadmin-mysql"
                        ],
                        "from": {
                            "kind": "ImageStreamTag",
                            "name": "phpmyadmin:latest",
                            "namespace": "openshift"
                        }                    
                    },
                    "type": "ImageChange"
                }
            ]
        }
    }

add it after the service 

The route 

    $> oc get route phpmyadmin -o yaml
	
Same story for the simplification but note the host field left blank to be defaulted, you may also notice the use of a target port because we send the trafic to a service that has 2 ports 80 and 9000 but we do not want it directed toward 9000.

    {
      "kind": "Route",
      "apiVersion": "v1",
      "metadata": {
	    "openshift.io/generated-by": "template MySQL And PHPMyAdmin",
        "name": "phpmyadmin-${DATABASE_SERVICE_NAME}"
      },
      "spec": 
	  {
	    "host": "",
        "to": {
          "kind": "Service",
          "name": "phpmyadmin-${DATABASE_SERVICE_NAME}"
        },
		"port" : {
			"targetPort": "80-tcp"
		}
      }
    }	

    
All this is gathered in mysql-ephemeral-and-phpmyadmin-template.json 

Install it in the openshift namespace

     $> oc create -f /vagrant/lab/06_template/mysql-ephemeral-and-phpmyadmin-template.json -n openshift 
     $> oc get template -n openshift | grep phpmyadmin
     mysql-phpmyadmin-ephemeral    MySQL database service, without persistent storage with an associated phpmyad...   8 (3 generated)   6
	 

### Use the new template 

first to avoid confusion we're going to clean the already created object in the project mysql 

     $> oc delete route --all
     $> oc delete svc --all
     $> oc delete dc --all     
	 $> oc delete secret mysql
	 
Note that when you deletes the deployment config (dc) you automatically delete the pod and replication controller associated.

Now we are able to use the new template : 

     $> oc process mysql-phpmyadmin-ephemeral -n openshift \
	 -p MYSQL_USER=michael \
	 -p MYSQL_PASSWORD=michael \
	 -p MYSQL_ROOT_PASSWORD=rootmichael \
	 | oc create -f - 
	 
Put the phpmyadmin-mysql-mysql.cloudapps.lab.example.com name in your C:\Windows\System32\drivers\etc\hosts file because the default route is <service_name>-<project-name>.cloudapps.lab.example.com thus phpmyadmin-${DATABASE_SERVICE_NAME}-mysql.cloudapps.lab.example.com 

It's now really easy to create another mysql database with it's phpmyadmin IHM 

     $> oc process mysql-phpmyadmin-ephemeral -n openshift \
	 -p DATABASE_SERVICE_NAME=otherdb \
	 -p MYSQL_DATABASE=othersample
	 -p MYSQL_USER=otheruser \
	 -p MYSQL_PASSWORD=otheruser \
	 -p MYSQL_ROOT_PASSWORD=rootmichael \
	 | oc create -f -
	 
Put the phpmyadmin-otherdb-mysql.cloudapps.lab.example.com name in your C:\Windows\System32\drivers\etc\hosts file, browse to http://phpmyadmin-otherdb-mysql.cloudapps.lab.example.com/index.php and check you have the right credential and the right databases.


## Improvement 

### Custom icon for the template

#### Use a provided icon

How to manage icon is described here https://docs.openshift.org/latest/dev_guide/templates.html#writing-templates.

The simplest way is choosing among this list of icons : 
*   https://rawgit.com/openshift/openshift-logos-icon/master/demo.html
*   http://fontawesome.io/icons/
*   https://www.patternfly.org/styles/icons/

Then you simply change the value of the icon, pficon-storage-domain is a database with a magnifier, so it's a good choice for the objective we have

We change the value of the icon class in the template.

      "metadata": {
        "name": "mysql-phpmyadmin-ephemeral",
        "annotations": {
          ....
          "iconClass": "pficon-storage-domain",
          .....
        }
      },
	  
Let's understand hos it works. 

If you look the content of main.css you notice line 3020 the pficon selector choose the font : 

    [class*=" pficon-"],[class^=pficon-]
	{ ...   
      font-family:PatternFlyIcons-webfont;
	  font-style:normal;
	  font-variant:normal;
	  font-weight:400;
	  line-height:1;
	}
	
Then the pficon-storage-domain pseudo selector ::before choose a letter inside the font 

    .pficon-storage-domain:before{content:"\e90e"}
	
Notice the unicode character e90e is a [private use codepoint](https://codepoints.net/U+E90E), which avoid bugging with "real" character.
	

#### Use your own icon 

Let's say you want to use this logo https://upload.wikimedia.org/wikipedia/commons/4/4f/PhpMyAdmin_logo.svg 

You have to reference the icon class in the template 

      "metadata": {
        "name": "mysql-phpmyadmin-ephemeral",
        "annotations": {
          ....
          "iconClass": "phpmyadmin-logo",
          .....
        }
      },


Which will generate this span 

	  <span class="phpmyadmin-logo"></span>
	  
We may try to use the solution with the font with a font generator like the [icomoon app](https://icomoon.io/app/#/select), but the simplest way of doing it is to 
specify a background-image in a css we provide : disconnected.css and our own image 

We're going to host this svg and the css in the [disconnected-content builder project we did](../05_builder).

First let's update the alice git directory on the window host 

     $> cd /d/projets/OC/disconnected/alice
	 
Create the file disconnected.css
     
	 span.phpmyadmin-logo{
	   display:inline-block;
	   width: 100%;
	   height: 100%;
	   background-size: contain;
	   background:  url(PhpMyAdmin_logo.svg) no-repeat center;
	 }
	 
Copy the logo you can find here  
	 
	 https://upload.wikimedia.org/wikipedia/commons/4/4f/PhpMyAdmin_logo.svg
	 

Commit and push your change	 

	 $> git add .
	 $> git commit -m "Adding css and logo for custom logo template"
	 $> git push origin master

Let's comeback to workstation and restart the build on the project disconnected-content

     $> oc start-build disconnected-content

This will recreate the images with new contents. Check the content is properly served in https

     $> curl -k https://static-disconnected-content.cloudapps.lab.example.com/disconnected.css
	 $> curl -k https://static-disconnected-content.cloudapps.lab.example.com/PhpMyAdmin_logo.svg

The webconsole has to load this css now. In the openshift-webconsole namespace there's a configmap we can use to add [css and javascript file](https://docs.openshift.org/3.9/install_config/web_console_customization.html ) 

    $ oc edit configmap/webconsole-config -n openshift-web-console
	
And add the css file https://static-disconnected-content.cloudapps.lab.example.com/disconnected.css in the stylesheetURLs array 


     ....
	 extensions:
      properties: {}
      scriptURLs: []
      stylesheetURLs: ["https://static-disconnected-content.cloudapps.lab.example.com/disconnected.css"]
     features:
	 ....
    
After saving the ConfigMap, the web console containers will be updated automatically for the new extension files within a few minutes.	

Now the logo appear in the catalog.



## Improvement to do

*   Allow the user to choose another route name 
*   Make the route secure (https)
*   Manage persistence on the database

	 

	




 
 

		 

   
