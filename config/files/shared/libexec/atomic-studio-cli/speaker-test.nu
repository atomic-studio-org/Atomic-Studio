#!/usr/bin/env -S nu

# Test your speakers with espeak
export def "main speaker-test" [
  --wait (-w): duration # Amount of time to wait between tests
  --voice (-v): string # Espeak voice that will be used
  --exit (-e): int # Exit after "X" tests
  ...text: string
] {
  mut espeak_voice = "en+13"
  mut max_iterations = -1
  mut wait_time = 2sec
  mut speak_text: list<string> = ["Audio Jungle"]

  if $voice != null {
    $espeak_voice = $voice
  }
  if $wait != null {
    $wait_time = $wait
  }
  if $exit != null {
    $max_iterations = $exit
  }
  if ($text | length) != 0 {
    $speak_text = $text 
  }

  mut iterations = 0
  loop {
    if $iterations == $exit {
      exit 0
    }
    espeak-ng -v en+13 ...$speak_text
    sleep $wait_time 
    $iterations += 1
  }
}
