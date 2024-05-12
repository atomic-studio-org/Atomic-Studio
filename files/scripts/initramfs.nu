#!/usr/bin/env -S nu

let KERNEL_SUFFIX = "" # SHOULD INCLUDE "-" AFTER!

# TODO: Implement KERNEL_SUFFIX here without major breakages
let QUALIFIED_KERNEL = (run-external 'rpm' '-qa' --redirect-stdout | complete | get stdout | lines | find --regex '^kernel-[0-9]*\.[0-9]*\.[0-9]*' | str replace $'kernel-' "").0

rpm-ostree cliwrap install-to-root /
/usr/libexec/rpm-ostree/wrapped/dracut '--no-hostonly' '--kver' $"($QUALIFIED_KERNEL)" '--reproducible' '-v' '--add' 'ostree' '-f' $"/lib/modules/($QUALIFIED_KERNEL)/initramfs.img"

chmod '0600' $"/lib/modules/($QUALIFIED_KERNEL)/initramfs.img"
