echo "contrôle du répertoire pour le repo"
if [ ! -d /vagrant/offline/repos ]
then 
	echo "Le répertoire /vagrant/offline/repos est absent l'installation des dépendances sera impossible" >&2
	exit 1
fi
echo "Création d'un repo yum local pour la machine $(hostname)"
rm -rf /etc/yum.repos.d/*
cp /vagrant/offline/conf_to_copy/local.repo /etc/yum.repos.d/