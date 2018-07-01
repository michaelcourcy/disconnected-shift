# What a builder 

Todo 

# Making a simple build with nginx s2i

This lab is inspired by this [documentation on git](https://git-scm.com/book/en/v1/Git-on-the-Server-Setting-Up-the-Server) and by this blog post on [Private Git Repositories: Part 2B – Repository SSH Keys](https://blog.openshift.com/private-git-repositories-part-2b-repository-ssh-keys/).

##First create a simple git repository working with ssh 

### Create a user disconnected in workstation able to connect to the server with a key and able to work with the repository

	useradd -m -d /home/disconnectedgit -s /bin/bash disconnectedgit
	mkdir /home/disconnectedgit/.ssh 

Create a user able to connect as disconnectedgit

	cd /vagrant/lab/05_builder/ssh_keys/
	ssh-keygen -t rsa -b 4096 -C "alice@disconnectedgit" -f ./alice_rsa -P ""
	cat /vagrant/lab/05_builder/ssh_keys/alice_rsa.pub >> /home/disconnectedgit/.ssh/authorized_keys
    chown -R disconnectedgit:disconnectedgit /home/disconnectedgit/.ssh
    chmod 700 /home/disconnectedgit/.ssh
    chmod 600 /home/disconnectedgit/.ssh/authorized_keys
	
### test you can connect alice from anywhere with her key

In this case we made the test from node1 but it could have been node2, master or even your window host.    
	
	[root@workstation ssh_keys]# ssh node1.lab.example.com
    Last login: Sun Jun 24 19:24:01 2018 from 172.25.250.254
    [root@node1 ~]# ssh disconnectedgit@workstation.lab.example.com -i /vagrant/lab/05_builder/ssh_keys/alice_rsa
    Last failed login: Sun Jun 24 19:21:28 CEST 2018 from 172.25.250.11 on ssh:notty
    There were 2 failed login attempts since the last successful login.
    [disconnectedgit@workstation ~]$ 
	
	
### Create a bare repo in workstation 

comeback to workstation 
    
	su disconnectedgit
	cd
	mkdir disconnected-content.git
	cd disconnected-content.git
	git --bare init 
    
	
	
### Now let puts "things" inside this repo

The following actions are done from your window host with git-bash.

Create a alice directory commit change and push them to the distant repository

    $>cd /d/projets/OC/ #or whatever repository 
    $>mkdir -p disconnected/alice
    $>cd disconnected/alice/
    $>git init
    Initialized empty Git repository in D:/projets/OC/disconnected/john/.git/
	$>git config user.name "Alice"
	$>git config user.email "alice@disconnectedgit"
	$>echo "<html><body>Hello world</body></html>" > index.html
    $>git add .
    $>git commit -m "initial commit"
	
configure git to use the alice key to connect to the remote repository

    $>cd 
    $>cat <<EOF >> ~/.ssh/config
    Host discogit
       Hostname 172.25.250.254
       IdentityFile /e/openshift/cluster/lab/05_builder/ssh_keys/alice_rsa
       User disconnectedgit
	   
    EOF	
	$>cd /d/projets/OC/disconnected/alice
	$>git remote add origin discogit:disconnected-content.git
	$>git push origin master
	
	
##Build the first Source to image 

A build in OpenShift Origin is the process of transforming input parameters into a resulting object. Most often, builds are used to transform source code into a runnable container image.

And it's what we're going to do by building an nginx image that use the code in the repository.

Comeback to workstation and create a new project disconnected-content 

   $>oc new-project disconnected-content
   
Notice that openshift create for you 3 service accounts 

    $>oc get sa
    NAME       SECRETS   AGE
    builder    2         3d
    default    2         3d
    deployer   2         3d
	
When we launch a build we use the builder account. 

The builder account need to connect to the git repo we previously created and for that need to use the alice key.

Thus we create a secret with the ssh key of alice and we link it to the builder service account 

    $>oc create secret generic alice-secret --from-file=ssh-privatekey=/vagrant/lab/05_builder/ssh_keys/alice_rsa --type=kubernetes.io/ssh-auth
    secret "alice-secret" created
	$>oc secrets link builder alice-secret
	$>oc new-app workstation.lab.example.com/centos/nginx-112-centos7:latest~disconnectedgit@workstation.lab.example.com:disconnected-content.git


Let's see how thinks worked 

    oc logs -f bc/disconnected-content
    Cloning "disconnectedgit@workstation.lab.example.com:disconnected-content.git" ...
    error: Host key verification failed.
    fatal: Could not read from remote repository.
    Please make sure you have the correct access rights
    and the repository exists.
    
This is because it is a private Git repository, and although we created the secret holding the private key for accessing the repository, we didn’t tell OpenShift to use it for this build.

    oc set build-secret --source bc/disconnected-content alice-secret

And then relaunch the build 

    oc start-build disconnected-content 
    oc logs -f bc/disconnected-content
    Cloning "disconnectedgit@workstation.lab.example.com:disconnected-content.git" ...
            Commit: 38709db5d6016d72fc427ef10175d8a227f43924 (index modified)
            Author: Alice <alice@disconnectedgit>
            Date:   Thu Jun 28 09:24:46 2018 +0200
    ---> Installing application source
    ---> Copying nginx start-hook scripts...
    Pushing image docker-registry.default.svc:5000/disconnected-content2/disconnected-content:latest ...
    Pushed 0/9 layers, 1% complete
    Pushed 1/9 layers, 13% complete
    Pushed 2/9 layers, 25% complete
    Pushed 3/9 layers, 35% complete
    Pushed 4/9 layers, 45% complete
    Pushed 5/9 layers, 58% complete
    Pushed 6/9 layers, 69% complete
    Pushed 7/9 layers, 82% complete
    Pushed 8/9 layers, 93% complete
    Pushed 9/9 layers, 100% complete
    Push successful

To finish the job we are going now to add a route so we can reach the new application from the outside

    oc expose svc/disconnected-content
    oc get route
    NAME                   HOST/PORT                                                              PATH      SERVICES               PORT           TERMINATION   WILDCARD
    disconnected-content   disconnected-content-disconnected-content.cloudapps.lab.example.com             disconnected-content       8080-tcp                 None
    curl http://disconnected-content-disconnected-content.cloudapps.lab.example.com
    <html><body>Hello world!</body></html>

Notice that the route is really not nice disconnected-content-disconnected-content.... We change it 

    oc delete route disconnected-content
    oc expose svc/disconnected-content --hostname=static-disconnected-content.cloudapps.lab.example.com
    curl http://static-disconnected-content.cloudapps.lab.example.com
    <html><body>Hello world!</body></html>

### Understand the flow of action 

if you run oc get all you see a bunch of things 

    oc get all
    NAME                                     REVISION   DESIRED   CURRENT   TRIGGERED BY
    deploymentconfigs/disconnected-content   1          1         1         config,image(disconnected-content:latest)
    
    NAME                                TYPE      FROM      LATEST
    buildconfigs/disconnected-content   Source    Git       2
    
    NAME                            TYPE      FROM          STATUS                       STARTED          DURATION
    builds/disconnected-content-1   Source    Git           Failed (FetchSourceFailed)   27 minutes ago   5s
    builds/disconnected-content-2   Source    Git@38709db   Complete                     16 minutes ago   1m5s
    
    NAME                                DOCKER REPO                                                                   TAGS      UPDATED
    imagestreams/disconnected-content   docker-registry.default.svc:5000/disconnected-content2/disconnected-content   latest    14     minutes ago
    imagestreams/nginx-112-centos7      docker-registry.default.svc:5000/disconnected-content2/nginx-112-centos7      latest    29     minutes ago
    
    NAME                          HOST/PORT                                               PATH      SERVICES               PORT           TERMINATION   WILDCARD
    routes/disconnected-content   static-disconnected-content.cloudapps.lab.example.com             disconnected-content   8080-tcp                     None
    
    NAME                              READY     STATUS       RESTARTS   AGE
    po/disconnected-content-1-build   0/1       Init:Error   0          27m
    po/disconnected-content-1-kggnl   1/1       Running      0          14m
    po/disconnected-content-2-build   0/1       Completed    0          16m
    
    NAME                        DESIRED   CURRENT   READY     AGE
    rc/disconnected-content-1   1         1         1         14m
    
    NAME                       TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)             AGE
    svc/disconnected-content   ClusterIP   172.30.2.116   <none>        8080/TCP,8443/TCP   27m

The command 

    oc new-app workstation.lab.example.com/centos/nginx-112-centos7:latest~disconnectedgit@workstation.lab.example.com:disconnected-content.git

Create a bunch of thing in this order : 

* An image stream will be created as "nginx-112-centos7:latest" that will track the source image 
* A buildConfig with different triggers (see the triggers definition), especially one based on the image stream previously created. A buildConfig is similar to job in jenkins, every time a job is executed it's a build. As we change and re-rerun twice the buildconfig we can see two builds. For one buildconfig you may have many builds.
* The buildConfig is executed and it create a build using source code from disconnectedgit@workstation.lab.example.com:disconnected-content.git plus the S2I image in the 
* The resulting image will be pushed to image stream "disconnected-content:latest"
* A deployment config "disconnected-content" based on the image stream  disconnected-content:latest
* A service "disconnected-content"

This is the "new-app" way by making the best guess, but you can write a complete template to do all this things explicitly. If you want an example of this have a look to the nginx-example template. 
 
 ### TODO 

 *  Error if instead of using the nginx image coming from the workstation registry we use image coming from the internal registry
 *  Annotating the Secret with the Repository : the rest of this tutorial fail, we should open an issue
 *  Manage a hook to restart the buils as soon as the code change
 
    



	
    
    
