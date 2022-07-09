# Terraform :: Sample GCP Instance

Setup single Google Compute Engine (GCE) instance in default VPC (us-central-1) with Ngnix server on it.
Present basic Terraform feature

Use  GCP resources eliglible to [GCP Free Tier](https://cloud.google.com/free/docs/gcp-free-tier#free-tier-usage-limits) __only__.

## Prerequisites

* Logged to Google Console Account

```bash
make google-authentication
```

* Latest Terraform installed

## Usage

```bash
# deploy VM instance and related resources
make run

# connects to VM intances Nginx
make test

# ssh to VM instance (using ssh cli)
make ssh

# ssh to VM unstance (using gcloud compute ssh)
make gssh

# show Terraform state
make show-state

# terminates all GCP resources created with apply task
make run MODE=destroy
```

## Troublesshoot

```bash
make ssh
# check google-startup-scripts service status/logs
sudo systemctl status google-startup-scripts
sudo journalctl -u google-startup-scripts
```
