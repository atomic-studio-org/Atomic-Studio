#!/usr/bin/env -S nu
use lib/std.nu [get_arch, fetch_generic]

let ARCH = (get_arch)
let ARCH_ZAP = "amd64"

const BREW_TARGET = "/usr/libexec/brew-install"
http get "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" | save -f $BREW_TARGET
run-external chmod '+x' $BREW_TARGET

let GUM_LATEST = (http get https://api.github.com/repos/charmbracelet/gum/releases/latest | get assets | where {|e| $e.name | str ends-with $"($ARCH).rpm" } | get browser_download_url).0
let GUM_RPM = (fetch_generic $GUM_LATEST ".rpm")
run-external rpm-ostree install $GUM_RPM
rm -f $GUM_RPM

let ZAP_TARGET = "/usr/bin/zap"
let ZAP_LATEST = (http get https://api.github.com/repos/srevinsaju/zap/releases/latest | get assets | where {|e| $e.name | str ends-with $"($ARCH_ZAP)" } | get browser_download_url).0
let ZAP_BIN = (fetch_generic $ZAP_LATEST "")
mv $ZAP_BIN $ZAP_TARGET
run-external chmod '+x' $ZAP_TARGET
