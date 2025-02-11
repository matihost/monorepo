# Terraform :: ARO

Setup Azure RedHat OpenShift (ARO)

## Prerequisites

* Latest Terragrunt/OpenTofu installed
*
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)

* Azure Subscription.

* Logged to Azure Subscription:

  ```bash
  make login
  ```

* Initialize Azure Storage Account and Container for keeping Terraform state

  ```bash
  make init
  ```

* [../azure-entraid](../azure-entraid) - installed for the same stage environment (contains resource group and policies)

* [../azure-network-setup](../azure-network-setup) - installed for the same stage environment (contains resource group and policies)

* Obtain RedHat Pull Secret for ARO. Go to: [ARO Redhat Hybrid Console](https://console.redhat.com/openshift/install/azure/aro-provisioned). It is needed to be placed as RH_PULL_SECRET environment variable. It contains authentication for RedHat image registries:

```bash
# sample storage pull secret as env variable
export RH_PULL_SECRET='{"auths":{"cloud.openshift.com":{"auth":"...","email":"x.y@z.com"},"quay.io":{"auth":"...","email":"x.y@z.com"},"registry.connect.redhat.com":{"auth":"...","email":"x.y@z.com"},"registry.redhat.io":{"auth":"...","email":"x.y@z.com"}}}'
```

## Usage

```bash
# ensure you obtained Pull Secret for RH Registries from RH Hybrid Console, see Prerequisites
export RH_PULL_SECRET='....'

# setup ARO
make run MODE=apply [ENV=dev-northeurope-shared1]

# configure kubeconfig with break-glass credentials (kubeadmin) for oc (CLI) access
make kubeconfig [ENV=dev-northeurope-shared1]
k9s

# retrieve ARO break glass (kubeadmin with cluster admin privileges) credentials
make get-break-glass-credentials [ENV=dev-northeurope-shared1]

# open ARO Web Console (you can use break glass credentials obtained with previous steps)
make open-webconsole [ENV=dev-northeurope-shared1]
```

## Day 2 Procedures

### Add / Update Pull Secret

RH pull secret should be obtained with [Prerequisites](#prerequisites) step and provided as part of cluster buildout.

This procedure is to update the pull secret or add other cluster wide Docker Container Registry access:
[How to add or update pull secrets](https://learn.microsoft.com/en-us/azure/openshift/howto-add-update-pull-secret)

### Service Principal Credentials Auto Rotation

ARO cluster needs Service Principal with NetworkContributor role in other to modify Machine Set or use other Azure API (storage etc). However the Service Principal secret expires and needs to be refreshed.

```bash
# get Service Principal expiration date
make get-sp-expiration-date [ENV=dev-northeurope-shared1]

# rotate SP credentials, will check if the service principal exists and rotate or create a new service principal
make rotate-sp-credentials [ENV=dev-northeurope-shared1]
```

Follow
[Automates Service Principal Credential Rotation](https://learn.microsoft.com/en-us/azure/openshift/howto-service-principal-credential-rotation#automated-service-principal-credential-rotation-) procedure.

### Changing Worker Nodes Size

Follow [Upgrading Infrastructure and Worker Node VM Sizes in ARO](https://access.redhat.com/solutions/7022857) procedure.

### Refresh Machines

Follow: [Deleting a machine](https://docs.redhat.com/en/documentation/openshift_container_platform/4.15/html/machine_management/deleting-machine) procedure.

Retrieve all machines:

```bash
oc get machine -n openshift-machine-api
```

For each worker machine:

```bash
oc delete machine <worker-machine> -n openshift-machine-api
```

Wait for a new machine to be automatically set up.

Once the new node and applications return to the Ready state:

```bash
oc get no
oc get po -A -o wide | grep <new_node_name>
```

Repeat for the next machine as needed.

### Cluster Upgrade

#### Upgrade Prerequisites

Ensure all installed operators (especially from operator hub like ServiceMesh) supports current and and next OCP version. Ensure both operator and its installation is updated.

Verify that the cluster is in a ready state for an upgrade:

```bash
# check any issues
oc adm upgrade
```

Ensure that all Upgradeable=False conditions are resolved.

Possible known issues:

* If MCP is preventing the upgrade with the error:    "Cluster operator machine-config should not be upgraded between minor versions: PoolUpdating: One or more machine config pools are updating. Please see oc get mcp for further details." Follow: https://access.redhat.com/solutions/6012101

#### Upgrade Procedure

Update the channel to the next version stable-4.xx version:

```bash
oc adm upgrade channel stable-4.xx
```

WARNING: Wait until OCP downloads all possible versions eligible for migration. Initially, the new channel may show a limited number of available versions. Be patient.

Verify the intended version is listed as an available upgrade option:

```bash
oc adm upgrade
```

Ensure no `Upgradeable=False` conditions exist. See [Known issues](#upgrade-prerequisites).

Trigger the upgrade when ready:

```bash
oc adm upgrade --to=4.xx.xx
```

Monitor the upgrade process using the OCP Web Console or CLI:

```bash
for ((;;)); do
    sleep 30
    oc adm upgrade  # Check cluster upgrade status
    oc get clusteroperator  # Check operator upgrade status
    oc get no  # Check node patching status
done
```

WARNING: The upgrade process may display several errors, which are often false alarms. If the upgrade appears stuck, investigate:

```bash
# Check upgrade-related pods
oc get po -n openshift-cluster-version -o wide

# View version upgrade logs
oc logs version-4.xx.xx-xxxxx-xxxxx -n openshift-cluster-version

# Check operator logs
oc logs cluster-version-operator-xxxxxx-xxxxx -n openshift-cluster-version
```

#### Post-upgrade steps

Verify all pods are running or completed:

```bash
oc get po -A
```

Check cluster version:

```bash
oc get clusterversion
```

(Optionally) Follow [Refresh Machines](#refresh-machines) for worker nodes as ARO upgrades nodes in place.
