data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  prefix     = "${var.name != "" ? "${var.name}-" : ""}${var.env}-${var.region}"
}


variable "name" {
  type        = string
  description = "Name of the cluster"
  default     = ""
}

variable "env" {
  type        = string
  description = "Environment name"
}


# tflint-ignore: terraform_unused_declarations
variable "zone" {
  default     = "us-east-1a"
  type        = string
  description = "Preffered AWS AZ where resources need to placed, has to be compatible with region variable"
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Preffered AWS region where resource need to be placed"
}


variable "vpc_name" {
  default     = "dev-us-east-1"
  type        = string
  description = "VPC Name to place EC2 instances"
}


variable "zones" {
  type        = set(string)
  description = "AWS zones for VPC Subnetworks Deployment"
}


variable "openshift_version" {
  type        = string
  default     = "4.17.4"
  description = "Version of OpenShift, rosa list versions for versions"
  validation {
    condition     = can(regex("^[0-9]*[0-9]+.[0-9]*[0-9]+.[0-9]*[0-9]+$", var.openshift_version))
    error_message = "openshift_version must be with structure <major>.<minor>.<patch> (for example 4.17.3)."
  }
}


variable "max_upgrade_version" {
  type        = string
  default     = "4.17"
  description = "Indicates acknowledgement of agreements required to upgrade the cluster version between minor versions (e.g. a value of \"4.16\" indicates acknowledgement of any agreements required to upgrade to OpenShift 4.16.z from 4.15 or before)."
  validation {
    condition     = can(regex("^[0-9]*[0-9]+.[0-9]*[0-9]+$", var.max_upgrade_version))
    error_message = "openshift_version must be with structure <major>.<minor> (for example 4.17)."
  }
}




variable "billing_account_id" {
  type        = string
  default     = ""
  description = "AWS Billing Account, if not provided current account id"
}


variable "replicas" {
  type        = number
  default     = 3
  description = "Number of worker nodes to provision. This attribute is applicable solely when autoscaling is disabled. Single zone clusters need at least 2 nodes, multizone clusters need at least 3 nodes. Hosted clusters require that the number of worker nodes be a multiple of the number of private subnets. (default: 2)"
}

variable "machine_instance_type" {
  type        = string
  description = "Identifies the Instance type used by the default worker machine pool e.g. `m5.xlarge`"
  default     = null
}


variable "cluster_admin_password" {
  type        = string
  default     = ""
  description = "The break glass cluster-admin user password that is created with the cluster. The password must contain at least 14 characters (ASCII-standard) without whitespaces including uppercase letters, lowercase letters, and numbers or symbols."
  sensitive   = true
}


variable "service_cidr" {
  type        = string
  default     = "172.30.0.0/16"
  description = "Block of IP addresses for services, for example \"172.30.0.0/16\"."
}

variable "pod_cidr" {
  type        = string
  default     = "10.128.0.0/14"
  description = "Block of IP addresses from which Pod IP addresses are allocated, for example \"10.128.0.0/14\"."
}

variable "host_prefix" {
  type        = number
  default     = 23
  description = "Subnet prefix length to assign to each individual node. For example, if host prefix is set to \"23\", then each node is assigned a /23 subnet out of the given CIDR."
}


variable "pod_limit" {
  type        = number
  default     = 4096
  description = "Kubelet POD limit, minimum is 4096"
}


# TODO enable when feature works
# As of v1.6.6 ends with error: Autoscaler configuration is not available
variable "enable_cluster_autoscaler" {
  type        = bool
  default     = false
  description = "Whether to create enable cluster autoscaler"
}

variable "autoscaler_max_pod_grace_period" {
  type        = number
  default     = 30
  description = "Gives pods graceful termination time before scaling down."
}

variable "autoscaler_pod_priority_threshold" {
  type        = number
  default     = 1
  description = "To allow users to schedule 'best-effort' pods, which shouldn't trigger Cluster Autoscaler actions, but only run when there are spare resources available."
}

variable "autoscaler_max_node_provision_time" {
  type        = string
  default     = "10m"
  description = "Maximum time cluster-autoscaler waits for node to be provisioned."
}

variable "autoscaler_max_nodes_total" {
  type        = number
  default     = 10
  description = "Maximum number of nodes in all node groups. Cluster autoscaler will not grow the cluster beyond this number."
}
