# Note that custom roles in GCP have the concept of a soft-delete. There are two issues that may arise from this and how roles are propagated. 1) creating a role may involve undeleting and then updating a role with the same name, possibly causing confusing behavior between undelete and update. 2) A deleted role is permanently deleted after 7 days, but it can take up to 30 more days (i.e. between 7 and 37 days after deletion) before the role name is made available again. This means a deleted role that has been deleted for more than 7 days cannot be changed at all by Terraform, and new roles cannot share that name.

resource "google_project_iam_custom_role" "intanceGroupManager-updater" {
  role_id     = "instanceGroupUpdater"
  title       = "InstanceGroup Updater"
  description = "Update instanceGroup settings"
  permissions = ["compute.instanceGroupManagers.update", "compute.instanceGroupManagers.get", "compute.instanceGroupManagers.list"]
}
