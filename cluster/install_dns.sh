###############################
# mis à jour de /etc/named.conf
############################### 
cat <<EOF > /etc/named.conf
//
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//
// See the BIND Administrator's Reference Manual (ARM) for details about the
// configuration located in /usr/share/doc/bind-{version}/Bv9ARM.html

options {
	listen-on port 53 { 127.0.0.1; 172.25.250.254; };
	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	/* TO HARDEN COURCY */
	allow-query     { any; };

	/* 
	 - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
	 - If you are building a RECURSIVE (caching) DNS server, you need to enable 
	   recursion. 
	 - If your recursive DNS server has a public IP address, you MUST enable access 
	   control to limit queries to your legitimate users. Failing to do so will
	   cause your server to become part of large scale DNS amplification 
	   attacks. Implementing BCP38 within your network would greatly
	   reduce such attack surface 
	*/
	recursion yes;

	/* TO HARDEN COURCY */
	dnssec-enable no;
	dnssec-validation no;

	/* Path to ISC DLV key */
	bindkeys-file "/etc/named.iscdlv.key";

	managed-keys-directory "/var/named/dynamic";

	pid-file "/run/named/named.pid";
	session-keyfile "/run/named/session.key";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
	type hint;
	file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
include "/etc/named.local.openshift";
EOF

#######################################
#creation de /etc/named.local.openshift
#######################################
cat <<EOF > /etc/named.local.openshift
zone "lab.example.com" {
    type master;
    file "forward.openshift";
};

zone "250.25.172.in-addr.arpa" IN {
    type master;
    file "reverse.openshift"; 
};
EOF

#########################################
#creation de /var/named/forward.openshift
#########################################
cat <<EOF > /var/named/forward.openshift
\$TTL   604800
@  IN SOA workstation.lab.example.com. admin.lab.example.com. (
   3                ;Serial
   3600             ;Refresh
   1800             ;Retry
   604800           ;Expire
   86400            ;Minimul TTL
)

@   IN   NS    workstation

workstation     IN   A   172.25.250.254
master       IN   A   172.25.250.10
node1        IN   A   172.25.250.11
node2        IN   A   172.25.250.12
*.cloudapps  IN   A   172.25.250.11
EOF

#########################################
#creation de /var/named/forward.openshift
#########################################
cat <<EOF > /var/named/reverse.openshift
\$TTL   604800
@  IN SOA workstation.lab.example.com. admin.lab.example.com. (
   3                ;Serial
   3600             ;Refresh
   1800             ;Retry
   604800           ;Expire
   86400            ;Minimul TTL
)

@   IN   NS    workstation.lab.example.com.

254 IN   PTR workstation.lab.example.com.    ;172.25.250.254
10  IN   PTR master.lab.example.com.      ;172.25.250.10
11  IN   PTR node1.lab.example.com.       ;172.25.250.11
12  IN   PTR node2.lab.example.com.       ;172.25.250.12
EOF

#on controle la syntaxe des 4 fichiers 
named-checkconf /etc/named.conf 
named-checkzone 250.25.172.in-addr.arpa /var/named/reverse.openshift
named-checkzone lab.example.com /var/named/forward.openshift
#on ajoute named aux services 
systemctl enable named
systemctl start named
