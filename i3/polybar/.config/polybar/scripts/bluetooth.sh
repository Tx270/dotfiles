#!/bin/bash

source ~/.cache/wal/colors.sh

ICON_ON="%{T5}%{F$color9}󰂯%{F-}%{T-}"
ICON_OFF="%{T4}%{F$color9}󰂲%{F-}%{T-}"

bt_powered=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')
if [[ "$bt_powered" == "yes" ]]; then
  connected_line=$(bluetoothctl devices Connected | head -n 1)

  if [[ -n "$connected_line" ]]; then
    device_name=$(echo "$connected_line" | cut -d ' ' -f3-)
    echo "$ICON_ON $device_name"
  else
    echo "$ICON_ON"
  fi
else
  echo "$ICON_OFF"
fi
