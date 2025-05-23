# Terraform :: Static site with S3

Setup the following resources :

* a bucket with name of your intended DNS of the site ([AWS requirement that endpoint matches the bucket name](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteEndpoints.html?icmpid=docs_amazons3_console#website-endpoint-dns-cname))

* bucket is opened to read from the public internet from a bucket level and a bucket IAM resource policy level. See [Prerequistes](#prerequisites) for instruction how to open the S3 bucket on AWS account level. W/o it site cannot be exposed.

* bucket is configured as a static site

* index.html and error.html S3 objects

* (Optionally) IAM certificate and CloudFront distribution for HTTPS exposure

## Prerequisites

* AWS Account. AWS FreeTier Account is ok. With [AWS S3 FreeTier](https://aws.amazon.com/free/storage/s3/) - if your site is low popular - you may have this hosting totally for free for a year.

* Logged to AWS Account. Preferable AWS linked account.

* Opened S3 public access on account level. See [instructions](https://docs.aws.amazon.com/AmazonS3/latest/userguide/configuring-block-public-access-account.html). Site is exposed via S3 bucket. AWS block public access on AWS account level, on a bucket level and on a bucket resource policy IAM level. This module opens access on the bucket and the bucket resource IAM policy level.
You need to open it on the AWS account level. As it is the AWS account level config - it cannot be part of this module.
You may run  [../aws-iam-linked](../aws-iam-linked) module - which is opinionated IAM config for typical AWS linked account.

* Ensure you have DNS domain for [stage/dev/terragrunt.hcl#dns](stage/dev/terragrunt.hcl). Change dns variable to meet DNS domain you wish site will be accessible from internet. For HTTP only - I use free DNS subdomains from [https://freedns.afraid.org/](https://freedns.afraid.org/). With AWS Free Tier and FreeDNS you may serve a little site with low volume - totally for free for a year.

* Latest Terraform/OpenTofu and Terragrunt installed

## Deployment (with HTTP only)

* Ensure `enable_tls` variable is `false` (which is default when not provided).

* WARNING: Ensure you do not have deployed Resource Control Policy (RCP) `EnforceConfusedDeputyProtection` in the account as it block all unauthenticated access to S3.

Access to S3 is blocked by RCP ConfusedDeputyProtection which allow only Authenticated access from current Organization
If you wish that S3 content is exposed via HTTP directly from S3 Website Exposure - ensure RCP does not prevent it.

```bash
# show expected changes tp the infrastructure,
# variable MODEs: plan, apply, destroy,  optional ENV a directory under stage directory
make run MODE=plan [ENV=dev]

# when changes are valid, apply them
make run MODE=apply [ENV=dev]


# test availbility of AWS S3 site addresses
make test-s3
make test-site


# when works
# show the domain you should now edit your DNS provider
make get-cname-target-fors3site

# it will return you the domain you should create CNAME record pointing your site domain to this
# example for FreeDNS provider:
# matihost.mooo.com  CNAME  matihost.mooo.com.s3-website-us-east-1.amazonaws.com

# when done, check and wait until your domain is correctly propagated to public resolvers
# sample:
make check-dns DOMAIN=matihost.mooo.com
```

## HTTPS exposure

HTTPs exposure requires additional steps.

* Obtain a Domain. It can be free FreeDNS public subdomain - This repo was tested with FreeDNS provider as well.

  * However FreeDNS DNS changes propagation is slow (CloudFlare's resolver 1.1.1.1 even 1h to wait, Google's resolver: 8.8.8.8 - a bit faster).
  HTTPS exposure in this repository - relies on the fact that first you expose HTTP endpoint directly from S3 so that Let's Encrypt can use HTTP method to prove that you own the domain - and FreeDNS supports that method for public, free, FreeDNS subdomain.
  However  Let's Encrypt offers other method of verification via DNS TXT which [is not supported](https://github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_freedns) if you use FreeDNS public subdomain. TXT method is supported from FreeDNS if you buy top level domain from FreeDNS.

  * Recommended is to buy a domain for HTTPS exposure. It does not have to be Route53 from AWS. It can be whatever Domain provider allowing you manually define CNAME records.

  * You only need a domain. You don't need additional services from Domain provider. TLS certificate is taken from free Let's Encrypt provider.

* Decide about subdomain for the site (for example: [www.mydomain.com](www.mydomain.com) when you own [mydomain.com](mydomain.com))

* If you want to use Let's Encrypt HTTP method of verification - first follow [deployment for HTTP](#deployment-with-http-only) with  `enable_tls` being `false` (which is default) to deploy HTTP only.
Ensure you have working [http://www.mydomain.com](http://www.mydomain.com) site point to S3 site url as CNAME
This method requires - you do not have enabled RCP on S3 on the account - as it block all unathenticated access to S3.

Generate TLS certificate via Let's Encrypt: (certbot tool required):

```bash
make generate-letsencrypt-cert MAIN_DOMAIN=www.mydomain.com DOMAINS=www.mydomain.com,mydomain.com
```

Follow instruction on the screen. Essentially you need to create a file and place it under `.well-known/acme-challenge/` location in the S3 site bucket. This is the proof that you control the site - and hence Let's Encrypt will generate TLS certificate for free for 3 months,
The make script also copies the generated certificate to `~/.tls` directory so that next Terraform invocation can access it.

_Warning_: If you intent to run deployment of this module from GitHub Actions `CD` workflow, not from your local environment - you need to place/change these files as GitHub Actions Environment secrets `TLS_CRT`, `TLS_CHAIN`, `TLS_KEY` respectively.

* If you want to use Let's Encrypt TXT method of verification - you can deploy your version at once

```bash
make generate-letsencrypt-cert MAIN_DOMAIN=www.mydomain.com DOMAINS=www.mydomain.com,mydomain.com TLS_MODE=TXT
```

Follow instructions on the screen (aka edit your DNS TXT entry).

* Change `enable_tls` variable to `true` in your Terragrant config.
It will create IAM certificate and create CloudFront distribution as well point to your S3 (not to S3 HTTP Website).
Since it is CloudFront pointing to S3 - RCP preventing unauthenticated/confused deputy access can stay.

    ```bash
    make run ENV=prod MODE=apply
    ```

* Get CloudFront distribution domain:

    ```bash
    make get-cname-target-for-cloudfront ENV=prod
    ```

* Edit your subdomain to point it as CNAME to CloudFront distribution:

    ```txt
    www.mydomain.com  CNAME  dtr34sdfslzye.cloudfront.net
    ```

### Cleaning

* It is [recommended](https://repost.aws/questions/QUAlePGv3PSkmeeEVfRVKpVw/cloudfront-distribution-cannot-be-removed) to detach CNAME and certificate from CLoudFront distribution before actually removing it.

* Then remove objects:

    ```bash
    make run MODE=destroy ENV=prod
    ```

* But also **remove CNAME record from your domain name pointing to CloudFront distribution**!
If you don't do and you want to recreate CloudFront distribution using same alias/CNAME - it will be rejected with [error](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/troubleshooting-distributions.html#troubleshoot-incorrectly-configured-DNS-record-error).

* If you want to recreate deployment - please bear in mind this repo uses S3 bucket being name of your site DNS (see [prerequisites](#prerequisites) why). S3 buckets are globally unique and information about bucket is eventual consistent.. Translating to human language:
When you remove S3 bucket and you want to create it again - [you may need to wait from several minutes to several hours](https://serverfault.com/a/770488) - for AWS to let you create S3 bucket with the same name.

### Refresh TLS certificate

Let's Encrypt TLS certificate is valid for 3 months.
Run these steps before certificate is invalid:

```bash
# regenerate TLS certificate
make generate-letsencrypt-cert MAIN_DOMAIN=www.mydomain.com DOMAINS=www.mydomain.com,mydomain.com

# check proposed changes
make run MODE=plan ENV=prod


# when TLS certificate is to be changed and CloudFront distribution - apply
make run MODE=apply ENV=prod

# or
#
# if you run deployment from GitHub Actions CD workflow
# change GitHub Actions Environment secrets `TLS_CRT`, `TLS_CHAIN`, `TLS_KEY` and re-run CD workflow for that environment
```
