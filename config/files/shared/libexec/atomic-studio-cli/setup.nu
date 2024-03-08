use lib/std.nu [user_prompt, fancy_prompt_message]
use lib/distrobox.nu [DISTROBOX_DOWNLOAD_URL, distroboxes]

const opentabletdriver_service = "
[Unit]
Description=OpenTabletDriver Daemon
PartOf=graphical-session.target
After=graphical-session.target
ConditionEnvironment=|WAYLAND_DISPLAY
ConditionEnvironment=|DISPLAY

[Service]
ExecStart=/usr/bin/distrobox-enter  -n archbox -- ' /usr/bin/otd-daemon'
Restart=always
RestartSec=3

[Install]
WantedBy=graphical-session.target
"

# Setup Atomic Studio supported apps
export def "main setup" [] {
  echo "Usage setup <subcommand>."
}

# Install Davinci Resolve in a compatible distrobox
export def "main setup opentabletdriver" [
  --yes (-y) # Skip all confirmation prompts
] {
  if (which distrobox | length) == 0 {
    fancy_prompt_message "Distrobox"
    if not (user_prompt $yes) {
      return 
    }
    curl -s $DISTROBOX_DOWNLOAD_URL | pkexec sh
  }

  let archbox_entry = ($distroboxes | select aliases name image | where aliases == arch).0

  try { distrobox ls | grep ($archbox_entry.name) } catch { 
    fancy_prompt_message "The Arch Linux subsystem"
    if not (user_prompt $yes) {
      return 
    }
    distrobox create -i $archbox_entry.image --name $archbox_entry.name -Y --pull 
  }
  
  distrobox enter -n $archbox_entry.name -- ' paru -S opentabletdriver --noconfirm'
  mkdir $"($env.HOME)/.config/systemd/user"
  try { rm -f $"($env.HOME)/.config/systemd/user/($archbox_entry.name)-opentabletdriver.service" } catch { }
  
  $opentabletdriver_service | save -f $"($env.HOME)/.config/systemd/user/($archbox_entry.name)-opentabletdriver.service"

  systemctl --user daemon-reload
  systemctl enable --user --now $"($archbox_entry.name)-opentabletdriver.service"
  
  distrobox enter -n $archbox_entry.name -- 'distrobox-export --app otd-gui'
}
