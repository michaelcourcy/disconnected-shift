# base machine

The goal is to produce the oc_base.box that will be used as a base for cloning all the machine of the cluster. 

This run will create a machine with the following features

*   A disk partition for the docker storage with a thin pool on this partition
*   A disk partition for the glusterfs storage 
*   ntp is activated  (TODO to be improved for really offline env, even if test show it works)
*   firewalld is desactivated  (TODO to be improved)
*   the root password is setup to root (TODO probably useless check and remove)

## Launching 

Make sure you have moved the offline directory you produced in prepare_offline in the base_machine directory

and then just 
    
    cd base_machine
    vagrant up 

And wait for completion and the message "base machine successfully complete"

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

