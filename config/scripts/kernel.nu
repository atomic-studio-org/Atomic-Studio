#!/usr/bin/env -S nu
let FEDORA_MAJOR_VERSION = (run-external --redirect-combine rpm '-E' '%fedora' | complete).stdout
const COPR_FILE = "/etc/yum.repos.d/_copr_whitehara-kernel-tkg.repo"
  
http get $"https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg/repo/fedora-($FEDORA_MAJOR_VERSION)/whitehara-kernel-tkg-fedora-($FEDORA_MAJOR_VERSION).repo" | save -f $COPR_FILE 

rpm-ostree cliwrap install-to-root /

rpm-ostree override replace --experimental --from repo='copr:copr.fedorainfracloud.org:whitehara:kernel-tkg' kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-uki-virt

rm -f $COPR_FILE
