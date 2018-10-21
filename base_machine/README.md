# base machine

The goal is to produce the oc_base.box that will be used as a base for cloning all the machine of the cluster. 

Beside we'll use linked clone which mean saving  a lot of space.

On the machine 

*   Create a disk partition for the docker storage
*   Docker storage is setup using a thin pool on this partition
*   ntp is activated  (to be improved for really offline env, even if test show it works)
*   firewalld is desactivated  (TODO to be improved)
*   the root password is setup to root 

## Launching 

Make sure you have moved the offline directory you produced in prepare_offline in the base_machine directory

and then just 

    vagrant up 

In the base_machine directory.

## Package the box oc_base.box

When finished we want to make this machine a box that will be reused everytime we destroy/rebuild the cluster.

We need to reload and setup the vbox addition inside the machine. TODO not sure this step has to be reproduced because we already do it in install.sh

    vagrant reload
    #log to the machine
    vagrant ssh
    sudo su 
    cd /opt/VBox*/init
    ./vboxadd setup
    #log out
    exit
    exit
    # create the box in the current directory
    vagrant halt
    vagrant package --output oc_base.box  

