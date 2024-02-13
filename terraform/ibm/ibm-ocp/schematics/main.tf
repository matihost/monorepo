module "local_execution" {
  source = "../module"

  env                           = var.env
  resource_group_name           = var.resource_group_name
  resource_group_id             = var.resource_group_id
  instance_profile              = var.instance_profile
  zone                          = var.zone
  region                        = var.region
  vpc_name                      = var.vpc_name
  subnetworks                   = var.subnetworks
}
