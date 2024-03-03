#!/usr/bin/env bash
set -euo pipefail
BREW_TARGET=/usr/libexec/brew-install 

wget https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -O "$BREW_TARGET"

chmod +x "$BREW_TARGET"
