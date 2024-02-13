resource "ibm_resource_instance" "cos" {
  resource_group_id = local.resource_group_id

  name     = "${local.prefix}-cos"
  service  = "cloud-object-storage"
  plan     = "standard"
  location = "global"
  # tags   = var.tags
}
