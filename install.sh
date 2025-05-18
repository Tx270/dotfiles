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
apt-get update
apt-get upgrade -y
pause

log_section "Installing Essential Packages"
apt-get install -y curl git stow build-essential libpam0g-dev libxcb-xkb-dev python3-pip python3-venv imagemagick autoconf pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev libgif-dev
pause

log_section "Installing Desktop Environment"
apt-get install -y xorg xinit i3 xcompmgr i3lock
pause

log_section "Installing UI Components"
apt-get install -y polybar rofi dunst feh maim xclip xsel libnotify-bin
pause

log_section "Installing Terminal and Editor"
apt-get install -y kitty neovim
pause

log_section "Installing Audio System"
apt-get install -y pipewire pipewire-audio-client-libraries libspa-0.2-bluetooth wireplumber pamixer playerctl
pause

log_section "Installing Bluetooth Support"
apt-get install -y bluez bluez-tools
systemctl enable bluetooth
pause

log_section "Installing System Utilities and Shell"
apt-get install -y htop bc smartmontools network-manager zsh nala zip bat atuin pipx ruby ruby-dev cargo
pause

log_section "Installing Applications"
if [ ! -f /etc/apt/sources.list.d/spotify.list ]; then
    curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    apt-get update
fi
apt-get install -y spotify-client firefox-esr thunar
pause

log_section "Configuring Desktop Files"
spotify_icon_dir="$USER_HOME/.local/share/applications"
mkdir -p "$spotify_icon_dir"
cat > "$spotify_icon_dir/spotify.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Spotify
GenericName=Music Player
Icon=/usr/share/icons/hicolor/256x256/apps/spotify.png
Exec=spotify %U
Terminal=false
Categories=Audio;Music;Player;
EOF
chown "$REAL_USER:$REAL_USER" "$spotify_icon_dir/spotify.desktop"
rm -f /usr/share/applications/{rofi-theme-selector,org.pulseaudio.pavucontrol,rofi,thunar-settings,display-im7.q16}.desktop 2>/dev/null
pause

set -e

log_section "Building and Installing Neofetch"
if [ ! -f /usr/bin/neofetch ]; then
    git clone https://github.com/dylanaraps/neofetch.git /tmp/neofetch
    cd /tmp/neofetch
    make install
fi
pause

log_section "Building and Installing ly Display Manager"
if [ ! -f /usr/bin/ly ]; then
    curl -sLo /tmp/zig.zip https://ziglang.org/download/0.14.0/zig-linux-x86_64-0.14.0.zip
    unzip -q /tmp/zig.zip -d /tmp/zigdir
    export PATH="/tmp/zigdir/zig-linux-x86_64-0.14.0:$PATH"
    git clone https://github.com/cylgom/ly.git /tmp/ly
    cd /tmp/ly
    zig build
    zig build installexe
    sudo systemctl enable ly.service
    rm -rf /tmp/zig.zip /tmp/zigdir /tmp/ly
fi
pause

log_section "Building and Installing i3lock-color"
if [ ! -f /usr/local/bin/i3lock-color ]; then
    git clone https://github.com/Raymo111/i3lock-color.git /tmp/i3lock-color
    cd /tmp/i3lock-color
    ./install-i3lock-color.sh
    cd /tmp
    rm -rf /tmp/i3lock-color
fi
pause

log_section "Building and Installing Betterlockscreen"
if [ ! -f /usr/local/bin/betterlockscreen ]; then
    echo "Instalacja betterlockscreen..."
    wget https://github.com/betterlockscreen/betterlockscreen/archive/refs/heads/main.zip -O /tmp/betterlockscreen.zip
    unzip /tmp/betterlockscreen.zip -d /tmp
    cd /tmp/betterlockscreen-main

    chmod +x betterlockscreen
    sudo cp betterlockscreen /usr/local/bin/

    sudo cp system/betterlockscreen@.service /usr/lib/systemd/system/
    sudo systemctl enable betterlockscreen@$REAL_USER
fi
pause

echo "System instllation finished. You can reboot now and then run userInstall.sh."
