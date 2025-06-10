#!/bin/bash

LOG_FILE="$HOME/installation-log-$(date +'%Y%m%d-%H%M%S')"
exec > >(tee -a "$LOG_FILE") 2>&1
set -euo pipefail

PAUSE=0
[[ "$1" == "--pause" ]] && PAUSE=1

log_section() {
  echo -e "\n\033[1;34m===== $1 =====\033[0m"
}
pause() {
  [[ "$PAUSE" -eq 0 ]] && read -p "Press Enter to continue..."
}

if [ "$(id -u)" != 0 ]; then
  echo "This script must be run with sudo" >&2
  exit 1
fi

REAL_USER=$(logname)

log_section "Updating System"
dnf update -y -q
dnf copr enable lihaohong/yazi -y
dnf copr enable elxreno/preload -y
pause

log_section "Installing Essential Packages"
dnf install -q -y \
  @development-tools gcc gcc-c++ git make meson automake autoconf pkgconf pkg-config \
  python3-pip python3-virtualenv curl wget stow iwd \
  xset xrandr xdpyinfo xdotool \
  libX11-devel libX11-xcb libxcb-devel libXinerama libXrandr \
  libXcursor-devel xorg-x11-proto-devel \
  xcb-util-devel xcb-util-image-devel xcb-util-renderutil-devel \
  xcb-util-keysyms-devel xcb-util-xrm-devel \
  libxkbcommon-devel libxkbcommon-x11-devel \
  cairo-devel fontconfig ImageMagick giflib-devel \
  libjpeg-turbo-devel libEGL-devel libGL-devel libepoxy-devel pixman-devel \
  libconfig-devel libev-devel dbus-devel pam-devel \
  pcre-devel pcre2-devel uthash-devel \
  taglib-devel fftw-devel opus-devel opusfile-devel libvorbis-devel libogg-devel \
  chafa-devel libatomic glib2-devel \
  libevdev-devel yaml-cpp-devel boost-devel \
  wmctrl cronie
pause

log_section "Installing Desktop Environment"
dnf install -q -y @base-x i3 picom
pause

log_section "Installing UI Components"
dnf install -q -y polybar rofi dunst feh maim xclip xsel libnotify
pause

log_section "Installing Audio System and Bluetooth"
dnf install -q -y pipewire wireplumber pamixer playerctl bluez bluez-tools
systemctl enable bluetooth
pause

log_section "Installing System Utilities and Shell"
dnf install -q -y kitty neovim htop bc tree smartmontools iwd systemd-resolved zsh zip tar bat atuin python3-pip pipx ruby ruby-devel sudo dnf install udiskie udisks2 preload cargo yazi node npm brightnessctl power-profiles-daemon acpi aerc rsync
pause

log_section "Installing Applications"
dnf install -q -y firefox
pause

log_section "Building and Installing Neofetch"
if [ ! -f /usr/bin/neofetch ]; then
  git clone https://github.com/dylanaraps/neofetch.git /tmp/neofetch
  (
    cd /tmp/neofetch
    make install
  )
fi
pause

log_section "Building and Installing ly Display Manager"
if [ ! -f /usr/bin/ly ]; then
  curl -fsSL https://ziglang.org/download/0.14.0/zig-linux-x86_64-0.14.0.tar.xz -o /tmp/zig.tar.xz
  mkdir -p /tmp/zigdir && tar -xf /tmp/zig.tar.xz -C /tmp/zigdir
  export PATH="/tmp/zigdir/zig-linux-x86_64-0.14.0:$PATH"
  (
    git clone https://github.com/cylgom/ly.git /tmp/ly
    cd /tmp/ly
    zig build && zig build installexe
  )
  systemctl enable ly.service
  rm -rf /tmp/zig.tar.xz /tmp/zigdir /tmp/ly
fi
pause

log_section "Building and Installing i3lock-color"
if [ ! -f /usr/local/bin/i3lock-color ]; then
  git clone https://github.com/Raymo111/i3lock-color.git /tmp/i3lock-color
  (
    cd /tmp/i3lock-color
    ./install-i3lock-color.sh
  )
  rm -rf /tmp/i3lock-color
fi
pause

