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
if [ ! -d "$HOME/.local/share/fonts/Meslo" ]; then
  mkdir -p "$HOME/.local/share/fonts/" && cd /tmp || exit 1
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip -O Meslo.zip || exit 2
  unzip -oq Meslo.zip -d Meslo || exit 3
  rm Meslo.zip
  mv Meslo "$HOME/.local/share/fonts" || exit 4
  fc-cache -f > /dev/null
  echo "Meslo Nerd fonts installed"
fi
pause

log_section "Installing Zsh Plugins"
sudo chsh -s "$(which zsh)" "$USER"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-allclear" ]; then
    git clone https://github.com/givensuman/zsh-allclear "$ZSH_CUSTOM/plugins/zsh-allclear"
fi
pause

log_section "Configuring Audio"
systemctl --user mask pulseaudio.socket pulseaudio.service || true
systemctl --user --now enable pipewire pipewire-pulse wireplumber
pause

log_section "Installing Pywal and Ensuring pipx Path"
if ! command -v wal &> /dev/null; then
    python3 -m pipx ensurepath
    pipx install pywal16
fi
pause

log_section "Compiling Cargo and Ruby Tools"
export PATH="$HOME/.cargo/bin:$PATH"
[ ! -f ~/.cargo/bin/xcolor ] && cargo install xcolor
if ! command -v colorls &> /dev/null; then
    gem install colorls --user-install
fi
pause

log_section "Applying Dotfiles"
rm -rf ~/.config/neofetch ~/.zshrc ~/.config/i3
cd ~/.dotfiles || exit 1
stow */
find ~/.config -name "*.sh" -type f -exec chmod +x {} \;
pause

log_section "Setting up Sysmonitor script"
if ! sudo crontab -l 2>/dev/null | grep -q sysmonitor.sh; then
    (sudo crontab -l 2>/dev/null; echo "*/10 * * * * $HOME/.config/sysmonitor.sh") | sudo crontab -
fi
pause

echo "User environment ready. You can reboot now."
