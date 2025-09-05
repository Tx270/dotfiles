#!/bin/bash

LOG_FILE="/home/$(logname)/installation-log-$(date +'%Y%m%d-%H%M%S')"
exec > >(tee -a "$LOG_FILE") 2>&1
set -eo pipefail

PAUSE=0
[[ "$1" == "--pause" ]] && PAUSE=1

log_section() {
  echo -e "\n\033[1;34m===== $1 =====\033[0m"
}
pause() {
  if [[ "$PAUSE" -eq 1 ]]; then
    read -p "Press Enter to continue..."
  fi
}

if [ "$(id -u)" = 0 ]; then
  echo "Don't run this script with sudo." >&2
  exit 1
fi

log_section "Setting up Fonts"
if [ ! -d "$HOME/.local/share/fonts/Meslo" ]; then
  mkdir -p "$HOME/.local/share/fonts/" && cd /tmp || exit 1
  echo "eeeee"
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip -O Meslo.zip || exit 2
  echo "eeeee"
  unzip -oq Meslo.zip -d Meslo || exit 3
  rm Meslo.zip
  mv Meslo "$HOME/.local/share/fonts" || exit 4
  fc-cache -f >/dev/null
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

log_section "Installing Pipx Apps"
if ! command -v wal &>/dev/null; then
  python3 -m pipx ensurepath
  pipx install pywal16
  pipx install trash-cli
fi
pause

log_section "Instaling LazyVim"
[ ! -f $HOME/.config/nvim/lazy-lock.json ] && git clone https://github.com/LazyVim/starter $HOME/.config/nvim
pause

log_section "Compiling Cargo and Ruby Tools"
export PATH="$HOME/.cargo/bin:$PATH"
[ ! -f $HOME/.cargo/bin/xcolor ] && cargo install xcolor
[ ! -f $HOME/.cargo/bin/bluetui ] && cargo install bluetui
[ ! -f $HOME/.cargo/bin/impala ] && cargo install impala
if ! command -v colorls &>/dev/null; then
  gem install colorls --user-install
fi
pause

log_section "Applying Dotfiles"
rm -rf $HOME/.config/neofetch $HOME/.zshrc $HOME/.config/i3
cd $HOME/.dotfiles || exit 1
stow */
find $HOME/.config -name "*.sh" -type f -exec chmod +x {} \;
echo "exec i3" >$HOME/.xinitrc
chmod o+x "$HOME"
pause

log_section "Creating Home Directories"
cat >~/.config/user-dirs.dirs <<EOF
XDG_DESKTOP_DIR="\$HOME/Other/Desktop"
XDG_DOWNLOAD_DIR="\$HOME/Downloads"
XDG_TEMPLATES_DIR="\$HOME/Other/Templates"
XDG_DOCUMENTS_DIR="\$HOME/Documents"
XDG_MUSIC_DIR="\$HOME/Audio"
XDG_PICTURES_DIR="\$HOME/Pictures"
XDG_VIDEOS_DIR="\$HOME/Videos"
XDG_PUBLICSHARE_DIR="\$HOME/Other/Public"
EOF
source ~/.config/user-dirs.dirs
for dir in \
  "$XDG_DESKTOP_DIR" "$XDG_DOWNLOAD_DIR" "$XDG_TEMPLATES_DIR" \
  "$XDG_DOCUMENTS_DIR" "$XDG_MUSIC_DIR" "$XDG_PICTURES_DIR" \
  "$XDG_VIDEOS_DIR" "$XDG_PUBLICSHARE_DIR"; do
  mkdir -p "$dir"
done
ln -s /run/media/$(whoami) /home/$(whoami)/Other/Discs
pause

log_section "Setting up Crontab"
(
  c=$(crontab -l 2>/dev/null)
  echo "$c" | grep -vF "trash-empty 30"
  echo "@daily $(which trash-empty) 30"
) | crontab -
(
  s=$(sudo crontab -l 2>/dev/null)
  echo "$s" | grep -vF "sysmonitor.sh"
  echo "*/10 * * * * /bin/bash \$HOME/.config/sysmonitor.sh"
) | sudo crontab -
pause

log_section "All done!"
echo "User environment ready. You can reboot now."
