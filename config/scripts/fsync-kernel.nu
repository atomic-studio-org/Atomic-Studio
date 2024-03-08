#!/usr/bin/env -S nu
let FEDORA_MAJOR_VERSION = (run-external --redirect-combine rpm '-E' '%fedora' | complete).stdout
const COPR_FILE = "/etc/yum.repos.d/_copr_sentry-kernel-fsync.repo"
  
http get $"https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/repo/fedora-($FEDORA_MAJOR_VERSION)/sentry-kernel-fsync-fedora-($$FEDORA_MAJOR_VERSION).repo" | save -f $COPR_FILE 

rpm-ostree cliwrap install-to-root /
rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:sentry:kernel-fsync kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-uki-virt

rm -f $COPR_FILE
