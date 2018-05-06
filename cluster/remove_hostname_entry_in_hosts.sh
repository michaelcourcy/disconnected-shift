# on vire la ligne *.lab.example.com 127.0.0.1
# car dans un contexte multi noeud cela crée beaucoup de soucis 
# par exemple des process en parlant ou en écoutant sur *.lab.example.com
# se retrouve à le faire sur l'interface 127.0.0.1 au lieu de le faire
# sur l'interface 172.25.250.*
sed -i "/$(hostname)/d" /etc/hosts