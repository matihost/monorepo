data "google_compute_network" "default" {
  name = "default"

  depends_on = [
    google_project_service.apis
  ]
}


variable "asn" {
  type        = number
  description = <<EOT
    The ASN (16550, 64512 - 65534, 4200000000 - 4294967294) can be any private ASN
    not already used as a peer ASN in the same region and network or 16550 for Partner Interconnect.
  EOT
}


variable "psa_peering_cidr_range" {
  type        = string
  description = <<EOT
  VPC peering to allow managed services in Google VPC like Apigee, CloudSQL etc.
  to be accessible from VPC via internal IP, w/o need to use external ip.
  Should be /16 range.
  EOT
}

variable "dns_suffix" {
  type        = string
  description = <<EOT
    Dns main zone. The result main zone is a concatenation of var.env + "." + var.dns-suffix
  EOT
}

variable "regions" {
  type = map(object({
    ip_cidr_range         = string
    l7lb_proxy_cidr_range = string
    secondary_ranges = set(object({
      range_name    = string
      ip_cidr_range = string
    }))
  }))
  description = "GCP Regions For VPC Subnetworks Deployment"
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
