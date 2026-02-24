#!/bin/bash

case "$1" in
showy)
  i3-msg "gaps inner all set 4; gaps outer all set 3"
  ;;
focus)
  i3-msg "gaps inner all set 0; gaps outer all set 0"
  ;;
*)
  echo "Usage: $0 {showy|focus}"
  exit 1
  ;;
esac

echo "$1" >"$HOME/.config/mode"

killall -q polybar picom

while pgrep -x polybar >/dev/null; do sleep 0.1; done

"$HOME/.config/polybar/launch.sh" "$1" &
picom --config "$HOME/.config/picom/${1}.conf" &
