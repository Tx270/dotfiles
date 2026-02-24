#!/usr/bin/env bash

shutdown='󰤁'
reboot=''
lock=''
suspend='󰤄'
logout='󰍃'

choise=$(echo -e "$lock\n$suspend\n$reboot\n$shutdown" |
  rofi -dmenu -theme "$HOME/.config/rofi/power/style.rasi")

confirm() {
  "$HOME/.config/rofi/launcher.sh" --confirm
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
  if confirm; then
    systemctl reboot
  fi
  ;;
"$shutdown")
  if confirm; then
    systemctl poweroff
  fi
  ;;
esac
