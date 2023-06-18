module "local_execution" {
  source = "./module"

  image          = var.image
  container_name = var.container_name
}
