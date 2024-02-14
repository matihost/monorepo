# IBM Cloud Schematics repository for Networking deployment

This directory contains Terraform resources compatible with IBM Cloud Schematics folder structure.

## Create IBM CLoud Schematics Workspace from CLI

```bash
# to create default dev Schematics workspace for ibm-network-setup
# optionally point existing tf state file
ibmcloud sch ws new -f schematics/workspace.json [-s stage/target/...../dev/terraform.tfstate]

# then override  ssh_pub_key and ssh_key variables to contains valid SSH pub and private keys
```

## Create IBM Cloud Schematics Workspace procedure from UI

* Go to [https://cloud.ibm.com/schematics/workspaces/create](https://cloud.ibm.com/schematics/workspaces/create)
* Select this GitHub repository for Repository URL, Use full repository option.
* For Folder type: `terraform/ibm/ibm-network-setup/schematics` (aka path to this folder)
* Terraform version has to be in sync with [versions.tf](versions.tf) `required_version` option.
* Click Next
* For `Resource Group` and `Region` choose ideally the same values which you intent to use later as Terraform variables in actual deployment. Also `Workspace Name` should refer uniquely to single deployment of this repository.
* Click Next
* Verify Variables section, override senstive values if necessary.
* Click Generate Plan, and later Apply button.
