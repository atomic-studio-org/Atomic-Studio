use lib/user_interaction.nu [user_prompt, fancy_prompt_message]
use lib/distrobox.nu [DISTROBOXES_META, create_container_optional]

# Setup Atomic Studio supported apps
export def "main setup" [] {
  echo "Usage setup <subcommand>."
}

# Disable Supergfxctl, a GPU switcher for hybrid laptops
export def "main uninstall supergfxctl" [] {
  systemctl disable --now supergfxd.service
}

# Uninstall LACT, an overclocking utility for AMD cards
export def "main uninstall amd-lact" [] {
  systemctl disable --now lactd
  rpm-ostree uninstall lact
}

# Removes OpenTabletDriver services and the installation from container (does not delete the container itself.)
export def "main uninstall opentabletdriver" [] {
  let archbox_entry = ($DISTROBOXES_META | select aliases name image | where aliases == arch).0
  rm -f $"($env.HOME)/.config/systemd/user/($archbox_entry.name)-opentabletdriver.service"
  systemctl --user daemon-reload
  systemctl enable --user --now $"($archbox_entry.name)-opentabletdriver.service"
  distrobox enter -n $archbox_entry.name -- ' paru -Rns opentabletdriver --noconfirm'
}

# Removes RTCQS from the host system
export def "main uninstall rtcqs" [] {
  pipx uninstall rtcqs
}

# Install OpenTabletDriver in a container
export def "main setup opentabletdriver" [
  --yes (-y) # Skip all confirmation prompts
] {
  install_distrobox_if_not_exists $yes
  
  let archbox_entry = ($DISTROBOXES_META | select aliases name image | where aliases == arch).0

  let opentabletdriver_service = $"
  [Unit]
  Description=OpenTabletDriver Daemon
  PartOf=graphical-session.target
  After=graphical-session.target
  ConditionEnvironment=|WAYLAND_DISPLAY
  ConditionEnvironment=|DISPLAY
  
  [Service]
  ExecStart=/usr/bin/distrobox-enter  -n ($archbox_entry.name) -- ' /usr/bin/otd-daemon'
  Restart=always
  RestartSec=3
  
  [Install]
  WantedBy=graphical-session.target
  "

  create_container_optional $yes {name: $archbox_entry.name, description: "Arch Linux subsystem", image: $archbox_entry.image}
  
  distrobox enter -n $archbox_entry.name -- ' paru -S opentabletdriver --noconfirm'
  mkdir $"($env.HOME)/.config/systemd/user"
  try { rm -f $"($env.HOME)/.config/systemd/user/($archbox_entry.name)-opentabletdriver.service" } catch { }
  
  $opentabletdriver_service | save -f $"($env.HOME)/.config/systemd/user/($archbox_entry.name)-opentabletdriver.service"

  systemctl --user daemon-reload
  systemctl enable --user --now $"($archbox_entry.name)-opentabletdriver.service"
  
  distrobox enter -n $archbox_entry.name -- 'distrobox-export --app otd-gui'
}

# Installs RTCQS in the host system for checking realtime perms
export def "main setup rtcqs" [] {
  pipx install rtcqs
  echo "Restart your shell and run rtcqs_gui"
}


# Enable Supergfxctl, a GPU switcher for hybrid laptops
export def "main setup supergfxctl" [] {
  systemctl enable --now supergfxd.service
}

# Set up LACT, an overclocking utility for AMD cards
export def "main setup amd-lact" [] {
  ublue-update --wait
  echo 'Installing LACT...'
  http get (http get "https://api.github.com/repos/ilya-zlobintsev/LACT/releases/latest" | get assets | where {|e| $e.name | str ends-with "fedora-39.rpm"}).0.browser_download_url | save -f /tmp/lact.rpm
  rpm-ostree install --apply-live -y /tmp/lact.rpm
  systemctl enable --now lactd
  rm /tmp/lact.rpm
  echo 'Complete.'
}


