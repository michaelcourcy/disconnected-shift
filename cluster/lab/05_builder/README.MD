# What a builder 

Todo 

# Making a simple build with nginx s2i

##First create a simple git repository working with ssh 

### Create a user disconnected in workstation able to connect to the server with a key and able to work with the repository 

This part of the lab is inspired by this [documentation on git](https://git-scm.com/book/en/v1/Git-on-the-Server-Setting-Up-the-Server).

Create two different users able to connect as disconnected

	cd /vagrant/lab/05_builder/ssh_keys/
	ssh-keygen -t rsa -b 4096 -C "alice@disconnected" -f ./alice_rsa -P ""
	ssh-keygen -t rsa -b 4096 -C "john@disconnected" -f ./john_rsa -P ""
	useradd -m -d /home/disconnected -s /bin/bash disconnected
	mkdir /home/disconnected/.ssh
    cat /vagrant/lab/05_builder/ssh_keys/alice_rsa.pub >> /home/disconnected/.ssh/authorized_keys
    cat /vagrant/lab/05_builder/ssh_keys/john_rsa.pub >> /home/disconnected/.ssh/authorized_keys
	chown -R disconnected:disconnected /home/disconnected/.ssh
    chmod 700 /home/disconnected/.ssh
    chmod 600 /home/disconnected/.ssh/authorized_keys
	
### test you can connect from anywhere with this key, for clarity we keep the prompt in the command to help you seeing on which node the commands are executed
    
	[root@workstation ssh_keys]# ssh node1.lab.example.com
    Last login: Sun Jun 24 19:24:01 2018 from 172.25.250.254
    [root@node1 ~]# ssh disconnected@workstation.lab.example.com -i /vagrant/lab/05_builder/ssh_keys/alice_rsa
    Last failed login: Sun Jun 24 19:21:28 CEST 2018 from 172.25.250.11 on ssh:notty
    There were 2 failed login attempts since the last successful login.
    [disconnected@workstation ~]$ 
	
You can also try it from your window host with a ssh client.
	
### Create a bare repo in workstation 

comeback to workstation (execute exit twice)
    
	su disconnected
	cd
	mkdir disconnected-content.git
	cd disconnected-content.git
	git --bare init 
    
	
### From a user add inital content to the repository, from another one change some of the content 

From your window host, create a john and an alice directory and clone/commit change like two developpers working together.

> This action need a git version greater or equal to 2.10.0 and I use git bash for windows for this command

    
    $>cd /d/projets/OC/
    $>mkdir -p disconnected/{john,alice}
    $>cd disconnected/john/
    $>git init
    Initialized empty Git repository in D:/projets/OC/disconnected/john/.git/
	$>git config user.name "John"
	$>git config user.email "john@disconnected"
	$>echo "<html><body>Hello world</body></html>" > index.html
    $>git add .
    $>git commit -m "initial commit"
    $>git config core.sshCommand "ssh -i /e/openshift/cluster/lab/05_builder/ssh_keys/john_rsa -F /dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
	$>git remote add origin disconnected@172.25.250.254:/home/disconnected/disconnected-content.git
	$>git push origin master
	
Now use alice to clone and push a change 

    $>cd /d/projets/OC/disconnected/alice
	$>GIT_SSH_COMMAND='ssh -i /e/openshift/cluster/lab/05_builder/ssh_keys/alice_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone disconnected@172.25.250.254:/home/disconnected/disconnected-content.git
	$>cd disconnected-content/
	$>git config core.sshCommand "ssh -i /e/openshift/cluster/lab/05_builder/ssh_keys/alice_rsa -F /dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
	$>git config user.name "Alice"
	$>git config user.email "alice@disconnected"
	$>vi index.html
    $>git add .
    $>git commit -m "index modified"
    $>git push origin master
	
Now comeback 

	
    
    
