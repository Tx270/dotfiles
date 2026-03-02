#!/usr/bin/env bash

CONFIG_DIR="$(dirname "$(realpath "$0")")"

selection=$(cliphist list | rofi -dmenu -display-columns 2 -config "$CONFIG_DIR/style.rasi" -p "󰅌")

if [ -n "$selection" ]; then
  echo "$selection" | cliphist decode | wl-copy
fi
