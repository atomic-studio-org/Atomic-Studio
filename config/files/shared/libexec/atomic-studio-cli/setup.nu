use lib/user_interaction.nu [user_prompt, fancy_prompt_message]
use lib/distrobox.nu [DISTROBOXES_META, create_container_optional]

const INSTALLATION_BOX = "davincibox"
const DAVINCI_IMAGE = "ghcr.io/zelikos/davincibox:latest"

# Setup Atomic Studio supported apps
export def "main setup" [] {
  echo "Usage setup <subcommand>."
}


# Removes OpenTabletDriver services and the installation from container (does not delete the container itself.)
export def "main setup remove opentabletdriver" [] {
  let archbox_entry = ($DISTROBOXES_META | select aliases name image | where aliases == arch).0
  rm -f $"($env.HOME)/.config/systemd/user/($archbox_entry.name)-opentabletdriver.service"
  systemctl --user daemon-reload
  systemctl enable --user --now $"($archbox_entry.name)-opentabletdriver.service"
  distrobox enter -n $archbox_entry.name -- 'paru -Rns opentabletdriver --noconfirm'
}



# Install OpenTabletDriver in a container
export def "main setup install opentabletdriver" [
  --yes (-y) # Skip all confirmation prompts
] {
  if (which distrobox | length) == 0 {
    fancy_prompt_message "Distrobox"
    if not (user_prompt $yes) {
      exit 0
    }
    generic_script_installation $yes "distrobox" (distrobox_installer)
    exit 0
  }

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
  
  distrobox enter -n $archbox_entry.name -- 'paru -S opentabletdriver --noconfirm'
  mkdir $"($env.HOME)/.config/systemd/user"
  try { rm -f $"($env.HOME)/.config/systemd/user/($archbox_entry.name)-opentabletdriver.service" } catch { }
  
  $opentabletdriver_service | save -f $"($env.HOME)/.config/systemd/user/($archbox_entry.name)-opentabletdriver.service"

  systemctl --user daemon-reload
  systemctl enable --user --now $"($archbox_entry.name)-opentabletdriver.service"
  
  distrobox enter -n $archbox_entry.name -- 'distrobox-export --app otd-gui'
}

# Installs RTCQS in the host system for checking realtime perms
export def "main setup install rtcqs" [] {
  pipx install rtcqs
  echo "Restart your shell and run rtcqs_gui"
}

# This only works for Nvidia!
# Enable Supergfxctl, a GPU switcher for hybrid laptops
export def "main setup install supergfxctl" [] {
  systemctl enable --now supergfxd.service
}

# Set up LACT, an overclocking utility for AMD cards
export def "main setup install amd-lact" [] {
  ublue-update --wait
  echo 'Installing LACT...'
  http get (http get "https://api.github.com/repos/ilya-zlobintsev/LACT/releases/latest" | get assets | where {|e| $e.name | str ends-with "fedora-39.rpm"}).0.browser_download_url | save -f /tmp/lact.rpm
  pkexec rpm-ostree install --apply-live -y /tmp/lact.rpm
  sleep 2sec
  systemctl daemon-reload
  systemctl enable --now lactd
  rm /tmp/lact.rpm
  echo 'Complete.'
}

# Install Davinci Resolve in a compatible distrobox
export def "main setup install davinci" [
  --yes (-y) # Skip all confirmation prompts
  --box_name: string # Name of the distrobox where davinci-installer will be run from
  script_path: string # The script that will be run to install Davinci Resolve
] {
  if (which distrobox | length) == 0 {
    fancy_prompt_message "Distrobox" 
    if not (user_prompt $yes) {
      exit 0
    }
    generic_script_installation $yes "Distrobox" (distrobox_installer)
  }

  mut install_box = ""
  if $box_name == null {
    $install_box = $INSTALLATION_BOX 
  }
  let box_name = $install_box 

  create_container_optional $yes {name: $box_name, description: "Davinci container", image: $DAVINCI_IMAGE}

  mkdir $"($env.HOME)/.cache/davincibox"
  cp -f $script_path $"($env.HOME)/.cache/davincibox/dresolve.run"
  distrobox enter $box_name -- bash -c $"pushd ($env.HOME)/.cache/davincibox && ./dresolve.run --appimage-extract && popd"
  distrobox enter $box_name -- sh -c $"setup-davinci ($env.HOME)/.cache/davincibox/squashfs-root/AppRun distrobox && add-davinci-launcher distrobox"
  rm -rf $"($env.HOME)/.cache/davincibox"
}

# Delete Davinci Resolve in a from a distrobox
export def "main setup remove davinci" [
  --yes (-y) # Skip all confirmation prompts, 
  --box_name: string # Name of the distrobox where davinci-installer will be run from
  --delete-box # Also delete container
] {
  if (which distrobox | length) == 0 {
    fancy_prompt_message "Distrobox" 
    if not (user_prompt $yes) {
      exit 0
    }
    generic_script_installation $yes "Distrobox" (distrobox_installer)
  }

  mut install_box = ""
  if $box_name == null {
    $install_box = $INSTALLATION_BOX 
  }
 
  let install_box_static = $install_box 
  try { distrobox ls | grep $install_box } catch {
    echo $"The selected box ($install_box_static) is not created yet."
    exit 1 
  }

  distrobox enter $install_box '--' sh -c "add-davinci-launcher remove"
  if $delete_box != null {
    distrobox rm $install_box
  }
}

# Disable Supergfxctl, a GPU switcher for hybrid laptops
export def "main setup remove supergfxctl" [] {
  systemctl disable --now supergfxd.service
}

# Removes RTCQS from the host system
export def "main setup remove rtcqs" [] {
  pipx uninstall rtcqs
}

# Uninstall LACT, an overclocking utility for AMD cards
export def "main setup remove amd-lact" [--force (-f)] {
  try { rpm -qa | grep lact } catch {
    echo "Amd LACT doesnt seem to be installed. Use --force if it actually is installed."
    if $force == null {
      exit 1
    }
  }
  systemctl disable --now lactd
  rpm-ostree remove (rpm -qa | grep lact) -y --apply-live
}
