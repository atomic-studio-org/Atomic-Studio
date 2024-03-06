#!/usr/bin/env -S nu
def "main" [
    yaml_file: string
] {
  ($yaml_file | from yaml).scripts | each {
    | script | { run-external $script | complete }
  }
}
