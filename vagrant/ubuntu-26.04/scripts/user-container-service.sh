#!/usr/bin/env bash

DOCKERFILE='FROM registry.access.redhat.com/ubi10/ubi
USER root
LABEL maintainer="John Doe"
RUN yum install httpd -y && yum clean all && rm -rf /var/cache/yum
# Add default Web page and expose port
RUN echo "The Web Server is Running" > /var/www/html/index.html
EXPOSE 80
# Start the service
CMD ["-D", "FOREGROUND"]
ENTRYPOINT ["/usr/sbin/httpd"]
'
mkdir -p /tmp/mywebi
cd /tmp/mywebi || exit 1
echo "${DOCKERFILE}" >Dockerfile
# building image
buildah bud -t vagrant/webi:latest .
cd / && rm -rf /tmp/mywebi

# allow user-land systemd services survive user logout
sudo loginctl enable-linger vagrant

# user level Quadlet unit (podman generate systemd is deprecated)
mkdir -p ~/.config/containers/systemd
echo '[Unit]
Description=Web container (user)

[Container]
ContainerName=webi
Image=localhost/vagrant/webi:latest
PublishPort=81:80

[Install]
WantedBy=default.target
' >~/.config/containers/systemd/webi.container

# vagrant ssh provisioning session may lack XDG_RUNTIME_DIR needed by systemctl --user
XDG_RUNTIME_DIR="/run/user/$(id -u)"
export XDG_RUNTIME_DIR
systemctl --user daemon-reload
systemctl --user start webi.service

# open 81 port on firewall so that it is accessible from host
# via curl 172.30.250.5:81
sudo firewall-cmd --add-port=81/tcp
sudo firewall-cmd --runtime-to-permanent
