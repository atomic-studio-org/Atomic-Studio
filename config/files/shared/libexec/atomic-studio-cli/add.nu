#!/usr/bin/env -S nu

use lib/distrobox.nu [gen_export_string, create_container_optional, DISTROBOXES_META]
use lib/user_interaction.nu [fancy_prompt_message, user_prompt]
use lib/generic_install.nu [generic_script_installation, nix_installer, brew_installer, distrobox_installer] 

const valid_package_managers = ["apt", "brew", "nix", "dnf", "yum", "paru", "pacman", "pipx"]

# Export selected packages from selected subsystem to the host system
export def "main add export" [
  --export (-e): string # Path where packages will be exported to (default: ~/.local/bin),
  box_or_subsystem: string, 
  ...packages: string
] {
  mut exportPath = $export
  if $export == null {
    $exportPath = $"($env.HOME)/.local/bin"
  }
  let export_Path = $exportPath
  mkdir $export_Path

  let selected_box = ($DISTROBOXES_META | select aliases name | where { |e| ($e.name == $box_or_subsystem) or ($e.aliases == $box_or_subsystem) } | get name | str join)
  let packages_export_cmd: string = (gen_export_string $packages $export_Path)
  distrobox-enter $selected_box -- sh -c $"($packages_export_cmd) 2> /dev/null" err> /dev/null
}

# List all available commands and subsystems
export def "main add list" [
  --as-record (-r)
] {
  if $as_record != null {
    return {pkg_managers: $valid_package_managers, distroboxes: $DISTROBOXES_META}
  }

  echo $"Valid package managers:\n($valid_package_managers | table)\nSubsystems \(Distroboxes\):\n($DISTROBOXES_META| table)"
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
    nix => { nix_install $yes $packages ; exit 0 },
    brew => { brew_install $yes $packages ; exit 0},
    pipx => { pipx_install $yes $packages ; exit 0 },
  }

  distrobox_installer_wrapper $package_data (match $package_manager {
    apt => { box_distro: "ubuntu", installer_command: "sudo apt install -y" },
    paru => { box_distro: "arch", installer_command: "paru -Syu --noconfirm" } ,
    pacman => { box_distro: "arch", installer_command: "sudo pacman -Syu --noconfirm" },
    dnf | yum => { box_distro: "fedora", installer_command: "sudo dnf install -y" },
    _ => { echo $"Invalid package manager ($manager).\nValid package managers are ($valid_package_managers)" }
  })
}

def distrobox_installer_wrapper [
  package_data: record<packages: list<string>, export_path: string, no_confirm: bool>
  manager: record<box_distro: string, installer_command: string>
] {
  if (which distrobox | length) == 0 {
    generic_script_installation $package_data.no_confirm "distrobox" (distrobox_installer)
  }

  let box_name: string = ($DISTROBOXES_META | where aliases == $manager.box_distro | get name).0
  let box_alias: string = ($DISTROBOXES_META | where aliases == $manager.box_distro | get aliases | str join | str capitalize)
  let box_image: string = ($DISTROBOXES_META | where aliases == $manager.box_distro | get image | str join)
  
  create_container_optional $package_data.no_confirm {name: $box_name, description: $box_alias, image: $box_image }

  mkdir $package_data.export_path
  
  let packages_export = gen_export_string $package_data.packages $package_data.export_path
  distrobox enter $box_name -- sh -c $"($manager.installer_command) ($package_data.packages | str join ' ') && ($packages_export) 2> /dev/null" err> /dev/null
}

def pipx_install [yes: bool, packages: list<string>] {
  for $package in $packages {
    run-external pipx install $package
  }
}

def brew_install [yes: bool, packages: list<string>] {
  let brew_path = "/home/linuxbrew/.linuxbrew/bin/brew"
  if ((which brew | length) != 0) or ($brew_path | path exists) {
    run-external $brew_path install ($packages | str join)
    exit 0 
  }
  
  fancy_prompt_message Brew
  if not (user_prompt $yes) {
    exit 0
  }
  generic_script_installation $yes "brew" (brew_installer)
}

def nix_install [yes: bool, packages: list<string>] {
  if (which nix | length) != 0 {
    run-external nix profile install ($packages | each {|value| $"nixpkgs#($value) "} | str join) 
    exit 0
  }

  fancy_prompt_message Nix
  if not (user_prompt $yes) {
    exit 0
  }
  generic_script_installation $yes "nix" (nix_installer)
}
