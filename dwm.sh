#!/bin/bash

xbps-install -Syu
xbps-install -y base-devel git libX11-devel libXft-devel libXinerama-devel xorg-minimal xinit xsetroot dmenu pcmanfm NetworkManager nano sudo firefox

ln -s /etc/sv/dbus /var/service/
ln -s /etc/sv/NetworkManager /var/service/

echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
usermod -aG wheel maximo

mkdir -p /home/maximo/.local/src
cd /home/maximo/.local/src

git clone https://git.suckless.org/st
cd st && make clean install && cd ..

git clone https://git.suckless.org/dwm
cd dwm
cp config.def.h config.h

sed -i 's/Mod1Mask/Mod4Mask/g' config.h
sed -i 's/{ MODKEY|ShiftMask,             XK_Return, spawn,/          { MODKEY,                       XK_Return, spawn,/' config.h
sed -i 's/{ MODKEY,                       XK_p,      spawn,/          { MODKEY,                       XK_space,  spawn,/' config.h
sed -i '/static const char \*termcmd/i static const char *ffcmd[] = { "firefox", NULL };\nstatic const char *fmcmd[] = { "pcmanfm", NULL };' config.h
sed -i '/{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },/a \	{ MODKEY,                       XK_b,      spawn,          {.v = ffcmd } },\n	{ MODKEY,                       XK_f,      spawn,          {.v = fmcmd } },' config.h

make clean install
cd ..

cat << 'EOF' > /home/maximo/.xinitrc
while true; do
    xsetroot -name " $(date '+%d/%m/%Y %H:%M') "
    sleep 60
done &
exec dwm
EOF

if ! grep -q "startx" /home/maximo/.bashrc; then
cat << 'EOF' >> /home/maximo/.bashrc
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec startx
fi

alias apagar='sudo poweroff'
alias reiniciar='sudo reboot'
alias actualizar='sudo xbps-install -Syu'
EOF
fi

chown -R maximo:maximo /home/maximo/.local /home/maximo/.xinitrc /home/maximo/.bashr
