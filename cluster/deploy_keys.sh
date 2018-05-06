# on installe la clé ssh de workstation sur les trois autres noeuds
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N "" 
sshpass -p "root" ssh-copy-id -o StrictHostKeyChecking=no root@master.lab.example.com
sshpass -p "root" ssh-copy-id -o StrictHostKeyChecking=no root@node1.lab.example.com
sshpass -p "root" ssh-copy-id -o StrictHostKeyChecking=no root@node2.lab.example.com