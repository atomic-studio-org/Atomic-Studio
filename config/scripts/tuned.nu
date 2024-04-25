#!/usr/bin/env -S nu
use lib/std.nu [fetch_copr, get_fedora_version]

try { rpm-ostree override remove power-profiles-daemon } catch { echo "Failed removing ppd" }

let FEDORA_MAJOR_VERSION = (get_fedora_version)
let COPR_FILE = (fetch_copr $"https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-($FEDORA_MAJOR_VERSION)/ublue-os-staging-fedora-($FEDORA_MAJOR_VERSION).repo") 

rpm-ostree install tuned tuned-ppd tuned-utils tuned-utils-systemtap tuned-gtk tuned-profiles-atomic tuned-profiles-cpu-partitioning tuned-profiles-realtime powertop
systemctl enable tuned.service

rm -f $COPR_FILE
