virtual box 5.1.30 r118389
vagrant 2.03

Dossier base_machine à n'executer que si vous reconstruisez la machine de base
==============================================================================
Permet de fabriquer l’image VM socle (avec ajout d’un disk /dev/sdb  de 40g / install docker 1.1.2.6 et openshift) avec les images de bases pour faire fonctionner openshift et donc ne pas avoir à les télécharger online

Cette opération n'étant à faire qu'une fois et le fichier offline étant très très gros (90 Go) on déplace le fichier offline de cluster vers base_machine et on le redéplacera vers cluster une fois base_machine finie (impossible de gérer des hard ou softlink windows correctement interprété par linux)
	
Lancer la construction de la machine avec la commande vagrant up dans le répertoire du fichier Vagrantfile. 
Se connecter "vagrant ssh"
Devenez root "sudo su"
modification du mot de passe root à « root »  (utilisé lors de la copie de clé ssh dans la workstation) : passwd
sortez du shell en tapant deux fois exit. Faire un reboot via vagrant reload 
Se connecter "vagrant ssh"
Devenez root "sudo su"
lancement du script /opt/Vbox*./init/vboxadd setup (pour réparer le partage de fichier suite à mise a jour du kernel)
sortez du shell en tapant deux fois exit. Arréter la machine:  vagrant halt 
la packager via la commande : vagrant package --output oc_base.box
 
Copier la box après packaging dans le dossier cluster.
 
Dossier cluster
===============
Configure l’environnement complet (workstation, master, node1 et node2)

Copier la box packagé ci-dessus dans le répertoire (au même niveau que le Vagrantfile)
Si ça n'est pas fait déplacer le repertoire offline dans cluster
Vagrant up pour créer et démarrer les 4 VM
une fois l'install fini vous avez été automatiquement connecté depuis workstation 
connectez vous à workstation vagrant ssh workstation ou si vous êtes avec mobaxterm 
			vagrant ssh-config workstation > sshw
			ssh -F sshw workstation
Vérifier l'état des pods oc get pods --all-namespaces
L'aventure commence !


