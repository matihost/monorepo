# Buildah builder image based on a chosen OS.
# For most cases quay.io/buildah/stable (maintained by Buildah project) is enough, this image exists to
# build with Buildah on top of own base OS.
#
#   BASE_IMAGE=ubuntu:26.04                       (default)
#   BASE_IMAGE=quay.io/centos/centos:stream10
ARG BASE_IMAGE=ubuntu:26.04

FROM ${BASE_IMAGE}
# apt-get or dnf, depending on the base image. netavark is required by buildah to run containers (RUN instructions)
RUN if command -v apt-get >/dev/null 2>&1; then \
      apt-get -y update \
      && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends buildah fuse-overlayfs uidmap netavark crun ca-certificates \
      && rm -rf /var/lib/apt/lists/*; \
    else \
      dnf -y install buildah fuse-overlayfs shadow-utils \
      && dnf clean all; \
    fi
COPY storage.conf /etc/containers/storage.conf
# chroot isolation does not need privileges to create namespaces inside of a container
ENV BUILDAH_ISOLATION=chroot
RUN mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers \
  && touch /var/lib/shared/overlay-images/images.lock /var/lib/shared/overlay-layers/layers.lock
CMD ["buildah"]
