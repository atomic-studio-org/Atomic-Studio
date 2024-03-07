#!/usr/bin/env -S nu
#
use lib/std.nu [ARCH]

let FEDORA_MAJOR_VERSION = (run-external --redirect-combine rpm '-E' '%fedora' | complete).stdout
const COPR_FILE = "/etc/yum.repos.d/_copr_gloriouseggroll-nvidia-explicit-sync.repo"

http get $"https://copr.fedorainfracloud.org/coprs/gloriouseggroll/nvidia-explicit-sync/repo/fedora-($FEDORA_MAJOR_VERSION)/gloriouseggroll-nvidia-explicit-sync-fedora-($FEDORA_MAJOR_VERSION).repo?arch=($ARCH)" | save -f $COPR_FILE

rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:gloriouseggroll:nvidia-explicit-sync xorg-x11-server-Xwayland

rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:gloriouseggroll:nvidia-explicit-sync egl-wayland

rm $COPR_FILE
