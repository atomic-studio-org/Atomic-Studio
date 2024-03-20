export def "main wine" [] {
  echo "Usage wine <command>."
}

# Workaround if your wine64 prefix is not working
export def "main wine init" [--no_64_bit] {
  rm ~/wine -rf
  if $no_64_bit != null {
    wineboot -i
  }
  WINEARCH=win32 wineboot -i
}

# Run anything through wine-tkg
export def "main wine run" [...rest] {
  if not ( $"($env.HOME)/.wine" | path exists) {
    studio wine init
  }
  wineserver64
  wine64 ...$rest
}

# Open the wine manager 
export def "main wine manager" [] {
  winezgui
}

# Register pipewire-wineasio DLL to default wine prefix
export def "main wine wineasio register" [] {
  wineasio-register
  regsvr32 wineasio.dll
}

# Unregister pipewire-wineasio DLL to default wine prefix
export def "main wine wineasio unregister" [] {
  regsvr64 /u wineasio.dll
}

# Scans a wine prefix for VSTPlugins folders
export def "main wine yabridge scan" [wine_prefix?: string] {
  mut targetPath = $wine_prefix
  if $wine_prefix == null {
    $targetPath = $"($env.HOME)/.wine"
  }

  let CURRENTPATH = (pwd) 
  cd $targetPath
  ls -a ./** | where { |e| $e.name | str ends-with VSTPlugins }
  cd $CURRENTPATH
}

# Scans a wine prefix for VSTPlugins folders
export def "main wine yabridge add" [wine_prefix?: string] {
  studio wine yabridge scan $wine_prefix | par-each { |found_folder| do { run-external yabridgectl add $found_folder.name } & }
  yabridgectl sync
}

# Sync yabridgectl database 
export def "main wine yabridge sync" [] {
  yabridgectl sync
}
