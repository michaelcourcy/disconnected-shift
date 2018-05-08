# Prepare offline directory

This project prepare the offline environement for the 3.9 openshift-origin install. 

## Run it connected to the internet 

It must be run online, it will generate  an offline directory that you'll have to copy in project base_machine and finally in cluster.  This directory has all the assets needed to  allow base_machine and cluster projects to run offline.

## Scripts are idempotent

The scripts here are idempotent.  which means you can replay them without errors and somehow they don't restart from zero.

If you replay :
*   clone_openshift-ansible_project.sh you get all the change from openshift-ansible/release-3.9
*   create_repo.sh you only get the new packages in the differents repos 
*   pull_and_save_images.sh you get the changes for the images described in images/*.list files. If the images didn't change docker won't redownload them.

## Once it's finished 
 
Once the execution of the scripts finish you can safely delete the machine because the offline directory is created in /vagrant shared directory and won't be deleted with the machine.

The execution time of the scripts mainly depends of the quality of your connection with my 2Mo/s connection it took me about 30 hours and the whole directory is about 36,4 Go ...

Now copy or move the offline directory to base_machine and follow the instructions to create the machine you're going to clone.

 
