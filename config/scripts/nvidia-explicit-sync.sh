#!/usr/bin/env bash

COPR_FILE="/etc/yum.repos.d/_copr_gloriouseggroll-nvidia-explicit-sync.repo"
ARCH="x86_64"
FEDORA_MAJOR_VERSION=$(rpm -E %fedora)
wget "https://copr.fedorainfracloud.org/coprs/gloriouseggroll/nvidia-explicit-sync/repo/fedora-${FEDORA_MAJOR_VERSION}/gloriouseggroll-nvidia-explicit-sync-fedora-${FEDORA_MAJOR_VERSION}.repo?arch=${ARCH}" -O $COPR_FILE

rpm-ostree override replace \
  --experimental \
  --from repo=copr:copr.fedorainfracloud.org:gloriouseggroll:nvidia-explicit-sync \
    xorg-x11-server-Xwayland

rpm-ostree override replace \
  --experimental \
  --from repo=copr:copr.fedorainfracloud.org:gloriouseggroll:nvidia-explicit-sync \
    egl-wayland || true

rm $COPR_FILE
