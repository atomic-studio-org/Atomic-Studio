#!/usr/bin/env -S nu
use lib/std.nu [fetch_copr, get_fedora_version]
let FEDORA_MAJOR_VERSION = (get_fedora_version)
let COPR_FILE = (fetch_copr $"https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/repo/fedora-($FEDORA_MAJOR_VERSION)/kylegospo-wallpaper-engine-kde-plugin-fedora-($FEDORA_MAJOR_VERSION).repo")
let PLUGIN_CLONE_TARGET = (mktemp -d)

rpm-ostree install wallpaper-engine-kde-plugin

git clone https://github.com/catsout/wallpaper-engine-kde-plugin.git --depth 1 $PLUGIN_CLONE_TARGET
kpackagetool5 --type=Plasma/Wallpaper --global --install $"($PLUGIN_CLONE_TARGET)/plugin"

rm -rf $PLUGIN_CLONE_TARGET
rm -f $COPR_FILE
