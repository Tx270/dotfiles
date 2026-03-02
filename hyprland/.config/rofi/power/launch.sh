#!/usr/bin/env bash

shutdown='󰤁'
reboot=''
lock=''
suspend='󰤄'
logout='󰍃'

arch='󰣇'
windows='󰖳'
fedora=''
uefi=''

choise=$(echo -e "$lock\n$suspend\n$reboot\n$shutdown" |
  rofi -dmenu -theme "$HOME/.config/rofi/power/style.rasi")

confirm() {
  "$HOME/.config/rofi/launcher.sh" --confirm
}

reboot_menu() {
  options="$arch\n$windows\n$fedora\n$uefi"

  choice=$(echo -e "$options" |
    rofi -dmenu -p "Reboot to" -theme "$HOME/.config/rofi/power/style.rasi")

  case "$choice" in
  "$arch")
    sudo -n efibootmgr -n 0001 && systemctl reboot
    ;;
  "$windows")
    sudo -n efibootmgr -n 0000 && systemctl reboot
    ;;
  "$fedora")
    sudo -n efibootmgr -n 0004 && systemctl reboot
    ;;
  "$uefi")
    systemctl reboot --firmware-setup
    ;;
  esac
}

case "$choise" in
"$lock")
  hyprlock
  ;;
"$suspend")
  if confirm; then
    command -v hyprlock >/dev/null && hyprlock &
    systemctl suspend
  fi
  ;;
"$logout")
  if confirm; then
    hyprctl dispatch exit
  fi
  ;;
"$reboot")
  reboot_menu
  ;;
"$shutdown")
  if confirm; then
    systemctl poweroff
  fi
  ;;
esac
