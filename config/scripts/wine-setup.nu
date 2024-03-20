#!/usr/bin/env nu

use lib/std.nu [ARCH]

let FEDORA_MAJOR_VERSION = (run-external --redirect-combine rpm '-E' '%fedora' | complete).stdout

[
  $"https://copr.fedorainfracloud.org/coprs/patrickl/pipewire-wineasio/repo/fedora-($FEDORA_MAJOR_VERSION)/patrickl-pipewire-wineasio-fedora-($FEDORA_MAJOR_VERSION).repo"
  $"https://copr.fedorainfracloud.org/coprs/patrickl/yabridge/repo/fedora-($FEDORA_MAJOR_VERSION)/patrickl-yabridge-fedora-($FEDORA_MAJOR_VERSION).repo"
  $"https://copr.fedorainfracloud.org/coprs/patrickl/wine-tkg/repo/fedora-($FEDORA_MAJOR_VERSION)/patrickl-wine-tkg-fedora-($FEDORA_MAJOR_VERSION).repo?arch=($ARCH)"
  $"https://copr.fedorainfracloud.org/coprs/patrickl/wine-mono/repo/fedora-($FEDORA_MAJOR_VERSION)/patrickl-wine-mono-fedora-($FEDORA_MAJOR_VERSION).repo"
  $"https://copr.fedorainfracloud.org/coprs/patrickl/vkd3d/repo/fedora-($FEDORA_MAJOR_VERSION)/patrickl-vkd3d-fedora-($FEDORA_MAJOR_VERSION).repo?arch="
  $"https://copr.fedorainfracloud.org/coprs/patrickl/wine-dxvk/repo/fedora-($FEDORA_MAJOR_VERSION)/patrickl-wine-dxvk-fedora-($FEDORA_MAJOR_VERSION).repo?arch=($ARCH)"
  $"https://copr.fedorainfracloud.org/coprs/patrickl/winetricks/repo/fedora-($FEDORA_MAJOR_VERSION)/patrickl-winetricks-fedora-($FEDORA_MAJOR_VERSION).repo"
  $"https://copr.fedorainfracloud.org/coprs/patrickl/libcurl-gnutls/repo/fedora-($FEDORA_MAJOR_VERSION)/patrickl-libcurl-gnutls-fedora-($FEDORA_MAJOR_VERSION).repo"
] | each { |e| http get $e | append "\n" | save -a /etc/yum.repos.d/wine-related.repo }

rpm-ostree install zenity wine.($ARCH) wine-dxvk.($ARCH) wine.i686 wine-dxvk.i686 mingw32-wine-gecko mingw64-wine-gecko yabridge pipewire-wineasio libcurl-gnutls icoutils perl-Image-ExifTool winetricks

git clone https://github.com/fastrizwaan/WineZGUI /tmp/winezgui
cd /tmp/winezgui
./setup --install

ln -s /usr/bin/wineserver64 /usr/bin/wineserver
ln -s /usr/bin/wine64 /usr/bin/wine

rm /etc/yum.repos.d/wine-related.repo
