#!/usr/bin/env bash
rpm-ostree override remove power-profiles-daemon || true
rpm-ostree override remove tlp tlp-rdw || true

rpm-ostree install \
  tuned \
  tuned-ppd \
  tuned-utils \
  tuned-utils-systemtap \
  tuned-gtk \
  tuned-profiles-atomic \
  tuned-profiles-cpu-partitioning \
  powertop

systemctl enable tuned.service
