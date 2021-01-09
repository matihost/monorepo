#!/usr/bin/env bash

# install Apache
yum -y module install httpd

# set default ServerName in main Apache config file to allow it start w/o warnings
sed -i -E 's/^#ServerName .*$/ServerName centos:80/g' /etc/httpd/conf/httpd.conf

# enabling https and firewall rules
sudo firewall-cmd --add-service=http --add-service=https
sudo firewall-cmd --runtime-to-permanent

# define http VirtualHost for "magic.centos"

# when any VirtualHost with *:80 appears it overrides the default main config from /etc/httpd/conf/httpd.conf
# it means that when no ServerName matcher, it will choose the first VirtualHost
# that's why it is important to keep all VirtualHost for the same IP:PORT in one file - to ensure which one is choosen in case no Host is valid
echo '<VirtualHost *:80>
    DocumentRoot "/var/www/html"
    ServerName centos
    # other Host to be choosen
    ServerAlias centos
</VirtualHost>

<VirtualHost *:80>
    DocumentRoot "/var/www/magic/html"
    ServerName magic.centos
    ServerAlias magic
</VirtualHost>' >/etc/httpd/conf.d/vhosts.conf

mkdir -p /var/www/magic/html
echo "magic welcomes" >/var/www/magic/html/index.html
echo "default welcomes" >/var/www/html/index.html
chown -R apache:apache /var/www/magic /var/www/html/index.html

systemctl enable --now httpd

# testing - default VirtualHost
# curl -H "Host: centos"  -v http://172.30.250.3
# curl -H "Host: whatever"  -v http://172.30.250.3
# curl -v http://172.30.250.3
#
# # testing - magic.centos VirtualHost
# curl -H "Host: magic.centos"  -v http://172.30.250.3
# curl -H "Host: magic"  -v http://172.30.250.3

# define https VirtualHost for "magic.centos"

# it contains c_rehash script
yum -y install openssl-perl

# generate self-signed TLS
openssl req \
  -x509 -sha256 -subj "/CN=magic.centos" -days 365 -out /tmp/magic.centos.crt \
  -newkey rsa:2048 -nodes -keyout /tmp/magic.centos.key

# create .pem file (concatenated private key and crt file)
# needed for some system
cp /tmp/magic.centos.key /tmp/magic.centos.pem
cat /tmp/magic.centos.crt >>/tmp/magic.centos.pem

# add cert and key to system location
mv /tmp/magic.centos.crt /etc/pki/tls/certs/
chmod 644 /etc/pki/tls/certs/magic.centos.crt

mv /tmp/magic.centos.key /etc/pki/tls/private/
chmod 600 /etc/pki/tls/private/magic.centos.key

# self signed certificate has option CA enabled as well
# so placing .pem it to system ca-trusted key, so that it is trusted and -k is not needed locally
mv /tmp/magic.centos.pem /etc/pki/ca-trust/source/anchors/
chmod 644 /etc/pki/ca-trust/source/anchors/magic.centos.pem
# update system CA trusted certificates list
update-ca-trust
# rehash system certificates /etc/pki/tls/certs (needed by software retrieving certs via their hashes)
c_rehash

echo '<VirtualHost 172.30.250.3:443>
    DocumentRoot "/var/www/magic/html"
    ServerName magic.centos
    ServerAlias magic
    SSLEngine on
    SSLCertificateFile /etc/pki/tls/certs/magic.centos.crt
    SSLCertificateKeyFile /etc/pki/tls/private/magic.centos.key
    SSLCipherSuite PROFILE=SYSTEM
    SSLProxyCipherSuite PROFILE=SYSTEM
</VirtualHost>
' >>/etc/httpd/conf.d/vhosts.conf

systemctl reload --now httpd
# testing:
# bare curl should work locally as self signed certificate is added to this system CA certificates
# curl https://magic.centos
# from other box:
# curl -k -H "Host: magic.centos"  https://172.30.250.3