log_section "Building and Installing ibinput-gestures"
if [ ! -f /sbin/libinput-gestures ]; then
  gpasswd -a $REAL_USER input
  git clone https://github.com/bulletmark/libinput-gestures.git /tmp/gestures
  (
    cd /tmp/gestures
    ./libinput-gestures-setup install
  )
  rm -rf /tmp/gestures
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

log_section "Building and Installing Kew"
if [ ! -f /usr/local/bin/kew ]; then
  git clone https://github.com/ravachol/kew.git /tmp/kew
  (
    cd /tmp/kew
    make -j4
    make install
  )
  rm -rf /tmp/kew
fi
pause

log_section "Building and Installing Udev with Caps2esc"
if [ ! -f /usr/local/bin/udevmon ]; then
  git clone https://gitlab.com/interception/linux/tools.git /tmp/interception-tools
  (
    cd /tmp/interception-tools
    mkdir build
    cd build
    cmake ..
    make
    sudo make install
  )
  rm -rf /tmp/kew
fi
if [ ! -f /usr/local/bin/caps2esc ]; then
  git clone https://gitlab.com/interception/linux/plugins/caps2esc.git /tmp/caps2esc
  (
    cd /tmp/caps2esc
    mkdir build
    cd build
    cmake ..
    make
    sudo make install
  )
  rm -rf /tmp/caps2esc
fi
pause

log_section "Setting up udevmon service"
sudo mkdir -p /etc/interception
sudo tee /etc/interception/udevmon.yaml >/dev/null <<EOF
- JOB: "intercept -g \$DEVNODE | caps2esc | uinput -d \$DEVNODE"
  DEVICE:
    EVENTS:
      EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
EOF
sudo tee /etc/systemd/system/udevmon.service >/dev/null <<EOF
[Unit]
Description=Interception udevmon daemon
After=multi-user.target
[Service]
ExecStart=/usr/local/bin/udevmon -c /etc/interception/udevmon.yaml
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
UDEV_RULE="/etc/udev/rules.d/99-interception.rules"
RULE_CONTENT='KERNEL=="event*", GROUP="input", MODE="660"'
if ! grep -Fxq "$RULE_CONTENT" "$UDEV_RULE" 2>/dev/null; then
  echo "$RULE_CONTENT" | sudo tee "$UDEV_RULE" >/dev/null
  sudo udevadm control --reload-rules
fi
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now udevmon.service
pause

log_section "Swaping keys"
PC_FILE="/usr/share/X11/xkb/symbols/pc"
BACKUP_FILE="/usr/share/X11/xkb/symbols/pc.bak"
MARKER="# swapped Alt_L and Super_L by install.sh"
if [ ! -f "$BACKUP_FILE" ]; then
  sudo cp "$PC_FILE" "$BACKUP_FILE"
fi
if ! grep -qF "$MARKER" "$PC_FILE"; then
  sudo sed -Ei \
    -e 's/^(.*key\s+<LALT>\s*\{\s*\[)[^]]+(\s*\]\s*\};)/\1 Super_L\2/' \
    -e 's/^(.*key\s+<LWIN>\s*\{\s*\[)[^]]+(\s*\]\s*\};)/\1 Alt_L\2/' \
    "$PC_FILE"
  echo "$MARKER" | sudo tee -a "$PC_FILE" >/dev/null
fi
sudo rm -rf /var/lib/xkb/*
pause

log_section "Replacing NetworkManager with iwd"
rpm -q NetworkManager && {
  systemctl disable --now NetworkManager 2>/dev/null || true
  dnf remove -y -q NetworkManager
}
systemctl enable --now iwd
systemctl enable --now systemd-resolved
mkdir -p /etc/iwd
grep -q EnableNetworkConfiguration /etc/iwd/main.conf 2>/dev/null || cat <<EOF >/etc/iwd/main.conf
[General]
EnableNetworkConfiguration=true
[Network]
NameResolvingService=systemd
EOF
[ "$(readlink /etc/resolv.conf)" != "/run/systemd/resolve/stub-resolv.conf" ] &&
  ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

log_section "All done!"
echo "System installation finished. You can reboot now and then run installUser.sh."
