#!/usr/bin/env bash

# install Apache
yum -y module install httpd

# set default ServerName in main Apache config file to allow it start w/o warnings
sed -i -E 's/^#ServerName .*$/ServerName centos:80/g' /etc/httpd/conf/httpd.conf

# enabling https and firewall rules
sudo firewall-cmd --add-service=http --add-service=https
sudo firewall-cmd --runtime-to-permanent

# define VirtualHost for "magic.centos"

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
