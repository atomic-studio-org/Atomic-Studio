#!/usr/bin/env -S nu
try { rpm-ostree override remove power-profiles-daemon } catch { echo "Failed removing ppd" }
try { rpm-ostree override remove tlp tlp-rdw } catch { echo "Failed removing TLP" }

let FEDORA_MAJOR_VERSION = (run-external --redirect-combine rpm '-E' '%fedora' | complete).stdout
const COPR_FILE = "/etc/yum.repos.d/_copr_ublue-os_staging.repo"

http get $"https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-($FEDORA_MAJOR_VERSION)/ublue-os-staging-fedora-($FEDORA_MAJOR_VERSION).repo" | save -f $COPR_FILE 

rpm-ostree install tuned tuned-ppd tuned-utils tuned-utils-systemtap tuned-gtk tuned-profiles-atomic tuned-profiles-cpu-partitioning powertop

systemctl enable tuned.service

rm -f $COPR_FILE
