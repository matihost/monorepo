# Terraform :: Minimal set of IAM for Linked Account

Setup minimal IAM resources:

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

## Usage

```bash
# list available AWS CLI profiles
awsume -l

# configure profile with credentials for user
# after that you need to edit ~/.aws/config to provide mfa_serial for 2FA
aws configure --profile username@accountalias

# setup SSO profile via aws-sso-util
# pip3 install --user --break-system-packages aws-sso-util
aws-sso-util configure profile --sso-start-url "https://SSO_NAME.awsapps.com/start#/" --sso-region "eu-west-1" SSORoleName@accountalias
# in order to awsume to SSO profile, it requires to be logged first to the profile SSO config
aws-sso-util login --profile Admin@mati-dev

# activate particular AWS CLI profile
awsume username@accountalias

# convention that role profiles are capital letter
awsume Admin@accountalias

# example of assuming role in child account
awsume OrganizationAccountAccessRole@accountalias-dev

# check current profile identity
awswhoami



# setup IAM resources
make run MODE=apply
```
