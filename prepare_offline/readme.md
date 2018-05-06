Ce document décrit comment ont été construit repos et images

Construction de repos 
	Extraction des noms de repos (dans /etc/yum.d/*.repo) après avoir suivi la documentation d'install online cf video  -> repos.txt		
	Nettoyage des crochets sed -E -i.bak  's/\[(.*)\]/\1/' ~/repos.txt
    Un script shell boucle sur les noms ses repos et récupere une copie des repos -> sync_repo.sh
	Beaucoup de fichiers sont dupliqués on récupere la liste des duplicats: fdupes /repos > duplicates.txt 
	Puis on supprime les duplicates -> remove_duplicate.sh 
	Enfin on cree la base createrepo --database /repos 
	download par ftp des repos sur le disque dur externe (a executer sur l'host windows avec cygwin) scp -r root@172.25.250.254:/repos /cygdrive/e/offline/repos/
	
Construction de images 
	On recherche toutes les images installé sur les différents noeud en docker.io -> docker images | grep docker.io 
	On pull ses images pour les avoir sur workstation -> download_images.sh
	On les sauve dans un tar -> save_images.sh
	on recupère le tar pour le mettre sur le disque dur externe

Recupération du projet openshift-ansible
	git clone -b release-3.8 https://github.com/openshift/openshift-ansible
	Attention de le faire depuis une vm linux et non depuis windows car vous
	aurez des soucis dans les sauts de lignes
	
		
	