# tflint-ignore: terraform_unused_declarations
data "google_client_config" "current" {}
# tflint-ignore: terraform_unused_declarations
data "google_project" "current" {
}

# tflint-ignore: terraform_unused_declarations
data "google_compute_network" "default" {
  name = "default"
}


data "google_compute_network" "private" {
  name = "${var.env}-vpc"
}

data "google_compute_subnetwork" "subnet" {
  name   = "${var.env}-${var.region}-subnet"
  region = var.region
}

locals {
  prefix = "${var.env}-${var.region}-vpn"
}

variable "ca_crt" {
  type        = string
  description = "The pem encoded VPN CA crt"
  sensitive   = true
}

variable "ca_key" {
  type        = string
  description = "The pem encoded VPN CA key"
  sensitive   = true
}

variable "server_crt" {
  type        = string
  description = "The pem encoded VPN server crt"
  sensitive   = true
}

variable "server_key" {
  type        = string
  description = "The pem encoded VPN server key"
  sensitive   = true
}

variable "client_crt" {
  type        = string
  description = "The pem encoded VPN client crt"
  sensitive   = true
}

variable "client_key" {
  type        = string
  description = "The pem encoded VPN client key"
  sensitive   = true
}

variable "ta_key" {
  type        = string
  description = "OpenVPN ta.key file"
  sensitive   = true
}

variable "dh" {
  type        = string
  description = "OpenVPN dh2048.pem file"
  sensitive   = true
}


variable "ssh_pub_key" {
  type        = string
  description = "The pem encoded SSH pub key for accessing VMs"
  sensitive   = true
}

# tflint-ignore: terraform_unused_declarations
variable "ssh_key" {
  type        = string
  description = "The pem encoded SSH priv key to place on VPN VM"
  sensitive   = true
}

variable "external_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "The public CIDR IP which is allowed to access VPN Gateway."
}


variable "onpremise_dns_zone_forward" {
  type = object({
    zone   = string
    dns_ip = string
  })
  default     = { "zone" : "", "dns_ip" : "" }
  description = "The public CIDR IP which is allowed to access VPN Gateway."
}


variable "env" {
  type        = string
  description = "Environment, also VPC name"
}

variable "project" {
  type        = string
  description = "GCP Project For Deployment"
}

variable "region" {
  type        = string
  description = "GCP Region For Deployment"
}

variable "zone" {
  type        = string
  description = "GCP Zone For Deployment"
}
