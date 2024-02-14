resource "ibm_iam_trusted_profile" "bastion" {
  name = "${local.prefix}-${var.region}-bastion"
}


resource "ibm_iam_trusted_profile_policy" "bastion-viewer" {
  profile_id = ibm_iam_trusted_profile.bastion.id
  roles      = ["Viewer"]


  resources {
    resource_type = "resource-group"
    resource      = local.resource_group_id
  }

}
