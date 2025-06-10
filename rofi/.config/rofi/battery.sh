#!/usr/bin/env bash

styles="$HOME/.config/rofi/powermenu.rasi"
host=$(hostname)

current_profile="$(powerprofilesctl get)"

battery_status=$(acpi -b | grep "Battery 0" | awk -F': ' '{print $2}')
if [[ -z "$battery_status" ]]; then
  battery_status="Brak danych o baterii"
fi

options=("󰾆 Power Saver" "󰾅 Balanced" "󰓅 Performance")
profiles=("power-saver" "balanced" "performance")

menu=""
selected_row=0
for i in "${!options[@]}"; do
  if [[ "${profiles[i]}" == "$current_profile" ]]; then
    menu+="${options[i]}  <-\n"
    selected_row=$i
  else
    menu+="${options[i]}\n"
  fi
done

rofi_cmd() {
  rofi -dmenu \
    -p "$host" \
    -mesg "$battery_status" \
    -theme ${styles} \
    -selected-row $selected_row
}

run_rofi() {
  echo -e "$menu" | rofi_cmd
}

run_cmd() {
  selected="${1// <-/}"
  for i in "${!options[@]}"; do
    if [[ "${options[i]}" == "$selected" ]]; then
      powerprofilesctl set "${profiles[i]}"
      break
    fi
  done
}

chosen="$(run_rofi)"
run_cmd "$chosen"
