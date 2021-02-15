# Sample Application Exposure via Istio

```bash
# to deploy sample istio application on GKE
./sample-istio-on-gke.sh shared1-dev

# to expose Istio exposed via GKE NEG inventory via Global GCP LoadBalancers
cd istio-global-lb-setup && make apply

# to test application

# from within VPC
curl -kv https://http.internal.gke.shared1.dev

# from anywhere
# provide Global LB IP in EXTERNAL_IP
curl -kv --resolve "http.external.gke.shared1.dev:443:EXTERNAL_IP" https://http.external.gke.shared1.de
```
