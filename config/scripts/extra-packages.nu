#!/usr/bin/env -S nu
use lib/std.nu [get_arch, fetch_generic]

const BREW_TARGET = "/usr/libexec/brew-install"
let ARCH = (get_arch)

http get "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" | save -f "$BREW_TARGET"
run-external chmod '+x' "$BREW_TARGET"

let GUM_LATEST = (http get https://api.github.com/repos/charmbracelet/gum/releases/latest | get assets | where {|e| $e.name | str ends-with $"($ARCH).rpm" } | get browser_download_url).0
let GUM_RPM = (fetch_generic $GUM_LATEST ".rpm")
run-external rpm-ostree install $GUM_RPM
rm -f $GUM_RPM
