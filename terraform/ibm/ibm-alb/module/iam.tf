resource "ibm_iam_trusted_profile" "webserver" {
  name = local.prefix
}


resource "ibm_iam_trusted_profile_policy" "webserver-viewer" {
  profile_id = ibm_iam_trusted_profile.webserver.id
  roles      = ["Viewer"]


  resources {
    resource_type = "resource-group"
    resource      = var.resource_group_id
  }

}
