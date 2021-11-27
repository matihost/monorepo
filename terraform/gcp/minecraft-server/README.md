# Minecraft Server instance

Spawns a Minecraft Server

Features:

* Exposes Minecraft server and Minecraft RCON (password protected)

* Exposes Minecraft as single instance template exposed via external GCP Network Loadbalancer.

* Minecraft server starts with single whitelisted & op (aka admin) user. To allow other users to connect - op user has to join server and whitelist users via command: `/whitelist add username`

* Minecraft server world and configuration is automatically backup each hour to Cloud Storage. When server crashes - after 200 seconds of inactivity - the instance is recreated. Upon startup , the last backup is downloaded, otherwise it creates a new fresh world. Upon ordinary reboot, the backup is not downloaded.

* Minecraft server is automatically shutdown (instanceGroup is scaled to 0) at 10:30 PM and automatically started at 10:00 AM every day.

Limitations:

* public DNS is not create, requires separated public DNS for Minecraft server LB external IP

## Prerequisites

* Terraform `../gcp-iam` has been deployed - for custom IAM roles setup

* Terraform `../gcp-network-setup` has been deployed - for networking setup

* Cloud Scheduler requires AppEngine setup in your GCP project in the same region where you intent do deploy app.

## Usage

```bash
# setup Minecraft Server
make apply PASS=pass_for_minecraft_rcon OP_USER=minecraftusername [REGION=europe-central2]

# ssh to Minecraft Server instance
make ssh

# show terraform.state
make show-state
# destroy Minecraft Server resources
make destroy
```
