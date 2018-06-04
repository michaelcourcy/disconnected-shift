# Manage user and project

In this lab we are dealing with a pretty common use case:  how to limit a person to create and manage pod only in his own project. 

Some more specific use case also are  commons like : 

*   Put a quota on file storage for the project 
*   Put a quota on memory for the project 
*   Put a quota on CPU for for the project 
*   Forbid the deletion of some pods 


## Restrict a user to a single project 

I found all the material for this in this two links https://docs.openshift.org/3.9/admin_guide/manage_users.html and  https://docs.openshift.org/3.9/admin_guide/managing_projects.html.


### Create a new user and a project for this user 

We used a quite simple identity provider in the project which is the htpassword identity provider. The htpasswd file is referenced in the [inventory file](../../prepare_offline/offline/conf_to_copy/inventory). Search the line htpasswd. This is how we setup the cluster to manage user. You may also have a look to [create_openshift_admin.sh](../../cluster/create_openshift_admin.sh) where you can see how a first admin user has been created with the full privilege on the cluster.

    htpasswd -b /etc/origin/master/htpasswd admin redhat
    oc adm policy add-cluster-role-to-user cluster-admin admin
	
Where going tho to do the same thing for our first user

Log in to the master and create the user "restricted" with the password redhat.

    $> htpasswd -b /etc/origin/master/htpasswd restricted redhat
	Adding password for user restricted
	
Now the user is added to the identity provider but is not created in the etcd db, the user will be created when it will successfully connect for the first time.

We are going to create a new project for this user, comeback to workstation

    $> oc new-project projforrestricted
	
### Restrict the user to this project

#### Understand Rules, Roles, and Bindings 

To understand how to restrict "restricted" to "projforrestricted" we have to understand the authorization model of openshift : https://docs.openshift.org/3.9/architecture/additional_concepts/authorization.htm

* Rules : Sets of permitted verbs on a set of objects. For example, whether something can create pods.
* Roles : Collections of rules. Users and groups can be associated with, or bound to, multiple roles at the same time.
* Bindings : Associations between users and/or groups with a role.

For instance when we runned this command after the install 
    
	oc adm policy add-cluster-role-to-user cluster-admin admin
	
We created a binding between the clusterrole "cluster-admin" and the user "admin". By the way don't be confused between user and role name, admin or basic-user are roles, and we created a user called admin, this two objects have the same name but are different things. 

Let's say we want to see what's the verbs a cluster-admin clusterrole includes : 

    $> oc describe clusterrole.rbac cluster-admin
       Name:         cluster-admin
       Labels:       <none>
       Annotations:  authorization.openshift.io/system-only=true
                     openshift.io/description=A super-user that can perform any action in the cluster. When granted to a user within a project, they have full control over quota and membership and can perform every action...
                     rbac.authorization.kubernetes.io/autoupdate=true
       PolicyRule:
         Resources  Non-Resource URLs  Resource Names  Verbs
         ---------  -----------------  --------------  -----
                    [*]                []              [*]
         *.*        []                 []              [*]
		 
As you can see it's full power !

but if you do the same thing for the clusterrole admin you'll see a much longer output. Which means less power actually. 

    $> oc describe clusterrole.rbac admin
       Name:         admin
       Labels:       kubernetes.io/bootstrapping=rbac-defaults
       Annotations:  openshift.io/description=A user that has edit rights within the project and can change the project's membership.
                     rbac.authorization.kubernetes.io/autoupdate=true
       PolicyRule:
         Resources                                                  Non-Resource URLs  Resource Names  Verbs
         ---------                                                  -----------------  --------------  -----
         appliedclusterresourcequotas                               []                 []              [get list watch]
         appliedclusterresourcequotas.quota.openshift.io            []                 []              [get list watch]
         bindings                                                   []                 []              [get list watch]
         buildconfigs                                               []                 []              [create delete deletecollection get list patch update watch]
         buildconfigs.build.openshift.io                            []                 []              [create delete deletecollection get list patch update watch]
         buildconfigs/instantiate                                   []                 []              [create]
		 ....


The set of verbs [get list watch] is a rule on the resources appliedclusterresourcequotas, the admin don't have the capacity to update the clusterressourcesquotas, but  it can  update a buildconfig. 

