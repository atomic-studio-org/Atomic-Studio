#!/usr/bin/env -S nu

const STUDIO_TEMPLATE_PATH = "/usr/share/ublue-os/atomic-studio/templates/main.md"
const escape_patterns = [
  [source, output];
  ["[", '\['],
  ["]", '\]'],
  ["/", '\/'],
  ["&", '\&']
]

def replace_format [
  replacers: table<source: string, output: string> # Sources and outputs for the templates
  values: list<string> # The table where the values will be replaced
] {
  mut final_value = $values

  let max_iter = ($replacers | length)
  mut iter = 0
  loop {
    if $iter == $max_iter { 
      break
    }
    $final_value = ($final_value | str replace --all $replacers.$iter.$source $replacers.$iter.$replace)
    iter += 1
  }

  return final_value
}

# Turn MOTD off
export def "main motd off" [] {
  let MOTD_DISABLED_FILE = $"($env.HOME)/.config/atomic-studio/motd_disabled"
  if ($MOTD_DISABLED_FILE | path exists) {
    echo "MOTD is already disabled"
    exit 0
  }
  mkdir ($MOTD_DISABLED_FILE | path dirname) 
  touch $MOTD_DISABLED_FILE
  echo "Disabled MOTD for the current user"
}

# Turn MOTD on
export def "main motd on" [] {
  let MOTD_DISABLED_FILE = $"($env.HOME)/.config/atomic-studio/motd_disabled"
  if not ($MOTD_DISABLED_FILE | path exists) {
    echo "MOTD is already enabled"
    exit 0
  }
  rm $MOTD_DISABLED_FILE
  echo "Enabled MOTD for the current user"
}

# Display current MOTD text
export def "main motd" [
  --motd_path (-m): string # Path where MOTDs are stored
  --image_info_path (-i): string # Path operating system information is stored (as json)
  --template_path (-t): string # Which template will be used for displaying the MOTD
  --no-tip (-n) # Do not display tip 
] {
  let MOTD_DISABLED_FILE = $"($env.HOME)/.config/atomic-studio/motd_disabled"
  if ($MOTD_DISABLED_FILE | path exists) {
    exit 0
  }

  mut TEMPLATE_PATH = $STUDIO_TEMPLATE_PATH 
  if $template_path != null {
    $TEMPLATE_PATH = $template_path
  }
  
  mut MOTD_PATH = "/usr/share/ublue-os/atomic-studio/motd/tips"
  if $motd_path != null {
    $MOTD_PATH = $motd_path
  }

  mut IMAGE_INFO_PATH = "/usr/share/ublue-os/image-info.json"
  if $image_info_path != null {
    $IMAGE_INFO_PATH = $image_info_path
  }

  let CURRENT_TIP_FILE = (ls $MOTD_PATH | where { |e| ($e.type == "file") and ($e.name | str ends-with txt) } | shuffle | get 0.name)
  let IMAGE_INFO = (open $IMAGE_INFO_PATH)
  let IMAGE_NAME = (($IMAGE_INFO).image-ref | sed -e 's|ostree-image-signed:docker://ghcr.io/.*/||' -e 's|ostree-unverified-registry:ghcr.io/.*/||' )
  mut TIP = "󰋼 (open $CURRENT_TIP_FILE | lines | shuffle | get 0 | str join)"
  
  let IMAGE_DATE = (rpm-ostree status --booted | sed -n 's/.*Timestamp: \(.*\)/\1/p')
  let IMAGE_DATE_SECONDS = (run-external date '-d' "$IMAGE_DATE" +%s --redirect-combine | capture).stdout

  let CURRENT_SECONDS = (run-external date +%s | capture).stdout
  let DIFFERENCE = ($CURRENT_SECONDS - $IMAGE_DATE_SECONDS)
  let MONTH = (30 * 24 * 60 * 60)
  if $DIFFERENCE >= $MONTH {
    $TIP = '#  Your current image is over 1 month old, run `studio-update`'
  }
 
  if $no_tip != null {
    $TIP = ""
  }

  (replace_format [
    ["source", "output"]; 
    ["%IMAGE_NAME%" (replace_format $escape_patterns $IMAGE_NAME)]
    ["%IMAGE_TAG%" (replace_format $escape_patterns ($IMAGE_INFO).image-tag)] 
    ["%TIP%" (replace_format $escape_patterns ($TIP | lines))]
  ] (open $TEMPLATE_PATH | lines -s)) | str join "\n" | run-external glow '-s' auto '-'
}

