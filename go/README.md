# Go

[![Go Report Card](https://goreportcard.com/badge/github.com/matihost/learning)](https://goreportcard.com/report/github.com/matihost/learning)

Various Go applications showing Go lang structure, concepts, sample libraries usage, build, dependency management etc.

Project files structure follows [project-layout](https://github.com/golang-standards/project-layout) recommendation.

Project is build as Go module.

However it supports GOPATH style of building as well though [Dep](https://golang.github.io/dep/) (dependency management tool for Go).

## Prerequisites

Go lang 1.13.x+

Ubuntu

```bash
sudo apt -y install golang-1.13
sudo apt -y install golang-golang-x-tools
curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
```

CentOS/RHEL:

```bash
# CentOS / RHEL 7.x
#sudo yum --disablerepo=* --enablerepo=rhel-7-server-optional-rpms install golang
# CentOS / RHEL 8.x
sudo yum module install go-toolset
curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
```

Docker

Ubuntu:

```bash
sudo apt install docker.io
```

CentOS /RHEL 7.x:

```bash
sudo subscription-manager repos --enable=rhel-7-server-extras-rpms
sudo yum install docker
```

Configuring Docker (Ubuntu / CentOS /RHEL 7.x)

```bash
cat << EOF | sudo tee /etc/docker/daemon.json > /dev/null
{
 "live-restore": true,
 "group": "dockerroot"
 "insecure-registries": [
  "172.30.0.0/16"
 ],
 "log-driver": "journald",
 "signature-verification" : false
}

# Docker daemon  is accessible via file /var/run/docker.sock
# in order access docker utility without sudo-ing user must belong to "group" from /etc/docker/daemon.json
# it is dockerroot in above example
# usually the easiest way is to check posix group of /var/run/docker.sock
sudo usermod -aG dockerroot $(whoami)

cat << EOF |sudo tee -a /etc/sysconfig/docker > /dev/null
https_proxy=http://aaaa:80
http_proxy=http://aaaaa:80
no_proxy=localhost,127.0.0.1,172.30.1.1
EOF

# Docker daemon needs to be started and enabled
sudo systemctl start docker
sudo systemctl enable docker
```

## Installing

```bash
go get github.com/matihost/learning/go/cmd/language
go get github.com/matihost/learning/go/cmd/http-server
```

## Building from code

```bash

# will make symbolic lint in current GOPATH  so that the source code can be cloned into whatever localization on disk
# Compiled application will land is root source code directory
make build

# to remove vendor directory adn compiled application
make clean

# run go tests
make test

# to build application packaged as Docker
make build-image

# to run application Docker container from previously created Docker image
make run-container
```
