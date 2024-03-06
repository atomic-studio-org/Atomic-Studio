#!/usr/bin/env -S nu

const SYSTEM_JACKD_SCRIPT_PATH = "/usr/libexec/studio-jackd-default"

const DEFAULT_SCRIPT = "#!/usr/bin/env -S nu
jack_control start
jack_control ds alsa
jack_control dps rate 48000
jack_control dps nperiods 2
jack_control dps period 64
sleep 5sec
a2j_control --ehw
a2j_control --start
sleep 5sec
qjackctl &"


def user_prompt [yes: bool] {
  let user_response = input "[Y/n]> "
  return (($user_response =~ "(?i)yes") or ($user_response =~ "(?i)y"))
}

# Toggle Jackd only mode
export def "main jackd toggle" [
  --yes (-y) # Skip confirmation prompts
] {
  let CURRENT_IMAGE = (rpm-ostree status -b --json | jq -r '.deployments[0]."container-image-reference"')
  
  if ($CURRENT_IMAGE | grep -q "/var/ublue-os/image") {
      echo "Before we can switch to the Jack image,the current system needs an update. Do you wish to update?"
      
      if (not (user_prompt $yes)) {
        exit 0
      }
  
      studio update
      exit 0
  }
  
  mut CURRENT_STATE = "disabled"
  if ($CURRENT_IMAGE | grep -q "jack") {
      $CURRENT_STATE = "enabled"
  }
  
  echo "Jack-only mode is currently ${CURRENT_STATE}"
  echo "Enable or Disable jack-only mode"
  let OPTION = (gum choose Enable Disable)
  
  if "$OPTION" == "Enable" {
      if "$CURRENT_STATE" == "enabled" {
          echo "You are already on a jack image"
      } else {
          echo "Rebasing to a pipewire image"
          let base_image_name = ($CURRENT_IMAGE | sed 's|^ostree-image-signed:docker://ghcr.io/.*/||')
          rpm-ostree rebase $"ostree-image-signed:docker://($base_image_name)-jack:latest"
      }
  } else if "$OPTION" == "Disable" {
      if "$CURRENT_STATE" == "enabled" {
          echo "Rebasing to a pipewire image"
          rpm-ostree rebase ($CURRENT_IMAGE | str replace --all "-jack" "")
      } else {
          echo "You are currently not on a pipewire image"
      }
  }
}

# Do not use the users jackd script instead of the predefined system script
export def "main jackd disable-user" [] {
  let USER_JACKD_ENABLED = $"($env.HOME)/.config/atomic-studio/jack/user_custom_jackd"
  if not ($USER_JACKD_ENABLED | path exists) {
    echo "Custom JackD script for the user not enabled"
    exit 0
  }

  rm $USER_JACKD_ENABLED
  echo "Sucessfully disabled custom user jack script"
}

# Use the users jackd script instead of the predefined system script
export def "main jackd enable-user" [] {
  let DEFAULT_CUSTOM_SCRIPT_PATH = $"($env.HOME)/.config/atomic-studio/jack/custom-jackd.nu"
  let USER_JACKD_ENABLED = $"($env.HOME)/.config/atomic-studio/jack/user_custom_jackd"
  if ($USER_JACKD_ENABLED | path exists) {
    echo "Custom JackD script for the user already is enabled"
    exit 0
  }

  mkdir ($DEFAULT_CUSTOM_SCRIPT_PATH | path dirname)
  touch $USER_JACKD_ENABLED
  $DEFAULT_SCRIPT | save -f $DEFAULT_CUSTOM_SCRIPT_PATH
  echo "Sucessfully enabled custom user jack script"
}

# Run jackd with a specific script
export def "main jackd" [
  --entrypoint (-e): string # Entrypoint script for running jackd (default: ~/.config/atomic-studio/jack/custom-jackd.nu)
  ...args # Arguments that will be passed to the script
] {
  let DEFAULT_CUSTOM_SCRIPT_PATH = $"($env.HOME)/.config/atomic-studio/jack/custom-jackd.nu"
  let USER_JACKD_ENABLED = $"($env.HOME)/.config/atomic-studio/jack/user_custom_jackd"

  mut entrypoint_path = ""
  if $entrypoint == null {
    # There is something very... wrong with this but it seems to work?
    if ($USER_JACKD_ENABLED | path exists) {   
      $entrypoint_path = $SYSTEM_JACKD_SCRIPT_PATH 
    } else {
      $entrypoint_path = $DEFAULT_CUSTOM_SCRIPT_PATH
    }
  }

  if not ($entrypoint_path | path exists) {
    mkdir ($entrypoint_path | path dirname)
    $DEFAULT_SCRIPT | save -f $entrypoint_path
    chmod +x $entrypoint_path
  }

  run-external $entrypoint_path ...$args
}
