#!/usr/bin/env -S nu
def "main" [
    yaml_file: string
] {
  for $script in ($yaml_file | from yaml).scripts {
    run-external $"/tmp/config/scripts/($script)"
  }
}
