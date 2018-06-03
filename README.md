# Openshift origin disconnected

This project aims to show how to build an openshift-origin 3.9 cluster in a disconnected mode.

## Motivation 

*   Disconnected environments are in fact something  quite common in many organisations : governement or bank
*   Connected env are often badly connected (poor bandwidth, proxy problem, frequent network outage) and make the installation fail 
*   I think the way I build the solution and the machine are easy to understand so that you may be able to reproduce it whith other machine provider (Vmware, KVM, AWS, Azure, bare metal machine ...)

## Prerequisite

You must have VirtualBox and Vagrant on your system. This project was tested with this version :

*   virtual box 5.1.30 r118389
*   vagrant 2.03

## Building 

*   First be connected and run [Prepare offline](./prepare_offline) it will build the offline directory which contains all the assets to run the next disconnected
*   Second you can disconnect and run [Base Machine](./base_machine) which will prepare the machine you are going to clone in the clusters
*   Third you can disconnect and run [Cluster](./cluster) which will build the complete cluster 
