#!/usr/bin/env -S nu

const TARGET_CONFIG_PATH = "/etc/profile.d/atomic-pwjack.sh"
const VALID_BFSIZES = [8,16,32,64,128,256,512,1024,2048,4096]

# Set specific buffersize for PIPEWIRE_QUANTUM variable
export def "main pw-jack set" [--buffersize (-b): int] {
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

  echo "Log out and in for changes to take effect."
  exit 0
}

# Enable custom pipewire-jack configuration
export def "main pw-jack enable" [] {
  ln -fs /usr/share/doc/pipewire/examples/ld.so.conf.d/pipewire-jack-*-linux-gnu.conf \
			/etc/ld.so.conf.d/pipewire-jack.conf
  ldconfig
  systemctl mask pulseaudio-enable-autospawn.service
  echo "Reboot for changes to take effect."
  exit 0
}

# Disables custom pipewire-jack configuration
export def "main pw-jack disable" [] {
  rm -f /etc/ld.so.conf.d/pipewire-jack.conf
  ldconfig
  systemctl unmask pulseaudio-enable-autospawn.service
  echo "Reboot for changes to take effect."
  exit 0
}

