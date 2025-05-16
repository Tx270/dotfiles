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
apt-get install -y curl git stow build-essential libpam0g-dev libxcb-xkb-dev
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

log_section "Installing System Utilities"
apt-get install -y htop bc smartmontools network-manager
pause

log_section "Installing Applications"

apt-get install -y firefox-esr thunar

if [ ! -f /etc/apt/sources.list.d/spotify.list ]; then
    curl -sS https:
    echo "deb https://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list
    apt-get update
fi
apt-get install -y spotify-client

if [ ! -f /usr/local/bin/neofetch ]; then
    git clone https:
    cd /tmp/neofetch
    make
    make install
fi
pause

log_section "Installing Display Manager"
if [ ! -f /usr/local/bin/ly ]; then

    mkdir -p /tmp/zig
    curl -L https:
    export PATH="/tmp/zig:$PATH"

    git clone https:
    cd /tmp/ly
    zig build
    zig build installexe
    systemctl enable ly.service
fi
pause

log_section "Configuring User Environment"
su - "$REAL_USER" << 'EOF'

mkdir -p ~/.local/share/fonts/{meslo,departure}

for variant in Regular Bold Italic BoldItalic; do
    font_file="$HOME/.local/share/fonts/meslo/MesloLGSNerdFontMono-$variant.ttf"
    if [ ! -f "$font_file" ]; then
        curl -L "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20$variant.ttf" -o "$font_file"
    fi
done
fc-cache -fv

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https:
fi

plugins=(
    "https://github.com/zsh-users/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-syntax-highlighting"
)
for plugin in "${plugins[@]}"; do
    repo_name=$(basename "$plugin")
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$repo_name" ]; then
        git clone "$plugin" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$repo_name"
    fi
done

systemctl --user mask pulseaudio.socket pulseaudio.service
systemctl --user --now enable pipewire pipewire-pulse wireplumber

if ! command -v wal &> /dev/null; then
    pipx install pywal16
    pipx ensurepath
fi

export PATH="$HOME/.cargo/bin:$PATH"
[ ! -f ~/.cargo/bin/yazi ] && cargo install yazi-fm
[ ! -f ~/.cargo/bin/xcolor ] && cargo install xcolor

cd ~/.dotfiles && stow */

find ~/.config -name "*.sh" -type f -exec chmod +x {} \;

if [ ! -f /usr/local/bin/betterlockscreen ]; then
    git clone https:
    cd /tmp/betterlockscreen
    sudo install -Dm755 betterlockscreen /usr/local/bin/
    betterlockscreen -u ~/.config/backgrounds/nice-blue-background.png
fi

~/.config/wal/wal.sh

if ! crontab -l | grep -q sysmonitor.sh; then
    (crontab -l 2>/dev/null; echo "*/10 * * * * ~/.config/sysmonitor.sh") | crontab -
fi
EOF

log_section "Configuring Spotify"
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

log_section "Cleaning Desktop Files"
rm -f /usr/share/applications/{rofi-theme-selector,org.pulseaudio.pavucontrol,rofi,thunar-settings,display-im7.q16}.desktop 2>/dev/null

log_section "Setting Default Shell"
chsh -s "$(which zsh)" "$REAL_USER"

log_section "Installation Complete"
echo "System ready for reboot"
