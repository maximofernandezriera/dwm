#!/bin/bash

apt update && apt upgrade -y
apt install -y sudo nano git xserver-xorg-core xinit x11-xserver-utils build-essential libx11-dev libxft-dev libxinerama-dev dmenu pcmanfm wget gnupg network-manager wpasupplicant

usermod -aG sudo maximo
systemctl enable NetworkManager

curl -fsSL https://deb.librewolf.net/keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/librewolf.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/librewolf.gpg] https://deb.librewolf.net $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/librewolf.list
apt update && apt install -y librewolf

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
sed -i '/static const char \*termcmd/i static const char *wolfcmd[] = { "librewolf", NULL };\nstatic const char *fmcmd[] = { "pcmanfm", NULL };' config.h
sed -i '/{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },/a \	{ MODKEY,                       XK_b,      spawn,          {.v = wolfcmd } },\n	{ MODKEY,                       XK_f,      spawn,          {.v = fmcmd } },' config.h

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
EOF
fi

chown -R maximo:maximo /home/maximo/.local /home/maximo/.xinitrc /home/maximo/.bashrc
