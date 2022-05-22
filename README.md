# Matihost's Monorepo

[![License](https://img.shields.io/github/license/matihost/learning.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://app.travis-ci.com/matihost/learning.svg?branch=master)](https://app.travis-ci.com/github/matihost/learning)

Various technology deployments, tools & code:

* [k8s](k8s)
  * helm deployments:
    * echoserver - Helm setup for echoserver (Minikube/GKE)
    * mq - Helm based setup for IBM MQ (Minikube/GKE)
  * minikube - various script for native Minikube deployment under Ubuntu desktop
  * gatekeeper - Ansible based GateKeeper deployment for Minikube or GKE
  * istio - Ansible based Istio deployment for Minikube or GKE
  * jenkins - Ansible based Jenkins deployment for Minikube or GKE
  * okd-3 - Ansible playbooks to setup OpenShift/OKD 3 on VirtualBox VMs
  * images - docker images useful in other repos
    * ansible - docker image with Ansible, available at: quay.io/matihost/ansible
    * jenkins - docker image with Jenkins and predefined plugins, available at: quay.io/matihost/jenkins:lts
    * buildah - experiments with buildah
    * and usually each app has also Makefile task to build its docker image as well

* [terraform](terraform)
  * gcp - Terraform deployment for GCP
    * apigee - ApigeeX Free Tier setup with XLB, sample API proxies etc.
    * gke - GKE deployment along with optional components (Anthos, config-sync, workflow identity, etc)
    * minecraft-server - secure HA setup for Minecraft (VM, LB, hourly backups, auto-shutdown for night cloud functions etc)
    * gcp-open-vpn - OpenVPN setup supporting `dial-in` VPN in GCP (GCP VPN services does not support this mode), useful to work under GCP w/o need to expose services over external ip/xlb etc. It supports DNS sharing as well.
    * gcp-iam - setup IAM resources needed on fresh GCP account
    * gcp-network-setup - setup VPC and other minimal networking resources for futher deployments
    * gcp-biguery-dataset - basic config for BigQuery
    * gcp-kms - setup KMS keyrings, keys etc for other scripts
    * gcp-monitoring - setup logging buckets, custom dashboards, limits etc
  * aws - Terraform deployments for AWS, mainly utilizing only AWS Free Tier
    * aws-iam - setup IAM resources needed on fresh AWS account (users, roles, groups etc)
    * aws-network - minimal AWS recommended setup with private subnet
    * aws-instance - minimal VM setup
    * aws-alb - Application Load Balancer usage
    * aws-jenkins - Jenkins deployment as AWS VMs, Packer images for Jenkins Agents
    * aws-lambda - sample AWS Lambda emulating a client hitting EC2 instance with AWS ApiGateway exposure
* [scripts](scripts) - various bash scripts (tools for TLS handling, K8S etc.)
* [vagrant](vagrant)  - CentOS VM buildout with Vagrant with various Linux networking tools examples
* [algorithms](algorithms/project-euler) - Java based project solving various <https://projecteuler.net> problems
* [ansible](ansible)
  * system - script to provision/update and keep clean home Ubuntu based desktop environment
  * envoy - envoy deployment with various use cases
  * learning - various tricks in Ansible
* [go](go)
  * learning - various language tricks in Golang
* [java](java) - multi-module Maven project with
  * command-line  - example app retrieving exchange rates
  * mq - IBM Java client application
  * library - Groovy, Spock and Scala interaction examples
* [python](python)
  * exchange-rate - example app retrieving exchange rates
  * tools
    * automount-cifs - to setup Linux automount svc with home SAMBA NFS
    * setup-opendns  - to setup regular update of OpenDNS with home public ip
* [rust](rust) - sample Rust example
* [jenkins](Jenkinsfile), [travis](.travis.yml), [gcp cloudbuild](cloudbuild.yaml) - various Continous Integration toolset integration
