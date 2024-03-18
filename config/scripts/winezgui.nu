#!/usr/bin/env nu
git clone https://github.com/fastrizwaan/WineZGUI /tmp/winezgui
cd /tmp/winezgui
./setup --install
ln -s /usr/bin/wine64 /usr/bin/wine
ln -s /usr/bin/wineserver64 /usr/bin/wineserver
