cat <<EOF > /etc/dhcp/dhclient.conf
prepend domain-name-servers 172.25.250.254;
EOF

systemctl restart network
#check content of resolv.conf
cat /etc/resolv.conf 

