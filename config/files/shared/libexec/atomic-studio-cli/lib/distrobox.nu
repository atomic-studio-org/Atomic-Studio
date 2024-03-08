export const DISTROBOX_DOWNLOAD_URL = "https://raw.githubusercontent.com/89luca89/distrobox/main/install"

export def gen_export_string [package: string, export_Path: string] {
    return $"distrobox-export --app ($package) ; distrobox-export --export-path ($export_Path) --bin /usr/bin/($package)"
}

export const distroboxes = [
  ["aliases","name", "image", "description"];
  ["ubuntu", "ubuntubox", "ghcr.io/ublue-os/ubuntu-toolbox:latest", "Ubuntu based distrobox"]
  ["arch", "archbox", "ghcr.io/ublue-os/arch-distrobox:latest", "Arch Linux based distrobox with paru pre-installed"]
  ["fedora", "fedorabox", "ghcr.io/ublue-os/fedora-toolbox", "Fedora based distrobox"]
]