If you do the same thing with a basic-user role you'll see a role fitted for watching but not doing 

     $> oc describe clusterrole.rbac basic-user
        Name:         basic-user
        Labels:       <none>
        Annotations:  openshift.io/description=A user that can get basic information about projects.
                      rbac.authorization.kubernetes.io/autoupdate=true
        PolicyRule:
          Resources                                           Non-Resource URLs  Resource Names  Verbs
          ---------                                           -----------------  --------------  -----
          clusterroles                                        []                 []              [get list]
          clusterroles.authorization.openshift.io             []                 []              [get list]
          clusterroles.rbac.authorization.k8s.io              []                 []              [get list watch]
          projectrequests                                     []                 []              [list]
          projectrequests.project.openshift.io                []                 []              [list]
          projects                                            []                 []              [list watch]
          projects.project.openshift.io                       []                 []              [list watch]
          selfsubjectaccessreviews.authorization.k8s.io       []                 []              [create]
          selfsubjectrulesreviews                             []                 []              [create]
          selfsubjectrulesreviews.authorization.openshift.io  []                 []              [create]
          storageclasses.storage.k8s.io                       []                 []              [get list]
          users                                               []                 [~]             [get]
          users.user.openshift.io                             []                 [~]             [get]

Now if you want to see all the bindings on the currentproject projforrestricted you just list them 

     $> oc get rolebinding.rbac 
	 NAME                    AGE
     admin                   33m
     system:deployers        33m
     system:image-builders   33m
     system:image-pullers    33m
	 
We see that when creating a new project some useful bindings are automatically created for us. Let's see some of them 

     $> oc describe rolebinding.rbac system:deployers 
        Name:         system:deployers
        Labels:       <none>
        Annotations:  <none>
        Role:
          Kind:  ClusterRole
          Name:  system:deployer
        Subjects:
          Kind            Name      Namespace
          ----            ----      ---------
          ServiceAccount  deployer  projforrestricted
		  
system.deployers bind the ClusterRole system:deployer to the service account (which is a special kind of user) deployer.

Wait, who is deployer ? I didn't create this guy ? 

When you create a new project openshift also create automatically this list of service account inside the project.

     $> oc get sa
	 NAME       SECRETS   AGE
     builder    2         38m
     default    2         38m
     deployer   2         38m
	 
To finish there are two levels of roles and binding :

*   Cluster RBAC : Roles and bindings that are applicable across all projects. Roles that exist cluster-wide are considered cluster roles. Cluster role bindings can only reference cluster roles.
*   Local RBAC : Roles and bindings that are scoped to a given project. Roles that exist only in a project are considered local roles. Local role bindings can reference both cluster and local roles.

This two-level hierarchy allows re-usability over multiple projects through the cluster roles while allowing customization inside of individual projects through local roles.


### Give the user restricted the admin role in the project projforrestricted

Taking in account all that was previously explained, to reach our goal we're going to create a local binding in the project projectforrestricted between the user restricted and the role admin. To make this binding local instead of cluster we use add-role-to-user instead of add-cluster-role-to-user.

     $> oc adm policy add-role-to-user admin restricted 
     role "admin" added: "restricted"

This work because the current project is projectforrestricted. We can list all the bindings : 

     $> oc get rolebinding.rbac
     NAME                    AGE
     admin                   1h
     admin-0                 2m
     system:deployers        1h
     system:image-builders   1h
     system:image-pullers    1h
    	
Notice the new binding admin-0 

     $> oc describe rolebinding.rbac admin-0
     Name:         admin-0
     Labels:       <none>
     Annotations:  <none>
     Role:
       Kind:  ClusterRole
       Name:  admin
     Subjects:
       Kind  Name        Namespace
       ----  ----        ---------
       User  restricted
	   
Admin is a cluster role but the binding is local, I couldn't find a way to check if the binding is local or not except if I change for this user :

     $> oc logout
	 $> oc login
     Authentication required for https://master.lab.example.com:8443 (openshift)
     Username: restricted
     Password:
     Login successful.
     
     You have one project on this server: "projforrestricted"
     
     Using project "projforrestricted".

## Manage quotas

Todo.

		
	


  






    


	
