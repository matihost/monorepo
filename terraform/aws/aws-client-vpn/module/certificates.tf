# ca RSA key
resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name         = lookup(var.ca_subject, "common_name", null)
    country             = lookup(var.ca_subject, "country", null)
    locality            = lookup(var.ca_subject, "locality", null)
    organization        = lookup(var.ca_subject, "organization", null)
    organizational_unit = lookup(var.ca_subject, "organizational_unit", null)
    postal_code         = lookup(var.ca_subject, "postal_code", null)
    province            = lookup(var.ca_subject, "province", null)
    serial_number       = lookup(var.ca_subject, "serial_number", null)
    street_address      = lookup(var.ca_subject, "street_address", [])
  }

  validity_period_hours = 10 * 365 * 24 # 10 years
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

resource "aws_secretsmanager_secret" "ca" {
  name                    = "${local.prefix}-ca-certificate"
  recovery_window_in_days = 0
  description             = "${local.prefix} ca certificate contents"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "ca" {
  secret_id     = aws_secretsmanager_secret.ca.id
  secret_string = tls_private_key.ca.private_key_pem
}

# server RSA key
resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem

  subject {
    common_name         = lookup(var.server_subject, "common_name", null)
    country             = lookup(var.server_subject, "country", null)
    locality            = lookup(var.server_subject, "locality", null)
    organization        = lookup(var.server_subject, "organization", null)
    organizational_unit = lookup(var.server_subject, "organizational_unit", null)
    postal_code         = lookup(var.server_subject, "postal_code", null)
    province            = lookup(var.server_subject, "province", null)
    serial_number       = lookup(var.server_subject, "serial_number", null)
    street_address      = lookup(var.server_subject, "street_address", [])
  }

}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem   = tls_cert_request.server.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem
  is_ca_certificate  = false

  validity_period_hours = 365 * 24 # 1 year

  allowed_uses = [
    "server_auth",
    "key_encipherment",
    "digital_signature",
  ]
}

resource "aws_acm_certificate" "server" {
  private_key       = tls_private_key.server.private_key_pem
  certificate_body  = tls_locally_signed_cert.server.cert_pem
  certificate_chain = tls_self_signed_cert.ca.cert_pem

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret" "server" {
  name                    = "${local.prefix}-server-certificate"
  recovery_window_in_days = 0
  description             = "${var.name} server certificate contents"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "server" {
  secret_id     = aws_secretsmanager_secret.server.id
  secret_string = tls_private_key.server.private_key_pem
}

# client RSA key
resource "tls_private_key" "client" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "client" {
  private_key_pem = tls_private_key.client.private_key_pem

  subject {
    common_name         = lookup(var.client_subject, "common_name", null)
    country             = lookup(var.client_subject, "country", null)
    locality            = lookup(var.client_subject, "locality", null)
    organization        = lookup(var.client_subject, "organization", null)
    organizational_unit = lookup(var.client_subject, "organizational_unit", null)
    postal_code         = lookup(var.client_subject, "postal_code", null)
    province            = lookup(var.client_subject, "province", null)
    serial_number       = lookup(var.client_subject, "serial_number", null)
    street_address      = lookup(var.client_subject, "street_address", [])
  }
}

resource "tls_locally_signed_cert" "client" {
  cert_request_pem   = tls_cert_request.client.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem
  is_ca_certificate  = false

  validity_period_hours = 365 * 24 # 1 year

  allowed_uses = [
    "client_auth",
    "key_encipherment",
    "digital_signature",
  ]
}

resource "aws_acm_certificate" "client" {
  private_key       = tls_private_key.client.private_key_pem
  certificate_body  = tls_locally_signed_cert.client.cert_pem
  certificate_chain = tls_self_signed_cert.ca.cert_pem
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret" "client" {
  name                    = "${local.prefix}-client-certificate"
  recovery_window_in_days = 0
  description             = "${local.prefix} client certificate contents"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "client" {
  secret_id     = aws_secretsmanager_secret.client.id
  secret_string = tls_private_key.client.private_key_pem
}


output "client-ovpn-extension-config" {
  description = "client.ovpn file with routing entire client network traffic via VPN server"
  sensitive   = true
  value = templatefile("${path.module}/client.ovpn.tpl", {
    vpn_additional_config = <<EOF
script-security 2
up /etc/openvpn/update-resolv-conf
down /etc/openvpn/update-resolv-conf
EOF
    client_crt            = tls_locally_signed_cert.client.cert_pem
    client_key            = tls_private_key.client.private_key_pem
  })
}
