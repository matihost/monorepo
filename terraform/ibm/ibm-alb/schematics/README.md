# IBM Cloud Schematics repository for Load Balancers deployments

This directory contains Terraform resources compatible with IBM Cloud Schematics folder structure.

## Create IBM Cloud Schematics Workspace procedure

* Go to [https://cloud.ibm.com/schematics/workspaces/create](https://cloud.ibm.com/schematics/workspaces/create)
* Select this GitHub repository for Repository URL, Use full repository option.
* For Folder type: `terraform/ibm/ibm-alb/schematics` (aka path to this folder)
* Terraform version has to be in sync with [versions.tf](versions.tf) `required_version` option.
* Click Next
* For `Resource Group` and `Region` choose ideally the same values which you intent to use later as Terraform variables in actual deployment. Also `Workspace Name` should refer uniquely to single deployment of this repository.
* Click Next
* Verify Variables section, override if necessary.
* Click Generate Plan, and later Apply button.
