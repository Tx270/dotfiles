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
apt-get install -y curl git stow build-essential libpam0g-dev libxcb-xkb-dev python3-pip python3-venv
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
apt-get install -y htop bc smartmontools network-manager zsh nala zip batcat pipx ruby ruby-dev
pause

log_section "Installing Applications"
if [ ! -f /etc/apt/sources.list.d/spotify.list ]; then
    curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    apt-get update
fi
apt-get install -y spotify-client firefox-esr thunar
pause

set -e
log_section "Building and Installing Neofetch"
if [ ! -f /usr/local/bin/neofetch ]; then
    git clone https://github.com/dylanaraps/neofetch.git /tmp/neofetch
    cd /tmp/neofetch
    make
    make install
fi
pause

log_section "Building and Installing ly Display Manager"
if [ ! -f /usr/local/bin/ly ]; then
    curl -sLO https://ziglang.org/download/0.14.0/zig-linux-x86_64-0.14.0.tar.xz
    tar -xf zig-linux-x86_64-0.14.0.tar.xz
    export PATH="$PWD/zig-linux-x86_64-0.14.0:$PATH"
    git clone https://github.com/cylgom/ly.git /tmp/ly
    cd /tmp/ly
    zig build
    zig build installexe
    systemctl enable ly.service
    rm -rf "$PWD/zig-linux-x86_64-0.14.0" "$PWD/zig-linux-x86_64-0.14.0.tar.xz" /tmp/ly
fi
pause

set +e

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

log_section "Installing and Configuring Betterlockscreen"
if [ ! -f /usr/local/bin/betterlockscreen ]; then
    git clone https://github.com/betterlockscreen/betterlockscreen.git /tmp/betterlockscreen
    cd /tmp/betterlockscreen
    sudo install -Dm755 betterlockscreen /usr/local/bin/
fi

echo "System instllation finished. You can reboot now and then run userInstall.sh."
