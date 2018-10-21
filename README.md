# Openshift origin disconnected

This project aims to learn how to build an openshift-origin 3.9 cluster in a disconnected environment and also practice CI/CD with this PAAS. It runs in a vagrant box and create 4 machines :

*   Workstation that hold the following roles : 
    *   ansible installer, 
    *   openshift client, 
    *   docker registry, 
    *   dns server, 
    *   yum repository  
* Node1 : which is a compute and infra node in the same time 
* Node2 : similar to Node1
* Master : Which hold the master api and the etcd role

## Motivation 

*   Disconnected environments are in fact something  quite common in many organisations : governement or bank for instances but many orther use case exist
*   Connected env are often badly connected (poor bandwidth, proxy problem, frequent network outage) and make the installation fail. With disconnected-shift all the assets are local and the install is really likely to succeed.
*   I think the way I build the solution and the machine are easy to understand so that you may be able to reproduce it whith other machine provider (Vmware, KVM, AWS, Azure, bare metal machine ...). I was able to reproduce it with bare metals and VMs in an ESX in both cases with much more machines.
*   It brings an openshift sandbox for admin. Minishift is really cool for trying regular user stuff. But when you want to try risky change on your cluster you'd better validate it on disconnected-shift than minishift.


## Prerequisite

You must have VirtualBox and Vagrant on your system. This project was tested with this version :

*   virtual box 5.1.30 r118389
*   vagrant 2.03

## Building 

*   First you need to be connected and run [Prepare offline](./prepare_offline) it will build the offline directory which contains all the assets to run the [Base Machine](./base_machine) and the [Cluster](./cluster). This assets include the yum repository, the docker registry, and the openshift-ansible project.
*   Second you can disconnect and run [Base Machine](./base_machine) which will prepare a base vagrant box that you are going to clone, that will make the destroy/rebuild of the cluster really stable.
*   Third run [Cluster](./cluster) which will build the complete cluster starting from the base box you previously create.
