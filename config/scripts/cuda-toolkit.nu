#!/usr/bin/env -S nu 

use lib/std.nu [ARCH]

let FEDORA_MAJOR_VERSION = (run-external --redirect-combine rpm '-E' '%fedora' | complete).stdout
const COPR_FILE = "/etc/yum.repos.d/_cuda-toolkit.repo"

http get $"https://developer.download.nvidia.com/compute/cuda/repos/fedora($FEDORA_MAJOR_VERSION)/($ARCH)/cuda-fedora($FEDORA_MAJOR_VERSION).repo" | save -f $COPR_FILE 

rpm-ostree install cuda-toolkit-12-4

rm -f $COPR_FILE 
