#!/usr/bin/env -S nu

use lib/user_interaction.nu [GENERIC_RESET_SESSION_MESSAGE]

const TARGET_CONFIG_PATH = "/etc/profile.d/atomic-pwjack.sh"
const VALID_BFSIZES = [8,16,32,64,128,256,512,1024,2048,4096]
const REALTIME_GROUPS = ["realtime", "pipewire"]

def default_reset_message [message: string] {
  return $"($message) should be reset now."
}

# Reset the entire custom pipewire configuration
export def "main pw reset config" [] {
  let pipewire_config_path = $"($env.HOME)/.config/pipewire"
  rm -f $pipewire_config_path
  systemctl restart --user pipewire.service
  echo (default_reset_message "Pipewire user config")
}

# Reset PIPEWIRE_QUANTUM variable back to its default 
export def "main pw reset quantum-buffersize" [] {
  rm -f $TARGET_CONFIG_PATH
  pw-metadata -n settings 0 clock.force-quantum 0 
  systemctl restart --user pipewire.service
  echo (default_reset_message "PIPEWIRE_QUANTUM buffer size")
  echo $GENERIC_RESET_SESSION_MESSAGE
}

# Set specific buffersize for PIPEWIRE_QUANTUM variable (fixes ardour and carla crashes)
export def "main pw set quantum-buffersize" [buffersize: int] {
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
    $iter = $iter + 1
  }

  if not $is_valid_thing {
    echo "Invalid Value"
    exit 2
  }
  
  $"export PIPEWIRE_QUANTUM=\"($buffersize)/48000\"" | save -f $TARGET_CONFIG_PATH 
  pw-metadata -n settings 0 clock.force-quantum $buffersize
  
  echo $GENERIC_RESET_SESSION_MESSAGE
}

# Edit your own custom configuration for pipewire
export def "main pw set config" [
  --user (-u) # Select user configs
] {
  let pipewire_config_path = $"($env.HOME)/.config/pipewire"
  const pipewire_sys_path = "/usr/share/pipewire"

  mkdir $pipewire_config_path

  mut target_fpath = $pipewire_sys_path
  if $user != null {
    $target_fpath = $pipewire_config_path
  }

  let selected_config_file = (gum file $target_fpath)

  if $user == null {
    cp $selected_config_file $pipewire_config_path
  }
  mut editor = "nano"
  if $env.EDITOR != null {
    $editor = $env.EDITOR 
  }
  run-external $editor $"($selected_config_file)"
}

# Enables realtime in linux kernel arguments
export def "main pw enable realtime" [] {
  for $group in $REALTIME_GROUPS {
    pkexec usermod -a -G $group $env.USER
  }

  rpm-ostree kargs --append-if-missing="preempt=full"
  rpm-ostree kargs --append-if-missing="threadirqs"
  
  echo "Reboot for changes to take effect."
}

# Disables realtime from linux kernel arguments
export def "main pw disable realtime" [] {

  for $group in $REALTIME_GROUPS {
    pkexec usermod -R $group $env.USER
  }

  rpm-ostree kargs --delete-if-present="preempt=full"
  rpm-ostree kargs --delete-if-present="threadirqs"

  echo "Reboot for changes to take effect."
}

# Manage pipewire configurations
export def "main pw" [] {
  echo "Usage pw <subcommand>."
}
