#!/usr/bin/env bash
set -euo pipefail

ARCH=$(uname -i)
FEDORA_MAJOR_VERSION=$(rpm -E %fedora)
REPO_FILE_PATH=/etc/yum.repos.d/_copr_ycollet-audinux.repo
  
wget https://copr.fedorainfracloud.org/coprs/ycollet/audinux/repo/fedora-${FEDORA_MAJOR_VERSION}/ycollet-audinux-fedora-${FEDORA_MAJOR_VERSION}.repo \
 -O $REPO_FILE_PATH

rpm-ostree cliwrap install-to-root /
rpm-ostree override replace \
    --experimental \
    --remove=kernel \
    --remove=kernel-core \
    --remove=kernel-modules \
    --remove=kernel-headers \
    --remove=kernel-devel \
    --from repo=copr:copr.fedorainfracloud.org:ycollet:audinux \
    kernel-rt-mao

RUN 
     && \
    rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:sentry:kernel-fsync \
        kernel \
        kernel-core \
        kernel-modules \
        kernel-modules-core \
        kernel-modules-extra \
        kernel-uki-virt


rm -f $REPO_FILE_PATH
