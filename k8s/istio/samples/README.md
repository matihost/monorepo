# Sample Application Exposure via Istio

```bash
# to deploy sample istio application on GKE
# usage for gke deployment
./sample-http-server.sh gke shared1-dev

# usage for minikube deployment
./sample-http-server.sh minikube


# to test application

# from within VPC
curl -kv https://http.internal.gke.shared1.dev.gcp.testing/


# from anywhere
# provide Global LB IP in EXTERNAL_IP
curl -kv --resolve "http.external.gke.shared1.dev.gcp.testing:443:EXTERNAL_IP" https://http.external.gke.shared1.dev.gcp.testing
```
