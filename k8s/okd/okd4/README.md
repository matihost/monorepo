# OKD 4 on GCP

Install OKD 4.x on GCP as [private cluster on already present VPC](https://docs.okd.io/latest/installing/installing_gcp/installing-gcp-vpc.html)

## Prerequisites

* GCP Service Account Key file

```bash
cd files/gcp-prerequisites
mkdir -p target
make run
make use-okd-installer-sa
make get-okd-installer-sa-key > target/key.json
```

* GCP Network with own VPC (see the repo `terraform/gcp/gcp-network-setup`)

  * Ensure port 6443 is open to traffic (API server)

  * Ensure you have VPN to the VPC network as cluster is created in private mode. (see `terraform/gcp/gcp-open-vpn`)
  Both API server and Ingress are exposed via Internal TCP Load Balancer.
  The ingress ILB is set to be GlobalAccess so that it is accessible via VPN.
  However API server is not.
  You may need to manually switch it during installation. See Warning below.

* If you use GCP Free Tier,select different region than your usual workloads and ensure you do not use too big SSD for OKD control plane - to ensure your quota is enough.

## Cluster creation

```bash
# deploys OKD with cluster name and path to GSA key
./create-cluster.sh -n okd -k files/gcp-prerequisites/target/key.json
# or
# ./create-cluster.sh okd files/gcp-prerequisites/target/key.
```

### Warnings

* When installer freezes on:

  `DEBUG Still waiting for the Kubernetes API: Get "https://api.okd.dev.gcp.testing:6443/version": dial tcp 10.14.0.3:6443: i/o timeout`

  then:

  * ensure you run your installer from within VPC or via VPN.

  * then go to ILB of OKD API to GCP Cloud Console and set Global Access flag to Enable so that it has cross regional access.

* Upon any cluster problem upon creation - do not repeat `create-cluster.sh` script invocation as openshift-install is not idempotent - especially when it comes to create GCP objects. The only way to repeat is to destroy cluster first - see below.

* The whole procedure tooks around ~43 minutes to spin cluster

## Cluster destruction

```bash
./destroy-cluster.sh okd files/gcp-prerequisites/target/key.json
```
