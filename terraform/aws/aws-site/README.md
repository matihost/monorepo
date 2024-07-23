# Terraform :: Static site with S3

Setup the following resources :

* a bucket with name of your intended DNS of the site ([AWS requirement that endpoint matches the bucket name](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteEndpoints.html?icmpid=docs_amazons3_console#website-endpoint-dns-cname))

* bucket is opened to read from the public internet from a bucket level and a bucket IAM resource policy level. See [Prerequistes](#prerequisites) for instruction how to open the S3 bucket on AWS account level. W/o it site cannot be exposed.

* bucket is configured as a static site

* index.html and error.html S3 objects

## Prerequisites

* AWS Account. AWS FreeTier Account is ok. With [AWS S3 FreeTier](https://aws.amazon.com/free/storage/s3/) - if your site is low popular - you may have this hosting totally for free for a year.

* Logged to AWS Account. Preferable AWS linked account.

* Opened S3 public access on account level. See [instructions](https://docs.aws.amazon.com/AmazonS3/latest/userguide/configuring-block-public-access-account.html). Site is exposed via S3 bucket. AWS block public access on AWS account level, on a bucket level and on a bucket resource policy IAM level. This module opens access on the bucket and the bucket resource IAM policy level.
You need to open it on the AWS account level. As it is the AWS account level config - it cannot be part of this module.
You may run  [../aws-iam-linked](../aws-iam-linked) module - which is opinionated IAM config for typical AWS linked account.

* Ensure you have DNS domain for [stage/dev/terragrunt.hcl#dns](stage/dev/terragrunt.hcl). Change dns variable to meet DNS domain you wish site will be accessible from internet. For HTTP only - I use free DNS subdomains from [https://freedns.afraid.org/](https://freedns.afraid.org/). With AWS Free Tier and FreeDNS you may serve a little site with low volume - totally for free for a year.

* Latest Terraform/OpenTofu and Terragrunt installed

## Usage

```bash
# setup S3 based site
make run MODE=apply


# test availbility of AWS S3 site addresses
make test-s3
make test-site


# when works
# show the domain you should now edit your DNS provider
make get-cname-target

# it will return you the domain you should create CNAME record pointing your site domain to this
# example for FreeDNS provider:
# matihost.mooo.com  CNAME  matihost.mooo.com.s3-website-us-east-1.amazonaws.com

# when done, check and wait until your domain is correctly propagated to public resolvers
# sample:
make check-dns DOMAIN=matihost.mooo.com
```
