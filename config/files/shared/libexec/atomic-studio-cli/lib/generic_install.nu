export const DISTROBOX_DOWNLOAD_URL = "https://raw.githubusercontent.com/89luca89/distrobox/main/install"

export def generic_script_installation [yes: bool, program_name: string, installation_script: closure] {
  let log_file = $"/tmp/($program_name | str trim | str downcase)_install.log"
  touch $log_file
  echo $"Installing, please wait. You can check logs in ($log_file)"
  do $installation_script out> $log_file
  echo $"($program_name | str capitalize) installed successfuly! Please reload your shell and run this script again."
}

export def nix_installer [] {
  return { yes | curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install }
}

export def brew_installer [] {
  return { yes | /usr/libexec/brew-install ; echo "PLEASE IGNORE THE INSTRUCTIONS ABOVE. THEY WILL NOT HELP YOU! THE SYSTEM IS ALREADY CONFIGURED TO USE BREW PROPERLY BY DEFAULT :>"}
}

export def distrobox_installer [] {
  return { http get $DISTROBOX_DOWNLOAD_URL | pkexec sh }
}
