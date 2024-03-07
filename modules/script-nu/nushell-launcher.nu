#!/usr/bin/env -S nu
def "main" [
    yaml_file: string
] {
  ($yaml_file | from yaml).scripts | par-each {
    | script | do { run-external $script | complete }
  }
}
