resource "random_id" "minecraft-random" {
  byte_length = 4
}

resource "google_storage_bucket" "minecraft-data" {
  name          = "minecraft-server-data-${random_id.minecraft-random.hex}"
  force_destroy = true
  # GCP free tier GS is free only with regional class in some US regions
  location      = var.region
  storage_class = "REGIONAL"
}


resource "null_resource" "minecraft-config-template" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<-EOT
    pwd && mkdir -p target/minecraft-server && \
    cp -r config/* target/minecraft-server && \
    curl -sSL ${var.minecraft_server_url} -o  target/minecraft-server/server/server.jar && \
    cd target/ && \
    sed -i 's/MINECRAFT_PASS/${var.server_pass}/g' minecraft-server/server/server.properties minecraft-server/minecraft.service && \
    tar -Jcvf minecraft-config-template.tar.xz minecraft-server
    EOT
  }
}

resource "google_storage_bucket_object" "minecraft-config-template-object" {
  name   = "minecraft-config-template.tar.xz"
  source = "target/minecraft-config-template.tar.xz"
  bucket = google_storage_bucket.minecraft-data.name

  depends_on = [null_resource.minecraft-config-template]
}


output "minecraft_bucket" {
  value = google_storage_bucket.minecraft-data.name
}
