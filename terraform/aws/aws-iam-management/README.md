# Terraform :: Minimal set of IAM for AWS Management Account

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
(Current Account is management account - and SCPs are not preventing anything on managed account.)

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
  mfa_serial=arn:aws:iam::ACCOUNT_ID:mfa/username@accountalias@mfa-device-name
  [profile Admin@accountalias]
  role_arn = arn:aws:iam::ACCOUNT_ID:role/Admin
  region = us-east-1
  [profile OrganizationAccountAccessRole@accountalias-dev]
  role_arn = arn:aws:iam::ANOTHER_ACCOUNT_ID:role/OrganizationAccountAccessRole
  source_profile = username@accountalias
  region = us-east-1
  ```

  * (Optionally) The root AWS account has to follow [this procedure](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_billing.html?icmpid=docs_iam_console#tutorial-billing-step1) to enable billing access to IAM users.

## Configure AWS CLI profile Options

### Configure AWS CLI profile for IAM user

```bash
# configure profile with credentials for user
# after that you need to edit ~/.aws/config to provide mfa_serial for 2FA
aws configure --profile username@accountalias


# activate particular AWS CLI profile
awsume username@accountalias

# convention that role profiles are capital letter
awsume Admin@accountalias

# example of assuming role in child account
awsume OrganizationAccountAccessRole@accountalias-dev
```

### Configure AWS CLI profile for SSO user (Native AWS tooling)

```bash
# setup SSO profile
aws configure sso --profile SSORoleName@accountalias
# in order to awsume to SSO profile, it requires to be logged first to the SSO session
aws sso login --profile SSORoleName@accountalias

# then activate SSO profike
# you cannot use awsume to SSO profile, since it does not support SSO session
# https://github.com/trek10inc/awsume/issues/192
# so using AWS way to activate SSO profile via env variable
export AWS_PROFILE=admin@sandbox

# check current profile identity
awswhoami
aws sts get-caller-identity
```

### Configure AWS CLI profile for SSO user (via credential_process)

```bash
# setup SSO profile via aws-sso-util
# pip3 install --user --break-system-packages aws-sso-util
aws-sso-util configure profile --sso-start-url "https://SSO_NAME.awsapps.com/start#/" --sso-region "eu-west-1" SSORoleName@accountalias
# in order to awsume to SSO profile, it requires to be logged first to the profile SSO config
aws-sso-util login --profile Admin@mati-dev

# activate AWS CLI profile
awsume SSORoleName@accountalias
```

## Usage

```bash
# check current profile identity
awswhoami
aws sts get-caller-identity

