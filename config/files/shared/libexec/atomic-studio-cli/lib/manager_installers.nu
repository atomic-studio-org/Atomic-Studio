use user_interaction.nu [fancy_prompt_message, user_prompt]
use distrobox.nu [gen_export_string, create_container_optional, DISTROBOXES_META]
use generic_install.nu [generic_script_installation, nix_installer, brew_installer, distrobox_installer] 

def package_manager_not_installed [package_manager: string] {
  echo $"($package_manager | str capitalize) is not installed."
}

export def distrobox_install [
  package_data: record<packages: list<string>, export_path: string, no_confirm: bool>
  manager: record<box_distro: string, installer_command: string>
] {
  if (which distrobox | length) == 0 {
    fancy_prompt_message "Distrobox"
    if not (user_prompt $package_data.no_confirm) {
      exit 0
    }
    generic_script_installation $package_data.no_confirm "distrobox" (distrobox_installer)
    exit 0
  }

  let box_name: string = ($DISTROBOXES_META | where aliases == $manager.box_distro | get name).0
  let box_alias: string = ($DISTROBOXES_META | where aliases == $manager.box_distro | get aliases | str join | str capitalize)
  let box_image: string = ($DISTROBOXES_META | where aliases == $manager.box_distro | get image | str join)
  
  create_container_optional $package_data.no_confirm {name: $box_name, description: $box_alias, image: $box_image }

  mkdir $package_data.export_path

  let packages_export = gen_export_string $package_data.packages $package_data.export_path
  distrobox enter $box_name -- sh -c $"($manager.installer_command) ($package_data.packages | str join ' ') && ($packages_export) 2> /dev/null" err> /dev/null
}

export def pipx_install [yes: bool, packages: list<string>] {
  for $package in $packages {
    run-external pipx install $package
  }
}

export def brew_install [yes: bool, packages: list<string>] {
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

export def nix_install [yes: bool, packages: list<string>] {
  if (which nix | length) != 0 {
    run-external nix profile install ($packages | each {|value| $"nixpkgs#($value)"} | str join) 
    exit 0
  }

  fancy_prompt_message Nix
  if not (user_prompt $yes) {
    exit 0
  }
  generic_script_installation $yes "nix" (nix_installer)
}

export def distrobox_uninstall [
  package_data: record<packages: list<string>, no_confirm: bool>
  manager: record<box_distro: string, uninstaller_command: string>
] {
  if (which distrobox | length) == 0 {
    package_manager_not_installed "distrobox"
    exit 0
  }

  let box_name: string = ($DISTROBOXES_META | where aliases == $manager.box_distro | get name).0
  let box_alias: string = ($DISTROBOXES_META | where aliases == $manager.box_distro | get aliases | str join | str capitalize)
  let box_image: string = ($DISTROBOXES_META | where aliases == $manager.box_distro | get image | str join)
  
  try { distrobox ls | grep $box_name } catch {
    echo "This package manager is not yet installed, please install it through studio manager install -m ($manager)"
    exit 0
  }
  distrobox enter $box_name -- sh -c $"($manager.uninstaller_command) ($package_data.packages | str join ' ')"
}

export def pipx_uninstall [yes: bool, packages: list<string>] {
  for $package in $packages {
    run-external pipx uninstall $package
  }
}

export def brew_uninstall [yes: bool, packages: list<string>] {
  let brew_path = "/home/linuxbrew/.linuxbrew/bin/brew"
  if ((which brew | length) == 0) and (not ($brew_path | path exists)) {
    exit 0 
  }
  run-external $brew_path uninstall ($packages | str join)
}

export def nix_uninstall [yes: bool, packages: list<string>] {
  if (which nix | length) == 0 {
    package_manager_not_installed "nix" 
    exit 0 
  }
  run-external nix profile remove ($packages | str join ' ')
}
