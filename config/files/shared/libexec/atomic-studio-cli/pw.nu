#!/usr/bin/env -S nu

const TARGET_CONFIG_PATH = "/etc/profile.d/atomic-pwjack.sh"
const VALID_BFSIZES = [8,16,32,64,128,256,512,1024,2048,4096]
const REALTIME_GROUPS = ["realtime", "pipewire"]

# Set specific buffersize for PIPEWIRE_QUANTUM variable (fixes ardour and carla crashes)
export def "main pw set quantum-buffersize" [--buffersize (-b): int] {
  mut is_valid_thing: bool = false
  mut iter = 0
  let max_iter = ($VALID_BFSIZES | length)
  loop {
    if $iter == $max_iter { 
      break
    }
    if VALID_BFSIZES.$iter == $buffersize {
      $is_valid_thing = true
    }
  }

  if not is_valid_thing {
    echo "Invalid Value"
    exit 2
  }
  
  $"export PIPEWIRE_QUANTUM=\"($buffersize)/48000\"" | save -f /etc/profile.d/atomic-pwjack.sh
  pw-metadata -n settings 0 clock.force-quantum $buffersize
  
  echo "Log out and in for changes to take effect."
  exit 0
}

# Edit your own custom configuration for pipewire
export def "main pw edit" [
  --system (-s) # Select system configurations to override
  --user (-u) # Select user configs
] {
  let pipewire_config_path = $"($env.HOME)/.config/pipewire"
  const pipewire_sys_path = "/usr/share/pipewire"

  mkdir $pipewire_config_path

  mut target_fpath = ""
  if $system != null {
    $target_fpath = $pipewire_sys_path
  }
  if $user != null {
    $target_fpath = $pipewire_config_path
  }

  let selected_config_file = (gum file $target_fpath)

  if $system != null {
    cp $selected_config_file $pipewire_config_path
  }
  mut editor = "nano"
  if $env.EDITOR != null {
    $editor = $env.EDITOR 
  }
  run-external $editor $"($selected_config_file)"
}

# Installs RTCQS in the host system for checking realtime perms
export def "main pw rtcqs" [] {
  pipx install rtcqs
  pipx ensurepath
  echo "Restart your shell and run rtcqs_gui"
}

# Enables realtime in linux kernel arguments
export def "main pw enable realtime" [] {
  rpm-ostree kargs --append-if-missing="preempt=full"
  rpm-ostree kargs --append-if-missing="threadirqs"
  
  for $group in $REALTIME_GROUPS {
    usermod -a -G $group $env.USER
  }
  echo "Reboot for changes to take effect."
}

# Disables realtime from linux kernel arguments
export def "main pw disable realtime" [] {
  rpm-ostree kargs --delete-if-present="preempt=full"
  rpm-ostree kargs --delete-if-present="threadirqs"

  for $group in $REALTIME_GROUPS {
    usermod -R $group $env.USER
  }
  echo "Reboot for changes to take effect."
}

# Manage pipewire configurations
export def "main pw" [] {
  echo "Usage pw <subcommand>."
}
