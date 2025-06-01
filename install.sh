#!/bin/bash

LOG_FILE="$HOME/installation-log"
exec > >(tee -a "$LOG_FILE") 2>&1

log_section() {
    echo -e "\n\033[1;34m===== $1 =====\033[0m"
}
pause() {
    read -p "Press Enter to continue..."
}

if [ "$(id -u)" != 0 ]; then
    echo "This script must be run with sudo" >&2
    exit 1
fi

REAL_USER=$(logname)
USER_HOME="/home/$REAL_USER"

log_section "Updating System"
dnf update -y
pause

log_section "Installing Essential Packages"
dnf install -y curl git wget stow @development-tools pam-devel xcb-util-keysyms-devel python3-pip python3-virtualenv ImageMagick tar autoconf automake cairo-devel fontconfig gcc libev-devel libjpeg-turbo-devel libXinerama libxkbcommon-devel libxkbcommon-x11-devel libXrandr pam-devel pkgconf xcb-util-image-devel xcb-util-xrm-devel giflib-devel
pause

log_section "Installing Desktop Environment"
dnf install -y @base-x i3 xcompmgr
pause

log_section "Installing UI Components"
dnf install -y polybar rofi dunst feh maim xclip xsel libnotify
pause

log_section "Installing Audio System and Bluetooth"
dnf install -y pipewire wireplumber pamixer playerctl bluez bluez-tools
systemctl enable bluetooth
pause

log_section "Installing System Utilities and Shell"
dnf copr enable lihaohong/yazi
dnf install -y kitty neovim htop bc smartmontools NetworkManager NetworkManager-wifi zsh zip bat atuin python3-pip pipx ruby ruby-devel cargo yazi
pause

log_section "Installing Applications"
dnf install -y firefox thunar
pause

set -e

log_section "Building and Installing Neofetch"
if [ ! -f /usr/bin/neofetch ]; then
    git clone https://github.com/dylanaraps/neofetch.git /tmp/neofetch
    ( cd /tmp/neofetch && make install )
fi
pause

log_section "Building and Installing ly Display Manager"
if [ ! -f /usr/bin/ly ]; then
  curl -fsSL https://ziglang.org/download/0.14.0/zig-linux-x86_64-0.14.0.tar.xz -o /tmp/zig.tar.xz
  mkdir -p /tmp/zigdir && tar -xf /tmp/zig.tar.xz -C /tmp/zigdir
  export PATH="/tmp/zigdir/zig-linux-x86_64-0.14.0:$PATH"
  git clone https://github.com/cylgom/ly.git /tmp/ly && cd /tmp/ly
  zig build && zig build installexe
  systemctl enable ly.service
  rm -rf /tmp/zig.tar.xz /tmp/zigdir /tmp/ly
fi
pause

log_section "Building and Installing i3lock-color"
if [ ! -f /usr/local/bin/i3lock-color ]; then
    git clone https://github.com/Raymo111/i3lock-color.git /tmp/i3lock-color
    ( cd /tmp/i3lock-color && ./install-i3lock-color.sh )
    rm -rf /tmp/i3lock-color
fi
pause

log_section "Building and Installing Betterlockscreen"
if [ ! -f /usr/local/bin/betterlockscreen ]; then
    wget https://github.com/betterlockscreen/betterlockscreen/archive/refs/heads/main.zip -O /tmp/betterlockscreen.zip
    unzip /tmp/betterlockscreen.zip -d /tmp
    (
        cd /tmp/betterlockscreen-main || exit 1
        chmod +x betterlockscreen
        cp betterlockscreen /usr/local/bin/
        cp system/betterlockscreen@.service /usr/lib/systemd/system/
        systemctl enable betterlockscreen@$REAL_USER
    )
    rm -rf /tmp/betterlockscreen.zip /tmp/betterlockscreen-main
fi
pause

echo "System installation finished. You can reboot now and then run userInstall.sh."
