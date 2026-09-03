# Terraform :: Minimal set of IAM for Linked Account

Setup minimal IAM resources:

* Opens S3 Account Public Access. In order to expose a site via S3 bucket it needs to be opened. AWS block public access on account level, bucket level and resource policy on IAM level. This module opens access on account level. You still needs to open public access on bucket and bucket IAM resource policy level as well.

* Managed Policy: _BillingViewAccess_ to be able to see Billing Console content. To take effect root AWS account has to follow [this procedure](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_billing.html?icmpid=docs_iam_console#tutorial-billing-step1) to enable billing access for IAM users.

* Managed Policy: _PassInstanceProfileToEC2_ to be able to pass instance profile to EC2 instance

* Managed Policy: _DecodeAuthorizationMessages_ to be able to decode encoded authorization errors

* Managed Policy: _AssumeRole_ to be able to switch to Roles

* Roles and Instance Profiles:

** _s3all_ and _s3readers_ - to access S3 from EC2

**  _jenkins-master_ - should be applied to EC2 with Jenkins Master - so that Jenkins can spawn Jenkins Agent EC2.

** _Lambda-Basic_ - role to be applied to Lambda, allowing accessing VPC resources
Users management is not part of this setup.

** _ami-builder_ - role used to create AMI by Packer. LimitedAdmin group is able to assume this role.

** _FullAdmin_ and _ReadOnly_ roles - which can be assumed by user from this account and Organization Management Account

## Prerequisites

* Latest Terragrunt and OpenTofur or Terraform installed
* [AWS CLI v2](https://github.com/aws/aws-cli/tree/v2)
* Recommended [awsp](https://github.com/antonbabenko/awsp) or [awsume](https://awsu.me/) to easily switch aws profiles.

* AWS Account with Organization being set up. AWS FreeTier Account is ok.
Running [aws-iam-management](../aws-iam-management) can be run on AWS Management account to setup Organization.

* Logged to AWS Account Linked Account in AWS Organization.

* AWS CLI profile configured to AWS Linked Account. How to configure AWS CLI profile is described in [aws-iam-management :: Configure AWS CLI profile Options](../aws-iam-management/README.md#configure-aws-cli-profile-options) module.

## Usage

```bash
# setup IAM resources
make run MODE=apply
```
