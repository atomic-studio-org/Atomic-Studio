#!/usr/bin/env -S nu
def "main" [
    yaml_file: string
] {
  for $script in ($yaml_file | from yaml).scripts {
    NU_LOG_LEVEL=DEBUG run-external $"/tmp/config/scripts/($script)"
  }
}
