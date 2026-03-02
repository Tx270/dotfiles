#!/usr/bin/env bash

CONFIG_DIR="$(dirname "$(realpath "$0")")"

choice=$(printf "Capture Area\nCapture Window\nCapture Desktop\nColor Picker" | rofi -dmenu -i -p "Hyprshot" -theme "$CONFIG_DIR/style.rasi" -fade 0)

sleep 0.2 # wait for rofi to close

case "$choice" in
"Capture Area")
  hyprshot -z -m region -o ~/Pictures/Screenshots
  ;;
"Capture Window")
  hyprshot -z -m window -o ~/Pictures/Screenshots
  ;;
"Capture Desktop")
  hyprshot -z -m output -o ~/Pictures/Screenshots
  ;;
"Color Picker")
  color=$(hyprpicker --autocopy --render-inactive) && notify-send "Color $color" "Color copied to clipboard"
  ;;
esac
