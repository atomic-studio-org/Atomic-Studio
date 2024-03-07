#!/usr/bin/env -S nu
try { rpm-ostree override remove power-profiles-daemon } catch { echo "Failed removing ppd" }
try { rpm-ostree override remove tlp tlp-rdw } catch { echo "Failed removing TLP" }

rpm-ostree install tuned tuned-ppd tuned-utils tuned-utils-systemtap tuned-gtk tuned-profiles-atomic tuned-profiles-cpu-partitioning powertop

systemctl enable tuned.service
