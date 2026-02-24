#!/usr/bin/env bash

CONFIG_DIR="$(dirname "$(realpath "$0")")"

choice=$(printf "Area\nWindow\nDesktop" | rofi -dmenu -i -p "Hyprshot" -theme "$CONFIG_DIR/style.rasi" -fade 0)

case "$choice" in
Area)
  hyprshot -m region -o ~/Pictures/Screenshots
  ;;
Window)
  hyprshot -m window -o ~/Pictures/Screenshots
  ;;
Desktop)
  hyprshot -m output -o ~/Pictures/Screenshots
  ;;
esac
