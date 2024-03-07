#!/usr/bin/env -S nu

let ZLUDA_LATEST = (http get https://api.github.com/repos/vosen/ZLUDA/releases/latest | get assets | where {|e| $e.name | str ends-with $"-linux.tar.gz" } | get browser_download_url).0 

http get $ZLUDA_LATEST | save -f /tmp/zluda.tar.gz

mkdir /tmp/zluda

try {
  tar --strip-components 1 -xvzf /tmp/zluda.tar.gz -C /tmp/zluda
} catch {
  echo "Failed extracting the entire zluda file for some reason."
}

rm -f /tmp/zluda.tar.gz
mv /tmp/zluda /usr/lib64/zluda
