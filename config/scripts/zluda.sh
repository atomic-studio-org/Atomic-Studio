#!/usr/bin/env bash
set -euo pipefail

wget "$(curl https://api.github.com/repos/vosen/ZLUDA/releases/latest | jq -r '.assets[] | select(.name| test(".*-linux.tar.gz$")).browser_download_url')" -O /tmp/zluda.tar.gz

mkdir -p /tmp/zluda
tar --strip-components 1 -xvzf /tmp/zluda.tar.gz -C /tmp/zluda
mv /tmp/zluda /usr/lib64/zluda
rm -f /tmp/zluda.tar.gz

