#!/usr/bin/env bash

# install Apache
apt -y install apache2 openssl ca-certificates
a2enmod ssl

# set default ServerName in main Apache config file to allow it start w/o warnings
echo 'ServerName ubuntu:80' >/etc/apache2/conf-available/servername.conf
a2enconf servername

# enabling https and firewall rules
firewall-cmd --add-service=http --add-service=https
firewall-cmd --runtime-to-permanent

## define http VirtualHost for "magic.ubuntu"

# when any VirtualHost with *:80 appears it overrides the default main config
# it means that when no ServerName matcher, it will choose the first VirtualHost
# that's why it is important to keep all VirtualHost for the same IP:PORT in one file - to ensure which one is choosen in case no Host is valid
a2dissite 000-default
echo '<VirtualHost *:80>
    DocumentRoot "/var/www/html"
    ServerName ubuntu
    # other Host to be choosen
    ServerAlias ubuntu
</VirtualHost>

<Directory "/usr/local/www">
    AllowOverride None
    # Allow open access:
    Require all granted
</Directory>
<VirtualHost *:80>
    DocumentRoot "/usr/local/www/magic/html"
    ServerName magic.ubuntu
    ServerAlias magic
</VirtualHost>' >/etc/apache2/sites-available/vhosts.conf

mkdir -p /usr/local/www/magic/html
echo "magic welcomes" >/usr/local/www/magic/html/index.html
echo "default welcomes" >/var/www/html/index.html
chown -R www-data:www-data /usr/local/www /var/www/html/index.html

a2ensite vhosts
systemctl enable --now apache2

# testing from other machine
# # testomg - default VirtualHost
# curl -H "Host: ubuntu"  -v http://172.30.250.5
# curl -H "Host: whatever"  -v http://172.30.250.5
# curl -v http://172.30.250.5
#
# # testing - magic.ubuntu VirtualHost
# curl -H "Host: magic.ubuntu"  -v http://172.30.250.5
# curl -H "Host: magic"  -v http://172.30.250.5

## define https VirtualHost for "magic.ubuntu"

# generate self-signed TLS
openssl req \
  -x509 -sha256 -subj "/CN=magic.ubuntu" -days 365 -out /tmp/magic.ubuntu.crt \
  -newkey rsa:2048 -nodes -keyout /tmp/magic.ubuntu.key

# add cert and key to system location
mv /tmp/magic.ubuntu.crt /etc/ssl/certs/
chmod 644 /etc/ssl/certs/magic.ubuntu.crt

mv /tmp/magic.ubuntu.key /etc/ssl/private/
chmod 600 /etc/ssl/private/magic.ubuntu.key

# self signed certificate has option CA enabled as well
# so adding it to system ca-trusted store, so that it is trusted and -k is not needed locally
cp /etc/ssl/certs/magic.ubuntu.crt /usr/local/share/ca-certificates/magic.ubuntu.crt
# update system CA trusted certificates list (it rehashes /etc/ssl/certs as well)
update-ca-certificates

echo '<VirtualHost 172.30.250.5:443>
    DocumentRoot "/usr/local/www/magic/html"
    ServerName magic.ubuntu
    ServerAlias magic
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/magic.ubuntu.crt
    SSLCertificateKeyFile /etc/ssl/private/magic.ubuntu.key
</VirtualHost>
' >>/etc/apache2/sites-available/vhosts.conf

systemctl reload apache2
# testing:
# bare curl should work locally as self signed certificate is added to this system CA certificates
# curl https://magic.ubuntu
# from other box:
# curl -k -H "Host: magic.ubuntu"  https://172.30.250.5

## adding additional port 1180 on which Apache/httpd listens

# open 1180/tcp port on firewall
firewall-cmd --add-port=1180/tcp
firewall-cmd --runtime-to-permanent

echo 'Listen 1180

<VirtualHost *:1180>
    DocumentRoot "/var/www/html"
    ServerName ubuntu
    # other Host to be choosen
    ServerAlias ubuntu
</VirtualHost>

<VirtualHost *:1180>
    DocumentRoot "/usr/local/www/magic/html"
    ServerName magic.ubuntu
    ServerAlias magic
</VirtualHost>
' >>/etc/apache2/sites-available/vhosts.conf
systemctl reload apache2
