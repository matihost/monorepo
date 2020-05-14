# Buildah builder

```bash

# build buildah image
BASE_OS=centos make build
BASE_OS=ubuntu make build


# run buildah with bash as cmd
BASE_OS=centos make run
BASE_OS=ubuntu make run


# deploy buildah in currect context K8S
# not yet work
BASE_OS=centos make deploy

# deploys original buildah image from quay
BASE_OS=original make deploy

# deploy buildah in currect context K8S
# not yet work
BASE_OS=centos make build

```
