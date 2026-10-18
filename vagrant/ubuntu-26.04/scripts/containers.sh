#!/usr/bin/env bash

apt -y install podman buildah uidmap slirp4netns

# configure rootless containers
# increase user namespaces
echo "user.max_user_namespaces=28633" >/etc/sysctl.d/userns.conf
sysctl -p /etc/sysctl.d/userns.conf

# allow exposing svc on port 80 (list all below port 1024)
echo "net.ipv4.ip_unprivileged_port_start=0" >/etc/sysctl.d/unprivport.conf
sysctl -p /etc/sysctl.d/unprivport.conf

# example of system level container service (Quadlet, podman generate systemd is deprecated)
mkdir -p /tmp/web
cd /tmp/web || exit 1
echo 'FROM registry.access.redhat.com/ubi10/ubi
USER root
RUN yum update -y
RUN yum install httpd -y &&  yum clean all
RUN echo "The Web Server is Running from root" > /var/www/html/index.html
EXPOSE 80
# Start the service
ENTRYPOINT /usr/sbin/httpd && cat
' >Dockerfile
buildah bud -t root/web:latest .
cd / && rm -rf /tmp/web

mkdir -p /etc/containers/systemd
echo '[Unit]
Description=Web container (root)

[Container]
ContainerName=web
Image=localhost/root/web:latest
PublishPort=82:80

[Install]
WantedBy=multi-user.target
' >/etc/containers/systemd/web.container
systemctl daemon-reload
systemctl start web.service

# open 82 port on firewall so that it is accessible from host
# via curl 172.30.250.5:82
firewall-cmd --add-port=82/tcp
firewall-cmd --runtime-to-permanent
