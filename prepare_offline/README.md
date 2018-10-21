# Prepare offline directory

This machine prepare the offline environement for the 3.9 openshift-origin install. Hence it must be runned first and be connected to internet to download all the needed dependencies. The dependencies are all put in the /vagrant directory so that they won't be destroyed when you detroy this machine.

## Run it connected to the internet 

It must be run online, it will generate an offline directory of about 45 Go !!  In the next steps [Base Machine](../base_machine) and [Cluster](../cluster) you'll have to to move this directory in their respective directory. This directory has all the assets needed to  allow [Base Machine](../base_machine) and [Cluster](../cluster) projects to run offline.

## Launching 

Just 

    cd prepare_offline
    vagrant up 

And wait for completion and the message "prepare offline successfully complete". Then you can delete the machine :

    vagrant destroy


## Scripts are idempotent

The scripts here are idempotent.  which means you can replay them without errors and somehow they don't restart from zero.

If you redo 

    vagrant up

The yum repository will be updated (only new or updated packaged are going to be updated). But the docker image will be redownloaded only if you destroy the tar file.

If you replay :
*   clone_openshift-ansible_project.sh you get all the change from openshift-ansible/release-3.9
*   create_repo.sh you only get the new packages in the differents repos 
*   pull_and_save_images.sh you pull images and create archives. If the archive (a tar file) already exist they won't be created again.

## Once it's finished 
 
Once the execution of the scripts finish you can safely delete the machine because the offline directory is created in /vagrant shared directory and won't be deleted with the machine.

The execution time of the scripts mainly depends of the quality of your connection with my 2Mo/s connection it took me about 30 hours and the whole directory is about 45 Go ...

Now copy or move the offline directory to [Base Machine](../base_machine) and follow the instructions to create the machine you're going to clone.

 
