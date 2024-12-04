# Matihost's Monorepo

[![License](https://img.shields.io/github/license/matihost/monorepo.svg)](https://opensource.org/licenses/MIT)
[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-908a85?logo=gitpod)](https://gitpod.io/#https://github.com/matihost/monorepo)
[![CI](https://github.com/matihost/monorepo/actions/workflows/ci.yaml/badge.svg)](https://github.com/matihost/monorepo/actions/workflows/ci.yaml)

Various technology deployments, tools & code:

* [k8s](k8s)
  * helm deployments:
    * echoserver - Helm setup for echoserver (Minikube/GKE)
    * mq - Helm based setup for IBM MQ (Minikube/GKE)
  * minikube - various script for native Minikube deployment under Ubuntu desktop
  * gatekeeper - Ansible based GateKeeper deployment for Minikube or GKE
  * gh-arc - Ansible based GitHub Actions Runner Controller deployment for Minikube or GKE
  * istio - Ansible based Istio deployment for Minikube or GKE
  * jenkins - Ansible based Jenkins deployment for Minikube or GKE
  * okd - OKD clusters deployments:
    * okd4 - scripts to install OKD 4 on GCP
    * okd3 - Ansible playbooks to setup OpenShift/OKD 3 on VirtualBox VMs
  * images - docker images useful in other repos
    * ansible - docker image with Ansible, available at: quay.io/matihost/ansible
    * jenkins - docker image with Jenkins and predefined plugins, available at: quay.io/matihost/jenkins:lts
    * buildah - experiments with buildah
    * and usually each app has also Makefile task to build its docker image as well

* [terraform/tofu](terraform)
  * gcp - Open Tofu (open source version of Terraform) and Terragrunt deployment for GCP
    * apigee - ApigeeX Free Tier setup with XLB, sample API proxies etc.
    * gke - GKE deployment along with optional components (Anthos, config-sync, workflow identity, etc)
    * keycloak - Cloud Run, CloudSQL exposed over GLB deployment of Keycloak IAM/IDP software
    * ghost - Cloud Run, CloudSQL exposed over GLB deployment of Ghost software
    * minecraft-server - secure HA setup for Minecraft (VM, LB, hourly backups, auto-shutdown for night cloud functions etc)
    * gcp-open-vpn - OpenVPN setup supporting `dial-in` VPN in GCP (GCP VPN services does not support this mode), useful to work under GCP w/o need to expose services over external ip/xlb etc. It supports DNS sharing as well.
    * gcp-iam - setup IAM resources needed on fresh GCP account
    * gcp-network-setup - setup VPC and other minimal networking resources for futher deployments
    * gcp-biguery-dataset - basic config for BigQuery
    * gcp-kms - setup KMS keyrings, keys etc for other scripts
    * gcp-monitoring - setup logging buckets, custom dashboards, limits etc
    * gcp-workstations - setup GCP Workstations infrastructure for remote development
    * gcp-cloudbuild - setup GCP Cloud Build infrastructure to trigger build for GitHub repository
  * aws - Terragrunt / OpenTofu deployments for AWS, mainly utilizing only AWS Free Tier
    * aws-serverless - sample API app based on Python Fast API and Serverless Framework deployment
    * aws-rosa - deployment of ROSA HCP (aka OpenShift on AWS where control plane is on RedHat account)
    * aws-site - sample web site exposure via S3 and CloudFront
    * aws-iam-management, aws-iam-linked - setup IAM resources needed on fresh AWS management account (users, roles, groups etc) and subsequent linked AWS accounts
    * aws-network-setup - minimal AWS recommended setup with private subnet
    * aws-instance - VM setup
    * aws-alb - Application Load Balancer usage
    * aws-jenkins - Jenkins deployment as AWS VMs, Packer images for Jenkins Agents
    * aws-lambda - sample AWS Lambda emulating a client hitting EC2 instance with AWS ApiGateway exposure
    * aws-glue - sample AWS Glue / Apache Spark job wih PCI credit card removal in S3 bucket
    * aws-ecs - sample AWS ECS Services deployment
    * aws-rds - sample AWS RDS Aurora Serverless v2 PosrgreSQL setup
  * ibm - Terragrunt / OpenTofu deployments for IBM Cloud
    * ibm-iam - setup IAM resources needed on fresh IBM account (resource group)
    * ibm-network-setup - minimal IBM Cloud recommended network setup
    * ibm-alb - Application and Network Load Balancer usage
    * ibm-ocp - IBM RedHat OpenShift Kubernetes Service (ROKS) deployment
  * azure - Terragrunt / OpenTofu deployments for Azure
    * azure-network-setup - minimal Azure recommended network setup
    * azure-entraid - setup IAM resource needed on fresh Azure subscription (resource group)
    * azure-instance - VM setup
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
* [github actions](.github), [jenkins](Jenkinsfile), [travis](.travis.yml), [gcp cloudbuild](cloudbuild.yaml) - various Continous Integration toolset integration
