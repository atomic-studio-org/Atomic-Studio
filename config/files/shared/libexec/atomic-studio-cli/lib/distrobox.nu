export const DISTROBOX_DOWNLOAD_URL = "https://raw.githubusercontent.com/89luca89/distrobox/main/install"

export def gen_export_string [package: string, export_Path: string] {
    return $"distrobox-export --app ($package) ; distrobox-export --export-path ($export_Path) --bin /usr/bin/($package)"
}