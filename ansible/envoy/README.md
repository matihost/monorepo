# Envoy

Deployment of Envoy as systemd service

Deploys Envoy:

* http2https - forwarding local http port to remote https endpoint

## Prerequisites

* Ansible

```bash
pip3 install --user ansible
```

* Envoy CLI (for example use `ansible/system` module to deploy it under Ubuntu)

## Running

```bash
# deploy envoy with http2https config
make deploy-http2https-envoy
```
