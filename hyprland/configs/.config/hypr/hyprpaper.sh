#!/usr/bin/env bash

set -e

CONFIG="$HOME/.config/hypr/hyprpaper.conf"
DIR="$HOME/Pictures/Backgrounds"

WALLPAPER=$(find "$DIR" -type f -print0 | shuf -z -n 1 | tr -d '\0')

sed -i "s|^[[:space:]]*path = .*|	path = $WALLPAPER|" "$CONFIG"

hyprpaper &
