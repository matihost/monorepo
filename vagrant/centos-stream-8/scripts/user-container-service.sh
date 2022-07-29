#!/usr/bin/env bash

DOCKERFILE='FROM registry.access.redhat.com/ubi9/ubi
USER root
LABEL maintainer="John Doe"
# Update image
RUN yum update
RUN yum install --disablerepo=* --enablerepo=ubi-9-appstream --enablerepo=ubi-9-baseos httpd -y && rm -rf /var/cache/yum
# Add default Web page and expose port
RUN echo "The Web Server is Running" > /var/www/html/index.html
EXPOSE 80
# Start the service
CMD ["-D", "FOREGROUND"]
ENTRYPOINT ["/usr/sbin/httpd"]
# or shell form which prevents usage of CMD params
#ENTRYPOINT /usr/sbin/httpd && cat
'
mkdir -p /tmp/mywebi
cd /tmp/mywebi || exit 1
echo "${DOCKERFILE}" >Dockerfile
# building image
buildah bud -t vagrant/webi:latest .

# create user land systemd directories
mkdir -p ~/.config/systemd/user
cd ~/.config/systemd/user || exit 1
rm -rf /tmp/mywebi
# create container w/o running it,
# it should run as deamon, and autoremove after finishing
# and ideally expose some port on host on host
podman create --name=webi -it --rm -p 81:80 localhost/vagrant/webi:latest
# allow user-land systemd services survice user logout
sudo loginctl enable-linger vagrant

# generate
podman generate systemd -n --new --files webi
# remove container to allow systemd start container with the same name
podman rm webi
# enable service on user login and start it now
systemctl enable container-webi.service --user --now

# open 81 port on firewall so that it is accessible from host
# via curl 172.30.250.3:81
sudo firewall-cmd --add-port=81/tcp
sudo firewall-cmd --runtime-to-permanent
