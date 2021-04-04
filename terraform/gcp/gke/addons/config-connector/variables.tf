variable "gsa_roles" {
  type        = list(string)
  description = "List of GCP roles to apply to GSA assigned as worflow identity for K8S SA in K8S NS"
}

variable "kns" {
  type        = string
  description = "Name of existing namespace to which bing workflod identity and config connector context"
}

variable "kns_sas" {
  type        = list(string)
  default     = ["default"]
  description = "List of KNS service accounts which needs to be mapped to GSA as worfklow identity"
}
