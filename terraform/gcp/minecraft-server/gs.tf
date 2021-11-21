resource "random_id" "minecraft-random" {
  byte_length = 4
}

resource "google_storage_bucket" "minecraft-data" {
  name          = "minecraft-server-data-${random_id.minecraft-random.hex}"
  force_destroy = true
  # GCP free tier GS is free only with regional class in some US regions
  location      = var.region
  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      # keep only 2 version of a file
      num_newer_versions = 2
    }
    action {
      type = "Delete"
    }
  }
}


resource "null_resource" "minecraft-config-template" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<-EOT
    pwd && mkdir -p target/minecraft-server &&
      cp -r config/* target/minecraft-server &&
      curl -sSL ${var.minecraft_server_url} -o  target/minecraft-server/server/server.jar &&
      cd target/ &&
      curl -L ${var.minecraft_rcon_url} -o - |tar -zxv mcrcon &&
      mv mcrcon minecraft-server/server/ &&
      sed -i 's/MINECRAFT_PASS/${var.server_rcon_pass}/g' minecraft-server/server/server.properties minecraft-server/server/minecraft-backup.sh minecraft-server/minecraft.service &&
      sed -i 's/GS_BUCKET/${google_storage_bucket.minecraft-data.name}/g' minecraft-server/server/minecraft-backup.sh &&
      sed -i 's/MINECRAFT_SERVER_NAME/${var.minecraft_server_name}/g' minecraft-server/server/server.properties minecraft-server/server/minecraft-backup.sh &&
      tar -Jcvf minecraft-config-template.tar.xz minecraft-server
    EOT
  }
}

resource "google_storage_bucket_object" "minecraft-config-template-object" {
  name   = "${var.minecraft_server_name}/minecraft-config-template.tar.xz"
  source = "target/minecraft-config-template.tar.xz"
  bucket = google_storage_bucket.minecraft-data.name

  depends_on = [null_resource.minecraft-config-template]
}


output "minecraft_bucket" {
  value = google_storage_bucket.minecraft-data.name
}
