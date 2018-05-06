#sur workstation on installe un serveur dns 
#########################################
#creation de /etc/dhcp/dhclient.conf 
#########################################
cat <<EOF > /etc/dhcp/dhclient.conf
prepend domain-name-servers 172.25.250.254;
EOF

#on redemarre network 
systemctl restart network
#on controle /etc/resolv.conf 172.25.250.254 doit apparaitre
cat /etc/resolv.conf 

