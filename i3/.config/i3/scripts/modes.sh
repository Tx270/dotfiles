#!/bin/bash

echo "$1" >"$HOME/.config/mode"

killall -q polybar picom

while pgrep -x polybar >/dev/null; do sleep 0.1; done

"$HOME/.config/polybar/launch.sh" "$1" &
picom --config "$HOME/.config/picom/${1}.conf" &
