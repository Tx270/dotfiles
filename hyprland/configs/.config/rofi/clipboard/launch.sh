#!/usr/bin/env bash

CONFIG_DIR="$(dirname "$(realpath "$0")")"

cliphist list | rofi -dmenu -display-columns 2 -config "$CONFIG_DIR/style.rasi" -p "󰅌" | cliphist decode | wl-copy
