# Terraform :: EKS  deployment

Terraform scripts deploy EKS

In particular it creates:

- EKS with Auto mode - with two NodePools:
  - `system` - buildin for critical workflows
  - custom `compute` for workflows
- Cloud Watch, EFS and CSI Snapshots addons
- K8S metrics server on `system` nodepool
- ExternalDNS
- Private DNS Route53 zone
- Configure storage, ingress, node pool classes
- Configure app namespaces (quota, limits, networkpolicies)
  - For each managed namespace creates `edit` and `view` rolebinding for Groups `NSNAME-edit` and `NSNAME-view`
  - Assign optionally `EKS Pod Identity Role` to namespace `app` Service Account.
  - Assign optionally `IRSA` to namespace `app-irsa` Service Account.
- Configure OIDC authen & authz (Keycloak tested) with Group
  - Add ClusterRoleBinding allowing `cluster-admin` for Group: `cluster-admins`
- (Optional) NGNIX ingress controller backed by internal NLB

## Prerequisites

- The scripts assume that [aws-network-setup](../aws-network-setup) is already deployed (aka private networking is present).

- (Optionally) Keycloak with realsm and OIDC client id with group propagation mapper. It can be the same Keycloak realm instance provisioned for [aws-iam-management](../aws-iam-management#), but here:

  - it has to be true TLS (not self-signed),
  - exposed to the internet
  - wit Valid redirect URIs containing: `http://localhost:8000/*`
  - OIDC instead of SAML as client id with Client authentication enabled (standard flow) with client_id/secret authentication
  - with Client Scope / dedicated eks-dedicated added custom mapper with `Mapper type`: `Group Membership` with `Full group path` option disabled and `Token Claim Name` and `Name` equal to `groups`)

  You can also spin Keycloak deployment directly. For example deploy: [../../gcp/keycloak/](../../gcp/keycloak/).

- Latest Terraform or OpenTofu, Terragrunt installed

- jq, kubectl, krew tools installed

- Kubectl OIDC plugin:

```bash
kubectl krew install oidc-login
```

- EKS CTL CLI installed (optionally):

```bash
curl -sSL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar -zx -o eksctl
sudo mv eksctl /usr/local/bin
```

- Logged to AWS Account and ensure Default Region is set.

```bash
aws configure
```

## Usage

```bash

# deploys EKS
make run ENV=dev MODE=apply

# show Terraform state
make show-state ENV=dev

# create kubeconfig - with current IAM authenticated user/role as kubectl user
make kubeconfig


# test OIDC setup and provide instructions to update ~/.kube/config to use it
 export CLIENT_SECRET=...clientid_secret_from_keycloak....
make oidc-test ISSUER_URL=https://id.yoursite.com/realms/yourrealm CLIENT_ID=eks

# when all is ok, JWT token contains valid claims (especially groups) then

# create ~/.kube/config entry for EKS access (using public API endpoint) with user authentication via OIDC
make kubeconfig-oidc ISSUER_URL=https://id.yoursite.com/realms/yourrealm CLIENT_ID=eks
```

## Day 2 Operations

### Login to cluster via commandline

```bash
# create ~/.kube/config entry for EKS
make kubeconfig

# open the best k8s dashboard
k9s
```
