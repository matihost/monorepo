provider "google" {
  region  = var.region
  zone    = local.zone
  project = var.project
}

data "google_client_config" "current" {}
data "google_project" "current" {
}
data "google_compute_network" "private" {
  name = "private-vpc"
}

data "google_compute_subnetwork" "private1" {
  name   = "private-subnet-${var.region}"
  region = var.region
}

locals {
  zone = "${var.region}-${var.zone_letter}"
}

variable "region" {
  type        = string
  default     = "europe-central2"
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

variable "external_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "The public CIDR IP which is allowed to access Minecraft server"
}

variable "minecraft_server_url" {
  type        = string
  default     = "https://launcher.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar"
  description = "Minecraft server.jar version 1.18.2, downloadable from: https://www.minecraft.net/pl-pl/download/server"
}

variable "minecraft_server_name" {
  type        = string
  default     = "prod-01"
  description = "Minecraft server name"
}


variable "minecraft_rcon_url" {
  type        = string
  default     = "https://github.com/Tiiffi/mcrcon/releases/download/v0.7.2/mcrcon-0.7.2-linux-x86-64.tar.gz"
  description = "Minecraft RCON utility download url, downloadable from: https://github.com/Tiiffi/mcrcon/releases"
}

variable "server_rcon_pass" {
  type        = string
  description = "Minecraft server rcon pass"
}

variable "server_op_user" {
  type        = string
  description = "Minecraft operator/op user"
}
