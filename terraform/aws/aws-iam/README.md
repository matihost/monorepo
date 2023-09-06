# Terraform :: Minimal set of IAM

Setup minimal IAM resources:

* Managed Policy: _BillingViewAccess_ to be able to see Billing Console content. To take effect root AWS account has to follow [this procedure](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_billing.html?icmpid=docs_iam_console#tutorial-billing-step1) to enable billing access for IAM users.

* Managed Policy: _PassInstanceProfileToEC2_ to be able to pass instance profile to EC2 instance

* Managed Policy: _DecodeAuthorizationMessages_ to be able to decode encoded authorization errors

* Managed Policy: _AssumeRole_ to be able to switch to Roles

* Group : _LimitedAdmin_ - it contains above policies, plus ViewOnlyAccess, network, lambda and system admin, and ability to assume to Role within Account.
  It does not allow IAM modifications - except IAMUserChangePassword (ability for an IAM user to change their own password).

* Group : _IamAdmin_ - group allowing IAM modification, user and policies management, access to account billing information and tools.

* Group : _User_ - group with basic user privileges and allowing to assume any roles

* Roles and Instance Profiles:

** _s3all_ and _s3readers_ - to access S3 from EC2

**  _jenkins-master_ - should be applied to EC2 with Jenkins Master - so that Jenkins can spawn Jenkins Agent EC2.

** _lambda-basic_ - role to be applied to Lambda, allowing accessing VPC resources
Users management is not part of this setup.

** _ami-builder_ - role used to create AMI by Packer. LimitedAdmin group is able to assume this role.

** _Admin_ and _ReadOnly_ roles - so that IAM users can assume these roles

** AWS Organization along with _shared_, _dev_ and _prod_ Organization Units. Current account is management account and it belongs directly to root of the organization. You need to create Account yourself and attach them to Organization Units yourself.
After that you can switch to _OrganizationAccountAccessRole_ from any user/role in Management Account.

** Service Control Policy applied on organization root level to ensure only Free Tier EC2 instance type are used.
(Current Account is management account - and SCP are not preventing anything on managed account.)

## Prerequisites

* Latest Terraform installed
* [AWS CLI v2](https://github.com/aws/aws-cli/tree/v2)
* Recommended [awsp](https://github.com/antonbabenko/awsp) or [awsume](https://awsu.me/) to easily switch aws profiles.

* AWS Account. AWS FreeTier Account is ok.

* Logged to AWS Account allowing to modify IAM.

  * On fresh AWS root account it is recommended to first create: IAM user (for example `admin`), attach directly AdministratorAccess policy, create secrets keys and configure AWS:

  ```bash
  aws configure --profile admin@my-free-tier
  awsume -l
  awsume admin@my-free-tier
  ```

  * Then run this terraform script:

  ```bash
  make run MODE=plan
  # agree on bucket creation
  # if Terraform plan looks ok, run:
  make run MODE=apply
  ```

  After running this terraform - remove the user and its AdministratorAccess attachment and:

  * create IAM User and assign it to `User` group and relogin to it with `aws configure --profile username@accountalias`.
  Edit profile and add `mfa_serial` entry.
  * create AWS profile assuming particular role, for example run `/configure-assume-role.sh -p Admin@accountalias -s username@accountalias Admin` to
  create AWS CLI profile assuming `Admin` role from `username@accountalias` and name resulting profile with `Admin@accountalias`.

  * (Optionally) create auxiliary account in AWS Organization panel and attach them to Organization Units. When new Account is created and attached to AWS Organization you may create another entry in `~/.aws/config` to assume to `OrganizationAccountAccessRole` role in that Account.

  The resulting `~/.aws/configure` may look like this:

  ```txt
  [profile username@accountalias]
  region = us-east-1
  mfa_serial=arn:aws:iam::ACCOUNT_ID:mfa/username@matihosthack@mfa-device-name
  [profile Admin@accountalias]
  role_arn = arn:aws:iam::ACCOUNT_ID:role/Admin
  region = us-east-1
  [profile OrganizationAccountAccessRole@accountalias-dev]
  role_arn = arn:aws:iam::ANOTHER_ACCOUNT_ID:role/OrganizationAccountAccessRole
  source_profile = username@accountalias
  region = us-east-1
  ```

  * (Optionally) The root AWS account has to follow [this procedure](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_billing.html?icmpid=docs_iam_console#tutorial-billing-step1) to enable billing access to IAM users.

## Usage

```bash
# list available AWS CLI profiles
awsume -l

# configure profile with credentials for user
# after that you need to edit ~/.aws/config to provide mfa_serial for 2FA
aws configure --profile username@accountalias

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
