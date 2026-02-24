#!/usr/bin/env bash

set -e

CONFIG_DIR="$(dirname "$(realpath "$0")")"

yes=' Confirm'
no='󰜺 Cancel'

choice=$(printf "%s\n%s\n" "$yes" "$no" |
  rofi -dmenu \
    -p "Shutting down" \
    -mesg "Are you sure?" \
    -theme "$CONFIG_DIR/style.rasi")

if [[ "$choice" == "$yes" ]]; then
  exit 0
else
  exit 1
fi
