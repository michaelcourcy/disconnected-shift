# base machine

The goal is to produce the oc_base.box that will be used as a base for cloning all the machine of the cluster. 

*   Cloning save strorage space
*   Docker storage is setup properly 
*   ntp is activated  (to be improved for really offline env, even if test show it works)
*   firewalld is desactivated  (to be imporved for security reasons)


## To produce the oc_base.box 

*   Make sure you have moved or copied the offline directory you produced in prepare_offline
*   vagrant up
*   vagrant reload 
*   sudo su && cd /opt/VBox*/init && ./vboxadd setup
*   vagrant halt 
*   vagrant package --output oc_base.box 
