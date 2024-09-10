export def get_arch [] {
  return "x86_64"
}

export def get_fedora_version [] {
  return (run-external rpm '-E' '%fedora' | complete).stdout
}

export def fetch_generic [url: string, suffix: string] {
  let temporary_place = (mktemp -t --suffix $suffix)
  http get $url | save -f $temporary_place
  return $temporary_place
}

export def fetch_copr [url: string] {
  let copr_name = (mktemp --tmpdir-path "/etc/yum.repos.d/" --suffix ".repo")
  http get $url | save -f $copr_name
  return $copr_name
}
