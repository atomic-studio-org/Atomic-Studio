#!/usr/bin/env -S nu

use lib/user_interaction.nu [fancy_prompt_message, user_prompt]
use lib/generic_install.nu [generic_script_installation]
use lib/distrobox.nu [create_container_optional]

const INSTALLATION_BOX = "davincibox"
const DAVINCI_IMAGE = "ghcr.io/zelikos/davincibox:latest"

# Delete Davinci Resolve in a from a distrobox
export def "main davinci remove" [
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
  
  try { distrobox ls | grep $install_box out> /dev/null } catch { 
    echo "The selected box ($install_box) is not created yet."
    exit 1 
  }

  distrobox enter $install_box '--' sh -c "add-davinci-launcher remove"
  if $delete_box != null {
    distrobox rm $install_box
  }
}

# Install Davinci Resolve in a compatible distrobox
export def "main davinci" [
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
  
  distrobox enter $box_name -- sh -c $"setup-davinci ($script_path) distrobox && add-davinci-launcher"
}
