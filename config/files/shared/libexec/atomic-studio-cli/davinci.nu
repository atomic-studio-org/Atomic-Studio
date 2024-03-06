#!/usr/bin/env -S nu

const DISTROBOX_DOWNLOAD_URL = "https://raw.githubusercontent.com/89luca89/distrobox/main/install"
const INSTALLATION_BOX = "davincibox"
const DAVINCI_IMAGE = "ghcr.io/zelikos/davincibox:latest"

def user_prompt [yes: bool] {
  if $yes {
    return true 
  }
  let user_response = input "[Y/n]> "
  return (($user_response =~ "(?i)yes") or ($user_response =~ "(?i)y"))
}

def fancy_prompt_message [package_manager: string] {
  echo $"($package_manager) is not installed. Do you wish to install it?"
}

# Delete Davinci Resolve in a from a distrobox
export def "main davinci remove" [
  --yes (-y) # Skip all confirmation prompts, 
  --box_name: string # Name of the distrobox where davinci-installer will be run from
] {
  if (which distrobox | length) == 0 {
    fancy_prompt_message "Distrobox"
    if (not (user_prompt $yes)) {
      exit 0
    }
    curl -s $DISTROBOX_DOWNLOAD_URL | pkexec sh
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
}

# Install Davinci Resolve in a compatible distrobox
export def "main davinci" [
  --yes (-y) # Skip all confirmation prompts, 
  --box_name: string # Name of the distrobox where davinci-installer will be run from
  script_path: string # The script that will be run to install Davinci Resolve
] {
  if (which distrobox | length) == 0 {
    fancy_prompt_message "Distrobox"
    if (not (user_prompt $yes)) {
      exit 0
    }
    curl -s $DISTROBOX_DOWNLOAD_URL | pkexec sh
  }

  mut install_box = ""
  if $box_name == null {
    $install_box = $INSTALLATION_BOX 
  }
  let box_name = $install_box

  try { distrobox ls | grep $box_name out> /dev/null } catch { 
    fancy_prompt_message "The Davinci container"
    if (not (user_prompt $yes)) {
      exit 0
    }
    distrobox create -i $DAVINCI_IMAGE --name $box_name -Y --pull 
  }
  
  distrobox enter $box_name -- sh -c $"setup-davinci ($script_path) distrobox && add-davinci-launcher"
}