# setup IAM resources
make run MODE=apply
```

## AWS Identity Center With Keycloak as IdP

### Setup SSO

* Spin Keycloak deployment available over internet. For example deploy: [../../gcp/keycloak/](../../gcp/keycloak/).
* Create a Realm in Keycloak
* It is recommended Realm/Login/Email as username is enabled.
*
* Login to AWS console with IAM user of management account capable to access AWS Identity Center (for example `Admin@accountalias` account above)
* Go to AWS Identity Center. Optionally switch to region which should be a host region for Identity Center service (default: us-east-1)
* Enable Identity Center. Select _Choose your identity source_ , select _External identity provider_
* Under Keycloak Go to _Realm settings_ and download: _SAML 2.0 Identity Provider Metadata_
* Come back to AWS console. Under _Identity provider metadata_ upload your Realm Keycloak SAML 2.0 metadata downloaded in previous step.

* Under Service provider metadata click _Download metadata file_

* Under Keycloak your Realm options in Keycloak, click Clients, and click _Import a client_. Pass a metadata file download from AWS console. Click Save.
* Go to new Client settings, and change _IDP-Initiated SSO URL name_ to: `amazon-aws`. Optionally change _Login theme_ to keycloak (it is good looking...). Save.
* Go to _Realm settings_ and download: _SAML 2.0 Identity Provider Metadata_

* Proceed and your basic setup is completed.

* (Optionally) Change alias to _AWS access portal URL_.
Idp users login to AWS not as usual IAM users. They use _AWS access portal URL_ which redirect them do Idp page. Upon successful login AWS access portal shows Accounts where use can login.
The url looks like: <!-- markdown-link-check-disable-line -->https://b-2323443.awsapps.com/start. However the prefix can be change to more human friendly name.
Go to AWS Identity Center dashboard, Go to setting button, Actions and change the prefix for desired one.

### Configure federated user mapping to privileges in AWS

By default there is no automatic mapping for IdP user and Users on AWS side.
For basic setup - SSO and IdP is only to authenticate user. The assumption is that the same user is present in AWS Identity Center Users tab. If you successfully log into: <!-- markdown-link-check-disable-line -->https://youralias.awsapps.com/start - but they user is not present in AWS Identity Center/Users tab - the authentication fails.

You need to ensure that user in Keycloak exists in AWS Identity Center/Users with the same user name [manually](https://docs.aws.amazon.com/singlesignon/latest/userguide/provision-manually.html).
There is a way to [automatically](https://docs.aws.amazon.com/singlesignon/latest/userguide/provision-automatically.html) map user in Idp to user in AWS Identity center via SCIM protocol - however Keycloak does not support it. See [SCIM support #13484 ](https://github.com/keycloak/keycloak/issues/13484). Also [SCIM Keycloak plugin](https://github.com/Captain-P-Goldfish/scim-for-keycloak) is no more open source and [Libre SCIM](https://lab.libreho.st/libre.sh/scim/keycloak-scim) no more works with latest Keycloak

#### Manual mapping user in Keycloak with User in AWS Identity Center

In order to login to AWS:

* Ensure you have at least one user in configured Realm in Keycloak. You can do it in Keycloak Realm/Users configuration or by allowing to create user account upon first login (Realm/Login/User registration enabled, Email as username also enabled)

* Create the same user in AWS Identity Center / Users. The username must match with the username in Keycloak.

* Create a AWS Identity Center / Group and Assign user to it.

* Create AWS Identity Center /Permission sets. For example: create `Admin` Group and assing it to `AdministratorAccess` permission set associated with `AdministratorAccess` policy.

* In IAM Identity Center / AWS accounts page select AWS account and click _Assign users or groups_. Select group and choose permission sets.

* Now you can login to AWS with <!-- markdown-link-check-disable-line -->https://youralias.awsapps.com/start now.

#### Automatic mapping user in Keycloak with User in AWS Identity Center

There is a way to [automatically](https://docs.aws.amazon.com/singlesignon/latest/userguide/provision-automatically.html) map user in Idp to user in AWS Identity center via SCIM protocol.However Keycloak does not support it and [SCIM Keycloak plugin](https://github.com/Captain-P-Goldfish/scim-for-keycloak) is no more open source.
TODO check with Okta Free Trial

### Configure AWS CLI profiles for Identity Center (SSO)

Once the user is able to log into the AWS access portal, configure AWS CLI profiles with the wizard built into AWS CLI v2: `aws configure sso`.
No extra tooling is required - since AWS CLI v2.9 the CLI supports shared `sso-session` sections and refreshes SSO tokens natively.

* Run the wizard. It asks for the SSO session name, the AWS access portal URL (_AWS access portal URL_ from the Identity Center dashboard) and the region hosting Identity Center,
  then opens a browser to authorize the session and finally lets you pick the AWS account and the permission set:

  ```bash
  aws configure sso --profile Admin@accountalias
  ```

  ```txt
  SSO session name (Recommended): accountalias-sso
  SSO start URL [None]: https://youralias.awsapps.com/start
  SSO region [None]: us-east-1
  SSO registration scopes [sso:account:access]:
  # browser opens - approve the request
  There are 2 AWS accounts available to you.
  > accountalias (ACCOUNT_ID)
    accountalias-dev (ANOTHER_ACCOUNT_ID)
  Using the role name "AdministratorAccess"
  CLI default client Region [None]: eu-west-1
  CLI default output format [None]: json
  ```

  Keep the convention that role/permission set profiles start with a capital letter, for example `Admin@accountalias`.

* The wizard appends to `~/.aws/config`. `sso_role_name` is the name of the Identity Center _permission set_, not an IAM role:

  ```txt
  [sso-session accountalias-sso]
  sso_start_url = https://youralias.awsapps.com/start
  sso_region = us-east-1
  sso_registration_scopes = sso:account:access

  [profile Admin@accountalias]
  sso_session = accountalias-sso
  sso_account_id = ACCOUNT_ID
  sso_role_name = AdministratorAccess
  region = eu-west-1
  output = json
  ```

* For every additional account or permission set run `aws configure sso --profile PermissionSetName@accountalias` again and reuse the same
  SSO session name - then a single login covers all of these profiles. The `[sso-session]` block alone can be created with `aws configure sso-session`.
  Profiles may also be added by hand - only the four `sso_*` keys above are needed.

* Log in (token is cached in `~/.aws/sso/cache/`, typically valid for 8 hours) and verify:

  ```bash
  # one login for all profiles sharing the session
  aws sso login --sso-session accountalias-sso
  # or per profile
  aws sso login --profile Admin@accountalias

  aws sts get-caller-identity --profile Admin@accountalias
  awsume Admin@accountalias

  # invalidate cached SSO tokens
  aws sso logout
  ```

  `aws configure sso` logs in as a side effect, so it is only needed once per profile. Afterwards `aws sso login` is used to refresh the expired token
  (`Error loading SSO Token: Token for ... does not exist` or `Token has expired`).

* On a machine without a browser (bastion, container) use `aws sso login --no-browser` (prints the URL to open elsewhere) or `aws sso login --use-device-code`.
