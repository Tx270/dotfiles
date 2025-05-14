#!/bin/bash

# Log file setup
LOG_FILE="$HOME/installation-log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Funkcje pomocnicze
log_section() {
  echo -e "\n\033[1;34m===== $1 =====\033[0m"
}

pause() {
  read -p "Press Enter to continue..."
}

# Sprawdzenie uprawnień
if [ "$(id -u)" != 0 ]; then
  echo "This script must be run with sudo" >&2
  exit 1
fi

# Pobranie rzeczywistego użytkownika
REAL_USER=$(logname)
USER_HOME="/home/$REAL_USER"

# Aktualizacja systemu
log_section "Updating System"
apt update -qq || {
  echo "Error updating repositories"
  exit 1
}
apt upgrade -y -qq || {
  echo "Error upgrading system"
  exit 1
}
pause

# Instalacja podstawowych pakietów
log_section "Installing Essential Packages"
apt install -y -qq curl git stow build-essential libpam0g-dev libxcb-xkb-dev || {
  echo "Error installing essential packages"
  exit 1
}
pause

# Środowisko graficzne
log_section "Installing Desktop Environment"
apt install -y -qq xorg xinit i3 xcompmgr i3lock || {
  echo "Error installing desktop environment"
  exit 1
}
pause

# Komponenty UI
log_section "Installing UI Components"
apt install -y -qq polybar rofi dunst feh maim xclip xsel libnotify-bin || {
  echo "Error installing UI components"
  exit 1
}
pause

# Terminal i edytor
log_section "Installing Terminal and Editor"
apt install -y -qq kitty neovim || {
  echo "Error installing terminal and editor"
  exit 1
}
pause

# System audio
log_section "Installing Audio System"
apt install -y -qq pipewire pipewire-audio-client-libraries libspa-0.2-bluetooth wireplumber pamixer playerctl || {
  echo "Error installing audio system"
  exit 1
}
pause

# Bluetooth
log_section "Installing Bluetooth Support"
apt install -y -qq bluez bluez-tools || {
  echo "Error installing Bluetooth support"
  exit 1
}
systemctl enable bluetooth || {
  echo "Error enabling Bluetooth service"
  exit 1
}
pause

# Narzędzia systemowe
log_section "Installing System Utilities"
apt install -y -qq neofetch htop bc smartmontools network-manager || {
  echo "Error installing system utilities"
  exit 1
}
pause

# Aplikacje
log_section "Installing Applications"
apt install -y -qq firefox-esr thunar || {
  echo "Error installing applications"
  exit 1
}
pause

# Narzędzia developerskie
log_section "Installing Development Tools"
apt install -y -qq cargo pipx zoxide fzf ripgrep fd-find jq imagemagick || {
  echo "Error installing development tools"
  exit 1
}
pause

# Spotify
log_section "Installing Spotify"
curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg || {
  echo "Error adding Spotify key"
  exit 1
}
echo "deb https://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list || {
  echo "Error adding Spotify repository"
  exit 1
}
apt update -qq || {
  echo "Error updating repositories"
  exit 1
}
apt install -y -qq spotify-client || {
  echo "Error installing Spotify"
  exit 1
}
pause

# Menadżer wyświetlania
log_section "Installing Display Manager"
git clone https://github.com/fairyglade/ly /tmp/ly || {
  echo "Error cloning ly repository"
  exit 1
}
cd /tmp/ly || {
  echo "Error changing directory"
  exit 1
}
make || {
  echo "Error building ly"
  exit 1
}
make install || {
  echo "Error installing ly"
  exit 1
}
systemctl enable ly.service || {
  echo "Error enabling ly service"
  exit 1
}
pause

# Konfiguracja użytkownika
log_section "Configuring User Environment"
su - "$REAL_USER" <<'EOF'
# ... (zachowaj oryginalną sekcję konfiguracji użytkownika bez zmian)
EOF
pause

# Finalizacja
log_section "Installation Complete"
echo "Please reboot your system to apply all changes."
