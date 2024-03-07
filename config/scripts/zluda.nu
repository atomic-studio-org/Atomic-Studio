#!/usr/bin/env -S nu

let ZLUDA_LATEST = (http get https://api.github.com/repos/vosen/ZLUDA/releases/latest | get assets | where {|e| $e.name | str ends-with $"-linux.tar.gz" } | get browser_download_url).0 

http get $ZLUDA_LATEST | save -f /tmp/zluda.tar.gz

mkdir /tmp/zluda
tar --strip-components 1 -xvzf /tmp/zluda.tar.gz -C /tmp/zluda
mv /tmp/zluda /usr/lib64/zluda

rm -f /tmp/zluda.tar.gz
