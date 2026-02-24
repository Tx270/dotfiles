#!/usr/bin/env bash

set -e

CONFIG_DIR="$(dirname "$(realpath "$0")")"

profiles=("󰓅 Performance" "󰾅 Balanced" "󰾆 Power Saver")
names=("performance" "balanced" "power-saver")

current_profile="$(powerprofilesctl get)"

index=0
for i in "${!names[@]}"; do
  if [[ "${names[i]}" == "$current_profile" ]]; then
    index=$i
    break
  fi
done

choice=$(printf "%s\n" "${profiles[@]}" |
  rofi -dmenu -a "$index" -selected-row "$index" \
    -mesg "Choose a power profile" \
    -theme "$CONFIG_DIR/style.rasi")

for i in "${!profiles[@]}"; do
  [[ "$choice" == "${profiles[i]}" ]] && powerprofilesctl set "${names[i]}"
done
