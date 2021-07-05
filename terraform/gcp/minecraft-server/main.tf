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

variable "external_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "The public CIDR IP which is allowed to access VPN Gateway."
}

variable "minecraft_server_url" {
  type        = string
  default     = "https://launcher.mojang.com/v1/objects/0a269b5f2c5b93b1712d0f5dc43b6182b9ab254e/server.jar"
  description = "Minecraft server.jar version 1.17"
}

variable "minecraft_server_name" {
  type        = string
  default     = "prod-01"
  description = "Minecraft server name"
}

# TODO https://github.com/pwaller/waitsilence  - zrobic to w timerze, backupowac tylko ostatnie 3 backupy
# podczas startu ciagnac z backupa
variable "minecraft_rcon_url" {
  type        = string
  default     = "https://github.com/Tiiffi/mcrcon/releases/download/v0.7.1/mcrcon-0.7.1-linux-x86-64.tar.gz"
  description = "Minecraft RCON utility download url"
}

variable "server_rcon_pass" {
  type        = string
  description = "Minecraft server rcon pass"
}
