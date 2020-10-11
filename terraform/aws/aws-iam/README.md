# Terraform :: Minimal set of IAM

Setup minimal IAM resources:

* Policy: _AllowPassingInstanceProfileToEC2_ to be able to pass instance profile to EC2 instance

* Policy: _AllowDecodeAuthorizationMessages_ to be able to decode encoded authorization errors

* Group : _IamAdmin_ - group allowing IAM modification, user and policies management
* Group : _LimitedAdmin_ - it contains above policies, plus ViewOnlyAccess, network, lambda and system admin
  It does not allow IAM modifications - except IAMUserChangePassword (ability for an IAM user to change their own password).

* Roles and Instance Profiles:

** _s3all_ and _s3readers_ - to access S3 from EC2

**  _jenkins-master_ - should be applied to EC2 with Jenkins Master - so that Jenkins can spawn Jenkins Agent EC2.

** _lambda-basic_ - role to be applied to Lambda, allowing accessing VPC resources
Users management is not part of this setup.

## Prerequisites

* Logged to AWS Account allowing to modifty IAM.

On fresh AWS root acccount it is recommeded to first create: IAM user and attach directly AdministratorAccess policy.

Then run this terraform script.

After running this terraform - assing the user to LimitedAdmin group and remove AdministratorAccess policy attachment.

```bash
aws configure
```

After that it is recommended to create IAM User and assing him LimitedAdmin user and relogin to it with `aws configure`.

* Latest Terraform installed

## Usage

```bash
# setup IAM resources
make apply

# show Terraform state along with current EC2 instance user_date startup script
make show-state

# make destroy task is commented out for safety
```
