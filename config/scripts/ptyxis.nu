#!/usr/bin/env -S nu 
use lib/std.nu [get_arch, fedora_version, fetch_copr]

let ARCH = (get_arch)
let FEDORA_MAJOR_VERSION = (fedora_version)
let COPR_FILE = (fetch_copr https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-($FEDORA_MAJOR_VERSION)/ublue-os-staging-fedora-($FEDORA_MAJOR_VERSION).repo?arch=($ARCH))

rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:ublue-os:staging vte291 vte-profile
rpm-ostree install ptyxis

rm -f $COPR_FILE 
