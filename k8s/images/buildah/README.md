# Buildah builder

Container image with [Buildah](https://buildah.io/) which allows building container images
from inside of a container (for example in a Kubernetes Pod) without Docker daemon.

For most cases the official image maintained by Buildah project is the best choice: `quay.io/buildah/stable`.
This directory builds Buildah on top of own base OS, and contains the Pod manifest to run it.

Supported base OS (`BASE_OS`):

* `ubuntu` (default) - Ubuntu 26.04
* `centos` - CentOS Stream 10
* `original` - official `quay.io/buildah/stable` (only for `run`, `deploy`, `un-deploy`)

```bash
# build the image, the result: quay.io/matihost/buildah:<BASE_OS>
make build [BASE_OS=ubuntu|centos]

# run bash inside of the image
make run [BASE_OS=ubuntu|centos|original]

# verify that the image can build an image
make test-build-image [BASE_OS=ubuntu|centos|original]

# push to quay.io (assume docker login quay.io has been performed)
make push [BASE_OS=ubuntu|centos]

# deploy buildah Pod in the current Kubernetes context
make deploy [BASE_OS=ubuntu|centos|original]
make un-deploy [BASE_OS=ubuntu|centos|original]
```

The images run as root and use `chroot` isolation (`BUILDAH_ISOLATION=chroot`), which does not require creating
namespaces inside of the container. Building images still needs `/dev/fuse` (for `fuse-overlayfs`) and
relaxed seccomp profile, `make run` passes them. See `pod.manifest.yaml` for the Kubernetes equivalent.

## Rootless (non-root) usage

Running Buildah as an arbitrary non-root user (for example OpenShift random UID) is not supported by these images.
Without subuid/subgid ranges Buildah falls back to a single UID mapping and extracting image layers
which contain files owned by other users fails. Use the official `quay.io/buildah/stable` image and its `build` user
and follow [Buildah rootless tutorial](https://github.com/containers/buildah/blob/main/docs/tutorials/05-openshift-rootless-build.md).
