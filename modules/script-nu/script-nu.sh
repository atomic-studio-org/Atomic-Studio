#!/usr/bin/env -S nu 

def "main" [
    yaml_file: string
] {
  chmod +x "/tmp/config/scripts/*"
  ($yaml_file | from yaml).scripts | each {
    | script | { run-external $script }
  }
}
