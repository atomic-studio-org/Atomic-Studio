#!/usr/bin/env -S nu
let FEDORA_MAJOR_VERSION = (rpm -E %fedora)
let REPO_FILE_PATH= "/etc/yum.repos.d/_copr_sentry-kernel-fsync.repo"
  
wget $"https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/repo/fedora-($FEDORA_MAJOR_VERSION)/sentry-kernel-fsync-fedora-($$FEDORA_MAJOR_VERSION).repo" -O $REPO_FILE_PATH

rpm-ostree cliwrap install-to-root /
rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:sentry:kernel-fsync kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-uki-virt

rm -f $REPO_FILE_PATH
