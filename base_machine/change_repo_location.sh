echo "checking offline/repos directory"
if [ ! -d /vagrant/offline/repos ]
then 
	echo "directory /vagrant/offline/repos is missing we must exit" >&2
	exit 1
fi
echo "Adding *.repo file for $(hostname)"
rm -rf /etc/yum.repos.d/*
cp /vagrant/offline/conf_to_copy/yum.repos.d/*.repo /etc/yum.repos.d/