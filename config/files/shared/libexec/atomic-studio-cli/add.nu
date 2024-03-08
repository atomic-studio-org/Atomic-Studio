#!/usr/bin/env -S nu

use lib/distrobox.nu [gen_export_string, DISTROBOX_DOWNLOAD_URL]
use lib/std.nu [fancy_prompt_message, user_prompt]

const valid_package_managers = ["apt", "brew", "nix", "dnf", "yum", "paru", "pacman"]
const distroboxes = [
  ["aliases","name", "image", "description"];
  ["ubuntu", "ubuntubox", "ghcr.io/ublue-os/ubuntu-toolbox:latest", "Ubuntu based distrobox"]
  ["arch", "archbox", "ghcr.io/ublue-os/arch-distrobox:latest", "Arch Linux based distrobox with paru pre-installed"]
  ["fedora", "fedorabox", "ghcr.io/ublue-os/fedora-toolbox", "Fedora based distrobox"]
]

# Export selected packages from selected subsystem to the host system
export def "main add export" [
  --export (-e): string # Path where packages will be exported to (default: ~/.local/bin),
  box_or_subsystem: string, 
  ...packages: string
] {
  mut exportPath = ""
  if ($export == null) or ($export == "") {
    $exportPath = $"($env.HOME)/.local/bin"
  } else {
    $exportPath = $export
  }
  let export_Path = $exportPath
  mkdir $export_Path

  let selected_box = ($distroboxes | select aliases name | where { |e| ($e.name == $box_or_subsystem) or ($e.aliases == $box_or_subsystem) } | get name | str join)

  let packages_export = ($packages | each {|package| gen_export_string $package $export_Path } | str join " ; ")
  distrobox-enter $selected_box -- sh -c $"($packages_export) 2> /dev/null" err> /dev/null
}

# List all available commands and subsystems
export def "main add list" [
  --as-record (-r)
] {
  if $as_record != null {
    return {pkg_managers: $valid_package_managers, distroboxes: $distroboxes}
  }

  echo $"Valid package managers:\n($valid_package_managers | table)\nSubsystems \(Distroboxes\):\n($distroboxes| table)"
}

# Add a package to your Atomic Studio system by using package subsystems or host-based package managers.
export def "main add" [
  --yes (-y) # Skip all confirmation prompts, 
  --export (-e): string # Path where packages will be exported to (default: ~/.local/bin)
  --manager (-m): string # Package manager that will be used (default: brew)
  ...packages: string # Packages that will be installed
] {
  mut package_manager = $manager 
  if ($manager == null) {
    $package_manager = "brew"
  }

  mut export_path = $"($env.HOME)/.local/bin"
  if $export != null {
    $export_path = $export 
  }

  let package_data = {
    packages: $packages,
    export_path: $export_path,
    no_confirm: $yes,
  }

  match $package_manager {
    nix => { nix_install $yes $packages },
    brew => { brew_install $yes $packages },
    apt | paru | pacman | dnf | yum => {
      distrobox_installer_wrapper $package_data (match $package_manager {
        apt => { box_distro: "ubuntu", installer_command: "sudo apt install -y" },
        paru => { box_distro: "arch", installer_command: "paru -Syu --noconfirm" } ,
        pacman => { box_distro:"arch", installer_command: "sudo pacman -Syu --noconfirm" },
        dnf | yum => { box_distro: "fedora", installer_command: "sudo dnf install -y" },
      })
    },
    _ => { echo $"Invalid package manager ($manager).\nValid package managers are ($valid_package_managers)" }
  }
}

def distrobox_installer_wrapper [
  package_data: record<packages: list<string>, export_path: string, no_confirm: bool>
  manager: record<box_distro: string, installer_command: string>
] {
  if (which distrobox | length) == 0 {
    fancy_prompt_message "Distrobox"
    if not (user_prompt $package_data.no_confirm) {
      exit 0
    }
    echo "Installing, please wait."
    curl -s $DISTROBOX_DOWNLOAD_URL | pkexec sh
  }

  let box_name = ($distroboxes | where aliases == $manager.box_distro | get name).0

  try { distrobox ls | grep $box_name out> /dev/null } catch { 
    fancy_prompt_message $"The ($distroboxes | where aliases == $manager.box_distro | get aliases | str join | str capitalize) subsystem"
    if not (user_prompt $package_data.no_confirm) {
      exit 0
    }
    distrobox create -i ($distroboxes | where aliases == $manager.box_distro | get image | str join) --name $manager.box_name -Y --pull 
  }
  
  mkdir $package_data.export_path
  
  let packages_export = ($package_data.packages | each {|package| gen_export_string $package $package_data.export_path } | str join " ; ")
  distrobox enter $box_name -- sh -c $"($manager.installer_command) ($package_data.packages | str join ' ') && ($packages_export) 2> /dev/null" err> /dev/null
}

def brew_install [yes: bool, packages: list<string>] {
  let brew_path = "/home/linuxbrew/.linuxbrew/bin/brew"
  if (which brew | length) == 0) or (not ($brew_path | path exists)) {
    fancy_prompt_message Brew
    if not (user_prompt $yes) {
      exit 0
    }
    echo "Installing, please wait. You can check logs in /tmp/brew_install.log"
    do { yes | /usr/libexec/brew-install ; echo "PLEASE IGNORE THE INSTRUCTIONS ABOVE. THEY WILL NOT HELP YOU! THE SYSTEM IS ALREADY CONFIGURED TO USE BREW PROPERLY BY DEFAULT :>"} out> /tmp/brew_install.log
    echo "Brew installed successfully! Please reload your shell and run this program again."
    exit 0
  }
  run-external $brew_path install ($packages | str join)
}

def nix_install [yes: bool, packages: list<string>] {
  if (which nix | length) == 0 {
    fancy_prompt_message Nix
    if not (user_prompt $yes) {
      exit 0
    }
    echo "Installing, please wait. You can check logs in /tmp/nix_install.log"
    do { yes | curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install } out> /tmp/nix_install.log
    echo "Nix installed successfully! Please reload your shell and run this program again."
    exit 0
  }

  run-external nix profile install ($packages | each {|value| $"nixpkgs#($value) "} | str join)
}
