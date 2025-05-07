#!/bin/bash

options="  Shutdown\n  Reboot\n󰍃  Logout\n󰤄  Suspend\n󰜉  Lock"

choice=$(echo -e "$options" | rofi -dmenu -p "Power Menu")

case "$choice" in
    "  Shutdown") systemctl poweroff ;;
    "  Reboot") systemctl reboot ;;
    "󰍃  Logout") i3-msg exit ;;
    "󰤄  Suspend") systemctl suspend ;;
    "󰜉  Lock") i3lock ;;
    *) exit 1 ;;
esac

