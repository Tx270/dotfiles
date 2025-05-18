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
if [ ! -f "$HOME/.local/share/fonts/Meslo/MesloLGS NF Regular.ttf" ]; then
  mkdir -p "$HOME/.local/share/fonts/" && cd /tmp || exit 1
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip -O Meslo.zip || exit 2
  unzip -oq Meslo.zip -d Meslo || exit 3
  cp Meslo "$HOME/.local/share/fonts" || exit 4
  fc-cache -f > /dev/null
  rm -rf Meslo Meslo.zip
  echo "Meslo Nerd fonts installed"
fi
pause

log_section "Installing Zsh Plugins"
sudo chsh -s "$(which zsh)" "$(logname)"
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
rm -r ~/.config/neofetch
cd ~/.dotfiles
stow */
find ~/.config -name "*.sh" -type f -exec chmod +x {} \;
pause

log_section "Setting up Crontab for Sysmonitor"
if ! crontab -l | grep -q sysmonitor.sh; then
    (crontab -l 2>/dev/null; echo "*/10 * * * * ~/.config/sysmonitor.sh") | crontab -
fi
pause

log_section "User Configuration Complete"
echo "User environment ready."
