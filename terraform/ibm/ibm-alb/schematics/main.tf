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
  ssh_key_id                    = var.ssh_key_id
  private_security_group_name   = var.private_security_group_name
  public_lb_security_group_name = var.public_lb_security_group_name
  iam_trusted_profile           = var.iam_trusted_profile
}
