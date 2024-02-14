module "local_execution" {
  source = "../module"

  env                    = var.env
  resource_group_name    = var.resource_group_name
  resource_group_id      = var.resource_group_id
  instance_profile       = var.instance_profile
  zone                   = var.zone
  region                 = var.region
  ssh_pub_key            = var.ssh_pub_key
  ssh_key                = var.ssh_key
  zones                  = var.zones
  create_sample_instance = var.create_sample_instance
}
