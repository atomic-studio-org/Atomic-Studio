#!/usr/bin/env -S nu

# Show changelogs for the current system
export def "main update changelog" [] {
  rpm-ostree db diff --changelogs
}

# Toggle automatic upgrades
#
# Use 'enable' to Enable automatic updates.
# Use 'disable' to Disable automatic updates.
export def "main update toggle" [option?: string] {
  mut CURRENT_STATE = "disabled"
  if (run-external --redirect-combine systemctl is-enabled ublue-update.timer | complete).stdout == "enabled" {
    $CURRENT_STATE = "enabled"
  }

  mut opt = $option
  if $option == null {
    $opt = "prompt"
  }

  if "$OPTION" == "prompt" {
    echo $"Automatic updates are currently: ($CURRENT_STATE)"
    echo "Enable or Disable automatic updates?"
    $opt = (gum choose Enable Disable)
  }

  pkexec systemctl (match ($opt | str downcase) {
    "disable" | "enable" => ($opt | str downcase),
    _ => { echo "Invalid option" ; exit } 
  }) --now ublue-update.timer 
}

# Run topgrade transaction for general upgrades
export def "main update" [
  --config (-c) # Configuration file for Topgrade
] {
  mut config_file = $config
  if $config == null {
    $config_file = "/usr/share/ublue-os/topgrade.toml"
  }

  run-external topgrade '--config' '--keep' $config_file 
}