resource "docker_image" "image" {
  name         = var.image
  keep_locally = true
}

resource "docker_container" "container" {
  image = docker_image.image.latest
  name  = var.container_name
  ports {
    internal = 80
    external = 8000
  }
}
