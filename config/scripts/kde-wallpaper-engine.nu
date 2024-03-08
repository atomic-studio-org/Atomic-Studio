#!/usr/bin/env -S nu
let FEDORA_MAJOR_VERSION = (run-external --redirect-combine rpm '-E' '%fedora' | complete).stdout
const COPR_FILE = "/etc/yum.repos.d/_copr_kylegospo-wallpaper-engine-kde-plugin.repo"
  
http get $"https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/repo/fedora-($FEDORA_MAJOR_VERSION)/kylegospo-wallpaper-engine-kde-plugin-fedora-($FEDORA_MAJOR_VERSION).repo" | save -f $COPR_FILE 

rpm-ostree install wallpaper-engine-kde-plugin

rm -f $COPR_FILE

git clone https://github.com/catsout/wallpaper-engine-kde-plugin.git --depth 1 /tmp/wallpaper-engine-kde-plugin

kpackagetool5 --type=Plasma/Wallpaper --global --install /tmp/wallpaper-engine-kde-plugin/plugin

rm -rf /tmp/wallpaper-engine-kde-plugin
