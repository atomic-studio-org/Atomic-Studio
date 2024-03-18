#!/usr/bin/env -S nu

use lib/user_interaction.nu [user_prompt]
use lib/distrobox.nu [DISTROBOXES_META, gen_export_string]
use lib/manager_installers.nu [brew_install, nix_install, distrobox_install, pipx_install, brew_uninstall, nix_uninstall, distrobox_uninstall, pipx_uninstall]

# Available package managers: ["apt", "brew", "nix", "dnf", "yum", "paru", "pacman", "pipx"]
export def "main manager" [] {
  echo "Usage manager <command>."
}

# Export selected packages from selected subsystem to the host system
export def "main manager export" [
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
  let packages_export_cmd = gen_export_string $packages $export_Path

  distrobox-enter $selected_box -- sh -c $"($packages_export_cmd) 2> /dev/null" err> /dev/null
}

# Add a package to your Atomic Studio system by using package subsystems or host-based package managers.
export def "main manager install" [
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

  if ($packages | length) == 0 {
    echo "No packages were selected."
    exit 0
  }

  let package_data = {
    packages: $packages,
    export_path: $export_path,
    no_confirm: $yes,
  }

  match $package_manager {
    nix => { nix_install $yes $packages ; exit 0 },
    brew => { brew_install $yes $packages ; exit 0 },
    pipx => { pipx_install $yes $packages ; exit 0 },
  }

  distrobox_install $package_data (match $package_manager {
    apt => { box_distro: "ubuntu", installer_command: "sudo apt install -y" },
    paru => { box_distro: "arch", installer_command: "paru -Syu --noconfirm" } ,
    pacman => { box_distro: "arch", installer_command: "sudo pacman -Syu --noconfirm" },
    dnf | yum => { box_distro: "fedora", installer_command: "sudo dnf install -y" },
    _ => { echo $"Invalid package manager ($manager), see studio manager --help argument to get a list of valid package managers" }
  })
}

# Remove a package to your Atomic Studio package subsystems or host-based package managers.
export def "main manager remove" [
  --yes (-y) # Skip all confirmation prompts, 
  --manager (-m): string # Package manager that will be used (default: brew)
  ...packages: string # Packages that will be installed
] {
  mut package_manager = $manager 
  if ($manager == null) {
    $package_manager = "brew"
  }

  if ($packages | length) == 0 {
    echo $"No packages were selected, do you wish to uninstall the selected package manager? \(($package_manager)\)"
    if not (user_prompt $yes) { 
      exit 0
    }

    match $package_manager {
      nix => { /nix/nix-installer uninstall }
      brew => { http get https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh | bash }
      pipx => { echo "This package manager cannot be uninstalled since it is installed in your image." }
      apt => { run-external distrobox-rm '-f' ($DISTROBOXES_META | select aliases name | where aliases == "ubuntu").name.0 }
      pacman | paru => { run-external distrobox-rm '-f' ($DISTROBOXES_META | select aliases name | where aliases == "arch").name.0 }
      dnf | yum => { run-external distrobox-rm '-f' ($DISTROBOXES_META | select aliases name | where aliases == "fedora").name.0 }
    }
    exit 0
  }

  let package_data = {
    packages: $packages,
    no_confirm: $yes,
  }

  match $package_manager {
    nix => { nix_uninstall $yes $packages ; exit 0 },
    brew => { brew_uninstall $yes $packages ; exit 0 },
    pipx => { pipx_uninstall $yes $packages ; exit 0 },
  }

  distrobox_uninstall $package_data (match $package_manager {
    apt => { box_distro: "ubuntu", uninstaller_command: "sudo apt-get autoremove -y" },
    paru => { box_distro: "arch", uninstaller_command: "paru -Rns --noconfirm" } ,
    pacman => { box_distro: "arch", uninstaller_command: "sudo pacman -Rns --noconfirm" },
    dnf | yum => { box_distro: "fedora", uninstaller_command: "sudo dnf remove -y" },
    _ => { echo $"Invalid package manager ($manager), see studio manager --help argument to get a list of valid package managers" }
  })
}
