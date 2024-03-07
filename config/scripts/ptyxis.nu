#!/usr/bin/env -S nu 

use lib/std.nu [ARCH]

let FEDORA_MAJOR_VERSION = (run-external --redirect-combine rpm '-E' '%fedora' | complete).stdout
const COPR_FILE = "/etc/yum.repos.d/_copr_kylegospo-prompt.repo"

http get "https://copr.fedorainfracloud.org/coprs/kylegospo/prompt/repo/fedora-($FEDORA_MAJOR_VERSION)/kylegospo-prompt-fedora-($FEDORA_MAJOR_VERSION).repo?arch=($ARCH)" | save -f $COPR_FILE 

rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:prompt \
    vte291 \
    vte-profile \
    libadwaita

rpm-ostree install ptyxis

rm -f $COPR_FILE 
