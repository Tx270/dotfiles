#!/bin/bash

export DISPLAY=:0
export XAUTHORITY="/home/tx27/.Xauthority"
STATE_FILE="/tmp/monitor_state.txt"

dock_connected=$(xrandr | grep "^DP-1-3 connected")

if [[ -z "$dock_connected" ]]; then
    exit 0
fi

if [[ -z "$1" ]]; then
    if [[ -f "$STATE_FILE" ]]; then
        set -- "$(cat "$STATE_FILE")"
    else
      autorandr --change  
    fi
fi

case "$1" in
    1)
        autorandr --change  
        echo "1" > "$STATE_FILE"
        ;;
    2)
        xrandr --output DP-1-3 --primary --auto --output eDP-1 --off
        echo "2" > "$STATE_FILE"
        ;;
    3)
        xrandr --output eDP-1 --primary --auto --output DP-1-3 --off
        echo "3" > "$STATE_FILE"
        ;;
    *)
        exit 1
        ;;
esac
