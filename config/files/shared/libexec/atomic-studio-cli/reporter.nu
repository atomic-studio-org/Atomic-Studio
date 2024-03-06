#!/usr/bin/env -S nu --stdin

const fetch_info = ["hw", "audio", "packages", "podman", "systemd", "env"]

def table_commands [...commands: string] {
  return ($commands | par-each {
    |program|  
    { 
      command: $"($program)", 
      output: (run-external --redirect-stdout ($program | split words).0 ...($program | split row ' ' | skip 1 | each { |word| $"\'($word)\'" }) | complete).stdout
    }
  })
}

# List all available modules to export
export def "main reporter list" [] {
  echo $"($fetch_info | table)"
}

# Report system information to facilitate Atomic Studio development
export def "main reporter" [
  --method (-m): string # Method used for reporting, allowed values: ["fpaste", "termbin", "loopback"]
  --fetch_only # Only fetch, do not post anything anywhere
  ...fetch # Data that will be fetched (default: none)
] {
  mut method_command = ""
  $method_command = match $method {
    termbin => "nc termbin.com 9999",
    fpaste => "fpaste"
    loopback => "echo $in",
  }
  if $method == null {
    $method_command = "fpaste"
  }

  if not (is-terminal -i) {
    $in | nu --stdin -c $"($method_command)"
    return
  }

  $fetch | each { |fetch_arg|
     table_commands ...(match $fetch_arg {
      hw => { ["lscpu" "lsmem" "lsblk" "mount"] },
      audio => { ["pactl info", "pw-dump"] },
      packages => { ["rpm -qa" "rpm-ostree status -v"] },
      distrobox => { ["podman images" "distrobox ls" "podman ps -a"] },
      systemd => { ["systemctl status" "systemctl status --user"] },
      env => { ["$env"] }
      _ => [],
    })
  } | table -e --theme basic | nu --stdin -c $"($method_command)"
}
