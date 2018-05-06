#/bin/sh 
echo " test configuration DHCP"
docker="$(dig +noall +answer index.docker.io | wc -l)"
node1="$(dig +noall +answer node1.lab.example.com | wc -l)"
node2="$(dig +noall +answer node2.lab.example.com | wc -l)"
workstation="$(dig +noall +answer workstation.lab.example.com | wc -l)"
master="$(dig +noall +answer master.lab.example.com | wc -l)"
wildcard="$(dig +noall +answer magrandmereentongues.cloudapps.lab.example.com | wc -l)"

if [ "$docker" = "0" ] 
then 
	echo "docker: index.docker.io unresolvable"
fi
if [ "$node1" = "0" ] 
then 
	echo "cluster: node1.lab.example.com unresolvable"
fi
if [ "$node2" = "0" ] 
then 
	echo "cluster: node2.lab.example.com unresolvable"
fi
if [ "$workstation" = "0" ] 
then 
	echo "cluster: workstation.lab.example.com unresolvable"
fi
if [ "$master" = "0" ] 
then 
	echo "cluster: master.lab.example.com unresolvable"
fi
if [ "$wildcard" = "0" ] 
then 
	echo "wildcard: magrandmereentongues.cloudapps.lab.example.com unresolvable"
fi



