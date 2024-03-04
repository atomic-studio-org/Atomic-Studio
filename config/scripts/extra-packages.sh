#!/usr/bin/env bash
set -euo pipefail
BREW_TARGET=/usr/libexec/brew-install
ARCH="x86_64"

wget https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -O "$BREW_TARGET"
chmod +x "$BREW_TARGET"

rpm-ostree install "$(curl https://api.github.com/repos/charmbracelet/gum/releases/latest | jq -r '.assets[] | select(.name| test(".*.'"${ARCH}"'.rpm$")).browser_download_url')" 
