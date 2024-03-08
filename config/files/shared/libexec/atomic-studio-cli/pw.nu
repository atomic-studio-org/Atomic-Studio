#!/usr/bin/env -S nu

const TARGET_CONFIG_PATH = "/etc/profile.d/atomic-pwjack.sh"
const VALID_BFSIZES = [8,16,32,64,128,256,512,1024,2048,4096]

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

# Enables realtime in linux kernel arguments
export def "main pw enable realtime" [] {
  rpm-ostree kargs --append-if-missing="preempt=full"
}

# Disables realtime from linux kernel arguments
export def "main pw disable realtime" [] {
  rpm-ostree kargs --delete-if-present="preempt=full"
}

# Manage pipewire configurations
export def "main pw" [] {
  echo "Usage pw <subcommand>."
}
