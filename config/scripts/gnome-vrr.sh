#!/usr/bin/env bash
set -euo pipefail

FEDORA_MAJOR_VERSION=$(rpm -E %fedora)

wget https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-gnome-vrr-fedora-"${FEDORA_MAJOR_VERSION}".repo \
 -O /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo

rpm-ostree override replace --experimental \
    --from repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr mutter mutter-common gnome-control-center gnome-control-center-filesystem

rm -f /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo
