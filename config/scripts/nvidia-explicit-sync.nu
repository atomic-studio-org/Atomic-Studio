#!/usr/bin/env bash

use lib/std.nu [FEDORA_MAJOR_VERSION, ARCH]

const COPR_FILE = "/etc/yum.repos.d/_copr_gloriouseggroll-nvidia-explicit-sync.repo"

http get $"https://copr.fedorainfracloud.org/coprs/gloriouseggroll/nvidia-explicit-sync/repo/fedora-($FEDORA_MAJOR_VERSION)/gloriouseggroll-nvidia-explicit-sync-fedora-($FEDORA_MAJOR_VERSION).repo?arch=($ARCH)" | save -f $COPR_FILE

rpm-ostree override replace \
  --experimental \
  --from repo=copr:copr.fedorainfracloud.org:gloriouseggroll:nvidia-explicit-sync \
    xorg-x11-server-Xwayland

rpm-ostree override replace \
  --experimental \
  --from repo=copr:copr.fedorainfracloud.org:gloriouseggroll:nvidia-explicit-sync \
    egl-wayland

rm $COPR_FILE
