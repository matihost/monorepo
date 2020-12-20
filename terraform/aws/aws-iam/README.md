# Terraform :: Minimal set of IAM

Setup minimal IAM resources:

* Managed Policy: _BillingViewAccess_ to be able to see Billing Console content. To take effect root AWS account has to follow [this procedure](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_billing.html?icmpid=docs_iam_console#tutorial-billing-step1) to enable billing access for IAM users.

* Managed Policy: _PassInstanceProfileToEC2_ to be able to pass instance profile to EC2 instance

* Managed Policy: _DecodeAuthorizationMessages_ to be able to decode encoded authorization errors

* Managed Policy: _AssumeRole_ to be able to switch to Roles

* Group : _LimitedAdmin_ - it contains above policies, plus ViewOnlyAccess, network, lambda and system admin, and ability to assume to Role within Account.
  It does not allow IAM modifications - except IAMUserChangePassword (ability for an IAM user to change their own password).

* Group : _IamAdmin_ - group allowing IAM modification, user and policies management, access to account billing information and tools.

* Roles and Instance Profiles:

** _s3all_ and _s3readers_ - to access S3 from EC2

**  _jenkins-master_ - should be applied to EC2 with Jenkins Master - so that Jenkins can spawn Jenkins Agent EC2.

** _lambda-basic_ - role to be applied to Lambda, allowing accessing VPC resources
Users management is not part of this setup.

** _ami-builder_ - role used to create AMI by Packer. LimitedAdmin group is able to assume this role.

## Prerequisites

* Latest Terraform installed
* [AWS CLI v2](https://github.com/aws/aws-cli/tree/v2)
* Recommended [awsp](https://github.com/antonbabenko/awsp) to easily switch aws profiles.

* AWS Account. AWS FreeTier Account is ok.

* Logged to AWS Account allowing to modify IAM.

  On fresh AWS root acccount it is recommeded to first create: IAM user and attach directly AdministratorAccess policy.

  Then run this terraform script.

  After running this terraform - remove the user and its AdministratorAccess attachment and:

  * create IAM User and assign it to LimitedAdmin group and relogin to it with `aws configure`.
  * create another IAM User and assign it to IamAdmin group create AWS CLI profile with it `aws configure --profile iam`. Next run of this terraform script can run on user belonging to IAMAdmin group (aka do `awsp iam` to switch to this user before running `make apply`)

  * (Optionally) The root AWS account has to follow [this procedure](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_billing.html?icmpid=docs_iam_console#tutorial-billing-step1) to enable billing access to IAM users.

## Usage

```bash
# login to AWS Account allowing to modify IAM.
aws configure --profile iam

# or to switch to in case you already login
awsp iam
awswhoami

# setup IAM resources
make apply

# show Terraform state along with current EC2 instance user_date startup script
make show-state

# make destroy task is commented out for safety
```
