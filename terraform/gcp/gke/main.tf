provider "google" {
  region  = var.region
  zone    = local.zone
  project = var.project
}

data "google_client_config" "current" {}
data "google_project" "current" {
}
data "google_compute_network" "default" {
  name = "default"
}

data "google_compute_network" "private-gke" {
  name = "private-vpc"
}

data "google_compute_subnetwork" "private-gke" {
  name   = "private-subnet-${var.region}"
  region = var.region
}

locals {
  zone     = "${var.region}-${var.zone_letter}"
  gke_name = "${var.cluster_name}-${var.env}"
  location = var.regional_cluster ? var.region : local.zone
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP Region For Deployment"
}

variable "zone_letter" {
  type        = string
  default     = "a"
  description = "GCP Region For Deployment"
}

variable "project" {
  type        = string
  description = "GCP Project For Deployment"
}

variable "cluster_name" {
  type        = string
  default     = "shared"
  description = "GKE Cluster Name Project For Deployment"
}

variable "secondary_ip_range_number" {
  type        = string
  default     = "0"
  description = "secondary_ip_range for pod and svc, assumption there are two ip ragnes for both pods and svc per region, second GKE cluster in region should use other subnets"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment"
}

variable "regional_cluster" {
  type        = bool
  default     = false
  description = "Whether to create regional cluster. Default false - which means cluster will be zonal."
}

variable "master_cidr" {
  type        = string
  default     = "172.16.0.32/28"
  description = "IP CIDR to allocate to Master Nodes in GoogleVPC, cannot interfere with any range from nodes VPC, cannot interfere between any private GKE master ranges as peering is reused, has to be /28"
}

variable "expose_master_via_external_ip" {
  type        = bool
  default     = true
  description = "Whether to expose Kube API as ExternalIP. Default true - which means cluster will be available from laptop"
}

variable "external_access_cidrs" {
  type        = set(string)
  default     = []
  description = "The public CIDR IP which is allowed to access Kube API. expose_master_via_external_ip has to be true and you need to put your ip to be able to access GKE Master API"
}

variable "external_dns_k8s_namespace" {
  type        = string
  default     = "external-dns"
  description = "GKE Namespace where ExternalDNS is being deployed"
}

variable "external_dns_k8s_sa_name" {
  type        = string
  default     = "external-dns"
  description = "ExternalDNS  K8S ServiceAccount"
}

variable "enable_pod_security_policy" {
  default     = true
  description = "Whether to enable PodSecurityPolicy in the GKE cluster, PSP are deprecated since K8S 1.21 and going to be removed in K8S 1.25"
  type        = bool
}

variable "encrypt_etcd" {
  default     = false
  description = "Whether to encrypt GKE etcd with KMS key, requires prerequisites/kms to be run once"
  type        = bool
}

variable "bigquery_metering" {
  default     = false
  description = "Whether to export usage metering to BigQuery, requires prerequisites/bigquery-dataset to be run once"
  type        = bool
}
