# Envoy

Deployment of Envoy as systemd service

Deploys Envoy:

* http2https -  exposing envoy on HTTP and routing to HTTPS server
* https2many -  exposing envoy on HTTPS and routing to HTTP or HTTPS server

## Prerequisites

* Ansible

```bash
pip3 install --user ansible
```

* Envoy CLI (for example use `ansible/system` module to deploy it under Ubuntu)

## Running

```bash
# deploys envoy exposing envoy on HTTP and routing to HTTPS server
make deploy-http2https-envoy

# deploys envoy exposing envoy on HTTPS and routing to HTTP or HTTPS server
make deploy-https2many-envoy
```
