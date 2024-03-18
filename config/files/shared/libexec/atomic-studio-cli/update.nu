#!/usr/bin/env -S nu

# Unpin a certain system version
export def "main update unpin" [
  number: int # Which deployment will be unpinned
] {
  pkexec ostree admin pin --unpin $number
}

# Pin a certain system version
export def "main update pin" [
  number: int # Which deployment will be pinned
] {
  pkexec ostree admin pin $number
}

# Rollback an update 
export def "main update rollback" [] {
  pkexec rpm-ostree rollback 
}

# Show changelogs for the current system
export def "main update changelog" [] {
  pkexec rpm-ostree db diff --changelogs
}

# Disable automatic updates
export def "main update auto off" [] {
  systemctl disable --now ublue-update.timer
}

# Enable automatic updates
export def "main update auto on" [] {
  systemctl enable --now ublue-update.timer
}

# Run topgrade transaction for general upgrades
export def "main update" [
  --config (-c): string # Configuration file for Topgrade
] {
  mut config_file = $config
  if $config == null {
    $config_file = "/usr/share/ublue-os/topgrade.toml"
  }

  run-external ublue-update '--wait'
  run-external topgrade '--keep' '--config' $config_file
}
