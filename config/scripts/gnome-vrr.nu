#!/usr/bin/env -S nu

let FEDORA_MAJOR_VERSION = (run-external --redirect-combine rpm '-E' '%fedora' | complete).stdout
const REPO_PATH = "/etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo"

http get $"https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/repo/fedora-($FEDORA_MAJOR_VERSION)/kylegospo-gnome-vrr-fedora-($FEDORA_MAJOR_VERSION).repo" | save -f $REPO_PATH 

run-external rpm-ostree override replace '--experimental' '--from' repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr mutter mutter-common gnome-control-center gnome-control-center-filesystem

rm -f $REPO_PATH
