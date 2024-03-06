#!/usr/bin/env -S nu 

def "main" [
    yaml_file: string
] {
  chmod +x $"($env.PWD)/scripts/*"
  (open $yaml_file).scripts | each {
    | script | { run-external $script }
  }
}
