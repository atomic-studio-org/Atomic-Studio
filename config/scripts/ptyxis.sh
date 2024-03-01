#!/usr/bin/env bash
set -euo pipefail

ARCH="x86_64"
FEDORA_MAJOR_VERSION=$(rpm -E %fedora)

wget https://copr.fedorainfracloud.org/coprs/kylegospo/prompt/repo/fedora-/kylegospo-prompt-fedora-${FEDORA_MAJOR_VERSION}.repo?arch=${ARCH} \
 -O /etc/yum.repos.d/_copr_kylegospo-prompt.repo

rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:prompt \
    vte291 \
    vte-profile \
    libadwaita

rpm-ostree install ptyxis

rm -f /etc/yum.repos.d/_copr_kylegospo-prompt.repo
