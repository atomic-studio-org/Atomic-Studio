#!/usr/bin/env -S nu

use lib/std.nu [ARCH]

const BREW_TARGET = "/usr/libexec/brew-install"

http get "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" | save -f "$BREW_TARGET"
run-external chmod '+x' "$BREW_TARGET"

let GUM_LATEST = (http get https://api.github.com/repos/charmbracelet/gum/releases/latest | get assets | where {|e| $e.name | str ends-with $"($ARCH).rpm" } | get browser_download_url.0) 

http get $GUM_LATEST | save -f /tmp/gum.rpm
run-external rpm-ostree install /tmp/gum.rpm
rm /tmp/gum.rpm
