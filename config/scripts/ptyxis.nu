#!/usr/bin/env -S nu 

use lib/std.nu [ARCH]

let FEDORA_MAJOR_VERSION = (run-external --redirect-combine rpm '-E' '%fedora' | complete).stdout
const COPR_FILE = "/etc/yum.repos.d/_copr_ublue-os-staging.repo"

http get $"https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-($FEDORA_MAJOR_VERSION)/ublue-os-staging-fedora-($FEDORA_MAJOR_VERSION).repo?arch=($ARCH)" | save -f $COPR_FILE 

rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:ublue-os:staging libadwaita gtk4 vte291 vte-profile
rpm-ostree install ptyxis

rm -f $COPR_FILE 
