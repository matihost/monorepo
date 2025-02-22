resource "google_secret_manager_secret" "ca-crt" {
  secret_id = "${local.prefix}-ca-crt"
  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "ca-crt-data" {
  secret      = google_secret_manager_secret.ca-crt.id
  secret_data = var.ca_crt
}

resource "google_secret_manager_secret" "client-crt" {
  secret_id = "${local.prefix}-client-crt"
  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "client-crt-data" {
  secret      = google_secret_manager_secret.client-crt.id
  secret_data = var.client_crt
}


resource "google_secret_manager_secret" "server-crt" {
  secret_id = "${local.prefix}-server-crt"
  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "server-crt-data" {
  secret      = google_secret_manager_secret.server-crt.id
  secret_data = var.server_crt
}

resource "google_secret_manager_secret" "ca-key" {
  secret_id = "${local.prefix}-ca-key"
  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "ca-key-data" {
  secret      = google_secret_manager_secret.ca-key.id
  secret_data = var.ca_key
}

resource "google_secret_manager_secret" "server-key" {
  secret_id = "${local.prefix}-server-key"
  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "server-key-data" {
  secret      = google_secret_manager_secret.server-key.id
  secret_data = var.server_key
}

resource "google_secret_manager_secret" "client-key" {
  secret_id = "${local.prefix}-client-key"
  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "client-key-data" {
  secret      = google_secret_manager_secret.client-key.id
  secret_data = var.client_key
}


resource "google_secret_manager_secret" "ta-key" {
  secret_id = "${local.prefix}-ta-key"
  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "ta-key-data" {
  secret      = google_secret_manager_secret.ta-key.id
  secret_data = var.ta_key
}

resource "google_secret_manager_secret" "dh" {
  secret_id = "${local.prefix}-dh"
  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "dh-data" {
  secret      = google_secret_manager_secret.dh.id
  secret_data = var.dh
}
