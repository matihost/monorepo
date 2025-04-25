#!/usr/bin/env bash

yum -y install container-tools

# configure rootless containers
# increase user namespaces
echo "user.max_user_namespaces=28633" >/etc/sysctl.d/userns.conf
sysctl -p /etc/sysctl.d/userns.conf

# allow exposing svc on port 80 (list all below port 1024)
echo "net.ipv4.ip_unprivileged_port_start=0" >/etc/sysctl.d/unprivport.conf
sysctl -p /etc/sysctl.d/unprivport.conf

# example of system level container service
echo 'FROM registry.access.redhat.com/ubi9/ubi
USER root
RUN yum update -y
RUN yum install httpd -y &&  yum clean all
RUN echo "The Web Server is Running from root" > /var/www/html/index.html
EXPOSE 80
# Start the service
ENTRYPOINT /usr/sbin/httpd && cat
' >Dockerfile
buildah bud -t root/web:latest .
rm -rf Dockerfile

# create container w/o running it,
# it should run as deamon, and autoremove after finishing
# and ideally expose some port on host
podman create --name=web -it --rm -p 82:80 localhost/root/web:latest
cd /etc/systemd/system || exit 1

# generate
podman generate systemd --files -n --new web
# remove container to allow systemd start container with the same name
podman rm web
# enable service on boot and start it now
systemctl enable container-web.service --now

# open 81 port on firewall so that it is accessible from host
# via curl 172.30.250.4:82
sudo firewall-cmd --add-port=82/tcp
sudo firewall-cmd --runtime-to-permanent
