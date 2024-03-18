export const DISTROBOX_DOWNLOAD_URL = "https://raw.githubusercontent.com/89luca89/distrobox/main/install"

export def generic_script_installation [yes: bool, program_name: string, installation_script: closure] {
  echo $"Installing, please wait."
  do $installation_script
  echo $"($program_name | str capitalize) installed successfuly! Please reload your shell and run this script again."
}

export def nix_installer [] {
  mut executable_installer = "/usr/lib/nix-install"

  if not ( $executable_installer | path exists) {
    $executable_installer = /tmp/brew-install
    http get "https://install.determinate.systems/nix " | save -f $executable_installer
    chmod +x $executable_installer
  }
  let installer = $executable_installer

  return { open $installer | sh -s -- install --no-confirm }
}

export def brew_installer [] {
  mut executable_installer = "/usr/lib/brew-install"

  if not ($executable_installer | path exists) {
    $executable_installer = /tmp/brew-install
    http get "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" | save -f $executable_installer
    chmod +x $executable_installer
  }
  let installer = $executable_installer

  return { yes | run-external pkexec $installer }
}

export def distrobox_installer [] {
  return { http get $DISTROBOX_DOWNLOAD_URL | sh }
}
