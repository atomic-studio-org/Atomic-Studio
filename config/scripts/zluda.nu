#!/usr/bin/env -S nu
use lib/std.nu [fetch_generic]

let ZLUDA_LATEST = (http get https://api.github.com/repos/vosen/ZLUDA/releases/latest | get assets | where {|e| $e.name | str ends-with $"-linux.tar.gz" } | get browser_download_url).0
let FETCHED_ZLUDA_PATH = (fetch_generic $ZLUDA_LATEST ".tar.gz")
let PATH_TARGET = "/usr/lib64/zluda"

mkdir $PATH_TARGET

try {
  tar --strip-components 1 -xvzf $FETCHED_ZLUDA_PATH -C $PATH_TARGET
} catch {
  echo "WARNING: Failed extracting the entire zluda file for some reason."
}

rm -f $FETCHED_ZLUDA_PATH
