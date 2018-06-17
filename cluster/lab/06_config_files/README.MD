
finding the config file. To find all the config file we have to pull the rope : systemctl restart origin-master-api.service -> cat /etc/systemd/system/origin-node.service -> EnvironmentFile=/etc/sysconfig/origin-node -> CONFIG_FILE=/etc/origin/node/node-config.yaml

We deduce the master config file /etc/origin/master/master-config.yaml.