#!/usr/bin/env bash

choice=$(printf "Area\nWindow\nMonitor" | rofi -dmenu -i -p "Hyprshot" -fade 0)

case "$choice" in
  Area)
    hyprshot -m region -o ~/Pictures/Screenshots
    ;;
  Window)
    hyprshot -m window -o ~/Pictures/Screenshots
    ;;
  Monitor)
    hyprshot -m output -o ~/Pictures/Screenshots
    ;;
esac

