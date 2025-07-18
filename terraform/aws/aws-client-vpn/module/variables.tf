data "aws_caller_identity" "current" {}

locals {
  # tflint-ignore: terraform_unused_declarations
  account_id = data.aws_caller_identity.current.account_id

  prefix = "${var.env}-${var.region}-${var.name}"

  cloudwatch_log_group = "/aws/vpn-client/${local.prefix}"
}

variable "vpc" {
  type        = string
  description = "VPC name where to place VPN Endpoints"
  default     = "default"
}

variable "subnet" {
  type        = string
  description = "Name of VPC Subnet Tier tag to which attach VPN client endpoints"
  default     = "default"
}

variable "zones" {
  type        = set(string)
  description = "AWS zones of VPC subnetworks"
}

variable "external_access_range" {
  default     = "0.0.0.0/0"
  type        = string
  description = "The public IP which is allowed to access VPN"
}


variable "split_tunnel" {
  description = "You can use a split-tunnel Client VPN endpoint when you do not want all user traffic to route through the Client VPN endpoint. "
  type        = bool
  default     = false
}

variable "client_cidr_block" {
  description = "(Required) The IPv4 address range, in CIDR notation, from which to assign client IP addresses. The address range cannot overlap with the local CIDR of the VPC in which the associated subnet is located, or the routes that you add manually. The address range cannot be changed after the Client VPN endpoint has been created. The CIDR block should be /22 or greater."
  type        = string
  default     = "10.24.0.0/16"
}

variable "security_group_ids" {
  description = "(Optional) The IDs of one or more security groups to apply to the target network. You must also specify the ID of the VPC that contains the security groups."
  type        = list(string)
  default     = []
}

variable "dns_servers" {
  description = "(Optional) Information about the DNS servers to be used for DNS resolution. A Client VPN endpoint can have up to two DNS servers. If no DNS server is specified, the DNS address of the connecting device is used."
  type        = list(string)
  default     = []
}

variable "vpn_additional_config" {
  description = "(Optional) Additional OpenVPN instructions to generated client.ovpn file"
  type        = string
  default     = ""
}


variable "ca_subject" {
  description = "The subject for which ca certificate is being requested. The acceptable arguments are all optional "
  type        = any
  default = {
    common_name = "ca.local"
  }
}

variable "server_subject" {
  description = "The subject for which server certificate is being requested. The acceptable arguments are all optional "
  type        = any
  default = {
    common_name = "server.local"
  }
}

variable "client_subject" {
  description = "The subject for which client certificate is being requested. The acceptable arguments are all optional "
  type        = any
  default = {
    common_name = "client.local"
  }
}

# Default variables

variable "env" {
  type        = string
  description = "Environment name"
  default     = "dev"
}


variable "name" {
  type        = string
  description = "Name for the objects"
  default     = "client-vpn"
}

variable "zone" {
  default     = "us-east-1a"
  type        = string
  description = "Preferred AWS AZ where resources need to placed, has to be compatible with region variable"
}

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Preferred AWS region where resource need to be placed"
}
