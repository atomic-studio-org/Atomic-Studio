use user_interaction.nu [fancy_prompt_message, user_prompt]

export def gen_export_string [packages: list<string>, export_Path: string] {
    return ($packages | each {|package| $"distrobox-export --app ($package) ; distrobox-export --export-path ($export_Path) --bin /usr/bin/($package)" } | str join " ; ")
}

export const DISTROBOXES_META = [
  ["aliases","name", "image", "description"];
  ["ubuntu", "ubuntubox", "ghcr.io/ublue-os/ubuntu-toolbox:latest", "Ubuntu based distrobox"]
  ["arch", "archbox", "ghcr.io/ublue-os/arch-distrobox:latest", "Arch Linux based distrobox with paru pre-installed"]
  ["fedora", "fedorabox", "ghcr.io/ublue-os/fedora-toolbox", "Fedora based distrobox"]
]

export def create_container_optional [yes: bool, container: record<name: string, description: string, image: string>] {
  try { distrobox ls | grep $container.name } catch {
    fancy_prompt_message $container.description
    if not (user_prompt $yes) {
      return 0
    }
    distrobox create -Y --pull -i $container.image --name $container.name 
  }
}

