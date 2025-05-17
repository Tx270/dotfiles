#!/bin/bash

LOG_FILE="$HOME/installation-log"
exec > >(tee -a "$LOG_FILE") 2>&1

log_section() {
    echo -e "\n\033[1;34m===== $1 =====\033[0m"
}
pause() {
    read -p "Press Enter to continue..."
}

log_section "Setting up Fonts"
mkdir -p ~/.local/share/fonts/{meslo,departure}
for variant in Regular Bold Italic BoldItalic; do
    font_file="$HOME/.local/share/fonts/meslo/MesloLGSNerdFontMono-$variant.ttf"
    if [ ! -f "$font_file" ]; then
        curl -L "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20$variant.ttf" -o "$font_file"
    fi
done
fc-cache -fv
pause

log_section "Installing Oh-My-Zsh and Plugins"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
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
pause

log_section "Configuring Audio"
systemctl --user mask pulseaudio.socket pulseaudio.service
systemctl --user --now enable pipewire pipewire-pulse wireplumber
pause

log_section "Installing Pywal and Ensuring pipx Path"
if ! command -v wal &> /dev/null; then
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
    pipx install pywal16
fi
pause

log_section "Installing Cargo Tools"
export PATH="$HOME/.cargo/bin:$PATH"
[ ! -f ~/.cargo/bin/yazi ] && cargo install yazi-fm
[ ! -f ~/.cargo/bin/xcolor ] && cargo install xcolor
pause

log_section "Applying Dotfiles with Stow"
cd ~/.dotfiles && stow */
pause

log_section "Making Scripts Executable"
find ~/.config -name "*.sh" -type f -exec chmod +x {} \;
pause

log_section "Installing and Configuring Betterlockscreen"
if [ ! -f /usr/local/bin/betterlockscreen ]; then
    git clone https://github.com/betterlockscreen/betterlockscreen.git /tmp/betterlockscreen
    cd /tmp/betterlockscreen
    sudo install -Dm755 betterlockscreen /usr/local/bin/
    betterlockscreen -u ~/.config/backgrounds/nice-blue-background.png
fi
pause

log_section "Applying pywal Theme"
~/.config/wal/wal.sh
pause

log_section "Setting up Crontab for Sysmonitor"
if ! crontab -l | grep -q sysmonitor.sh; then
    (crontab -l 2>/dev/null; echo "*/10 * * * * ~/.config/sysmonitor.sh") | crontab -
fi
pause

log_section "User Configuration Complete"
echo "User environment ready."
