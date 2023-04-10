
data "google_client_openid_userinfo" "me" {
}


resource "google_os_login_ssh_public_key" "login" {
  user    = data.google_client_openid_userinfo.me.email
  key     = file("~/.ssh/id_rsa.cloud.vm.pub")
  project = var.project
}
