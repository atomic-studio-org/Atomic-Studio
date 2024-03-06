#!/usr/bin/env -S nu

const DISTROBOX_DOWNLOAD_URL = "https://raw.githubusercontent.com/89luca89/distrobox/main/install"
const valid_package_managers = ["apt", "brew", "nix", "dnf", "yum", "paru", "pacman"]
const distroboxes = [
  ["aliases","name", "image"];
  ["ubuntu", "ubuntubox", "ghcr.io/ublue-os/ubuntu-toolbox:latest"]
  ["arch", "archbox", "ghcr.io/ublue-os/arch-distrobox:latest"]
  ["fedora", "fedorabox", "ghcr.io/ublue-os/fedora-toolbox"]
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

  let packages_export = ($packages | each {|package| $"distrobox-export --app ($package) ; distrobox-export --export-path ($export_Path) --bin /usr/bin/($package)" } | str join " ; ")
  distrobox-enter $selected_box -- sh -c $"($packages_export) 2> /dev/null" err> /dev/null
}

# List all available commands and subsystems
export def "main add list" [] {
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

  mut exportPath = ""
  if ($export == null) or ($export == "") {
    $exportPath = $"($env.HOME)/.local/bin"
  } else {
    $exportPath = $export
  }
  let export_Path = $exportPath
  mkdir $export_Path


  match $package_manager {
    nix => { nix_install $yes $packages },
    brew => { brew_install $yes $packages }, 
    apt => { apt_install $yes $export_Path $packages },
    paru => { paru_install $yes $export_Path $packages },
    pacman => { pacman_install $yes $export_Path $packages },
    dnf => { dnf_install $yes $export_Path $packages },
    yum => { echo "Override: using DNF instead" ; dnf_install $yes $export_Path $packages },
    _ => { echo $"Invalid package manager ($manager).\nValid package managers are ($valid_package_managers)" }
  } 
}

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

def distrobox_installer_wrapper [yes: bool, export_path: string, packages: list<string>, box_distro: string, installer_command: string] {
  if (which distrobox | length) == 0 {
    fancy_prompt_message "Distrobox"
    if (not (user_prompt $yes)) {
      exit 0
    }
    echo "Installing, please wait."
    curl -s $DISTROBOX_DOWNLOAD_URL | pkexec sh
  }

  let box_name = ($distroboxes | where aliases == $box_distro | get name).0

  try { distrobox ls | grep $box_name out> /dev/null } catch { 
    fancy_prompt_message $"The ($distroboxes | where aliases == $box_distro | get aliases | str join | str capitalize) subsystem"
    if (not (user_prompt $yes)) {
      exit 0
    }
    distrobox create -i ($distroboxes | where aliases == $box_distro | get image | str join) --name $box_name -Y --pull 
  }
  
  let export_path = $"($env.HOME)/.local/bin"
  mkdir $export_path
  
  let packages_export = ($packages | each {|package| $"distrobox-export --app ($package) ; distrobox-export --export-path ($export_path) --bin /usr/bin/($package)" } | str join " ; ")
  distrobox enter $box_name -- sh -c $"($installer_command) ($packages | str join ' ') && ($packages_export) 2> /dev/null" err> /dev/null
}

def brew_install [yes: bool, packages: list<string>] {
  let brew_path = "/home/linuxbrew/.linuxbrew/bin/brew"
  if (which brew | length) == 0) or (not ($brew_path | path exists)) {
    fancy_prompt_message Brew
    if (not (user_prompt $yes)) {
      exit 0
    }
    echo "Installing, please wait. You can check logs in /tmp/brew_install.log"
    { yes | /usr/libexec/brew-install } out> /tmp/brew_install.log
    echo "PLEASE IGNORE THE INSTRUCTIONS ABOVE. THEY WILL NOT HELP YOU! THE SYSTEM IS ALREADY CONFIGURED TO USE BREW PROPERLY BY DEFAULT :>" out> /tmp/brew_install.log
  }
  run-external $brew_path install ($packages | str join ' ')
}

def nix_install [yes: bool, packages: list<string>] {
  if (which nix | length) == 0 {
    fancy_prompt_message Nix
    if (not (user_prompt $yes)) {
      exit 0
    }
    echo "Installing, please wait. You can check logs in /tmp/nix_install.log"
    { yes | curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install } out> /tmp/nix_install.log
    echo "Nix installed successfully! Please reload your shell and run this program again."
    exit 0
  }

  nix profile install ($packages | each {|value| $"nixpkgs#($value)"} | str join ' ')
}

def apt_install [yes: bool, export_path: string, packages: list<string>] {
  distrobox_installer_wrapper $yes $export_path $packages "ubuntu" "sudo apt install -y"
}

def dnf_install [yes: bool, export_path: string, packages: list<string>] {
  distrobox_installer_wrapper $yes $export_path $packages "fedora" "sudo dnf install -y" 
}

def pacman_install [yes: bool, export_path: string, packages: list<string>] {
  distrobox_installer_wrapper $yes $export_path $packages "arch" "sudo pacman -Syu --noconfirm" 
}

def paru_install [yes: bool, export_path: string, packages: list<string>] {
  distrobox_installer_wrapper $yes $export_path $packages "arch" "paru -Syu --noconfirm" 
}