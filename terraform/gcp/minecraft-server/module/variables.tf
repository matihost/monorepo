variable "vpc" {
  type        = string
  default     = "dev"
  description = "GC VPC name"
}

variable "vpc_subnet" {
  type        = string
  default     = "dev-europe-central2"
  description = "GC VPC subnet name, has to be located in variable region"
}


variable "machine_type" {
  type        = string
  default     = "e2-highcpu-8"
  description = "Instance type"
}

variable "region" {
  type        = string
  default     = "europe-central2"
  description = "GCP Region For Deployment"
}

variable "zone" {
  type        = string
  default     = "europe-central2-a"
  description = "GCP Zone For Deployment"
}

variable "project" {
  type        = string
  description = "GCP Project For Deployment"
}

variable "minecraft_server_url" {
  type        = string
  default     = "https://piston-data.mojang.com/v1/objects/5b868151bd02b41319f54c8d4061b8cae84e665c/server.jar"
  description = "Minecraft server.jar version 1.20.2, downloadable from: https://www.minecraft.net/pl-pl/download/server"
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
