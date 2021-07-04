# Minecraft Server instance

Spawns a Minecraft Server

Exposes Minecraft server and Minecraft RCON (password protected)

Exposes Minecraft as singe intance template exposed via external GCP Network Loadbalancer.

TODOs/Limitations:

* requires separated external DNS for Minecraft server external IP

* automatic backup to GS

## Prerequisites

* Terraform `../gcp-network-setup` has been deployed

## Usage

```bash
# setup Minecraft Server VM
make apply PASS=pass_for_minecraft_rcon

# ssh to Minecraft Server instance
make ssh

# show terraform.state
make show-state
# destroy Minecraft Server resources
make destroy
```
