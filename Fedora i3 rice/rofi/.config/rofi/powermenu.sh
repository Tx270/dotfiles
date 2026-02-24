#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x

styles="$HOME/.config/rofi/powermenu.rasi"

# CMDs
uptime="$(uptime -p | sed -e 's/up //g')"
host=$(hostname)

# Options
shutdown='󰐥 Shutdown'
reboot='󰜉 Reboot'
lock='󰌾 Lock'
suspend='󰤄 Suspend'
logout='󰍃 Logout'

fedora=' Fedora'
windows='󰖳 Windows'
debian=' Debian'
uefi=' UEFI Settings'

cancel='󰅖 Cancel'
yes='󰄬 Yes'
no='󰅖 No'

# Rofi CMD
rofi_cmd() {
  rofi -dmenu \
    -p "$host" \
    -mesg "Uptime: $uptime" \
    -theme ${styles}
}

# Confirmation CMD
confirm_cmd() {
  rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 250px;}' \
    -theme-str 'mainbox {children: [ "message", "listview" ];}' \
    -theme-str 'listview {columns: 2; lines: 1;}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
    -theme-str 'textbox {horizontal-align: 0.5;}' \
    -dmenu \
    -p 'Confirmation' \
    -mesg 'Are you Sure?' \
    -theme ${styles}
}

# Ask for confirmation
confirm_exit() {
  echo -e "$yes\n$no" | confirm_cmd
}

# Reboot submenu (instead of confirmation)
reboot_menu() {
  options="$fedora\n$windows\n$debian\n$uefi\n$cancel"
  choice=$(echo -e "$options" | rofi -dmenu -p "Reboot to" -theme ${styles})
  case "$choice" in
  $fedora)
    sudo -n efibootmgr -n 0004 && systemctl reboot
    ;;
  $windows)
    sudo -n efibootmgr -n 0000 && systemctl reboot
    ;;
  $debian)
    sudo -n efibootmgr -n 0002 && systemctl reboot
    ;;
  $uefi)
    systemctl reboot --firmware-setup
    ;;
  $cancel | *)
    exit 0
    ;;
  esac
}

# Pass variables to rofi dmenu (main powermenu)
run_rofi() {
  echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
  selected="$(confirm_exit)"
  if [[ "$selected" == "$yes" ]]; then
    if [[ $1 == '--shutdown' ]]; then
      systemctl poweroff
    elif [[ $1 == '--suspend' ]]; then
      mpc -q pause
      amixer set Master mute
      systemctl suspend
    elif [[ $1 == '--logout' ]]; then
      i3-msg exit
    fi
  else
    exit 0
  fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
$shutdown)
  run_cmd --shutdown
  ;;
$reboot)
  reboot_menu
  ;;
$lock)
  betterlockscreen -l
  ;;
$suspend)
  run_cmd --suspend
  ;;
$logout)
  run_cmd --logout
  ;;
esac
