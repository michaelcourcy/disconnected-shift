for dir in 	C7.0.1406-extras \
	C7.0.1406-fasttrack \
	C7.0.1406-updates \
	C7.1.1503-base \
	C7.1.1503-centosplus \
	C7.1.1503-extras \
	C7.1.1503-fasttrack \
	C7.1.1503-updates \
	C7.2.1511-base \
	C7.2.1511-centosplus \
	C7.2.1511-extras \
	C7.2.1511-fasttrack \
	C7.2.1511-updates \
	C7.3.1611-base \
	C7.3.1611-centosplus \
	C7.3.1611-extras \
	C7.3.1611-fasttrack \
	C7.3.1611-updates \
	centos-openshift-origin \
	centosplus \
	cr \
	epel \
	extras \
	fasttrack \
	updates
do 
	scp -r root@172.25.250.254:/offline/repos/$dir /cygdrive/e/offline/repos/
done
