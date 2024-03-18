#!/usr/bin/env nu
git clone https://github.com/fastrizwaan/WineZGUI /tmp/winezgui
/tmp/winezgui/setup --install
ln -s /usr/bin/wine64 /usr/bin/wine
