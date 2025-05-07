#!/bin/bash

BAT_PATH="/sys/class/power_supply/BAT0"
CHARGE=$(cat "$BAT_PATH/capacity")
STATUS=$(cat "$BAT_PATH/status")

if [ "$CHARGE" -lt 30 ]; then
        COLOR="#af0303"
    elif [ "$CHARGE" -gt 98 ]; then
        COLOR="#50FA7B"
    else
        COLOR="#cba6f7"
fi

if [[ "$STATUS" == "Charging" ]]; then
    ICON="󰂄"
    COLOR="#cba6f7"
else
    if [ "$CHARGE" -lt 15 ]; then
        ICON="󰂃"
    elif [ "$CHARGE" -lt 20 ]; then
        ICON="󰁺"
    elif [ "$CHARGE" -lt 30 ]; then
        ICON="󰁻"
    elif [ "$CHARGE" -lt 40 ]; then
        ICON="󰁼"
    elif [ "$CHARGE" -lt 50 ]; then
        ICON="󰁽"
    elif [ "$CHARGE" -lt 60 ]; then
        ICON="󰁾"
    elif [ "$CHARGE" -lt 70 ]; then
        ICON="󰁿"
    elif [ "$CHARGE" -lt 80 ]; then
        ICON="󰂀"
    elif [ "$CHARGE" -lt 90 ]; then
        ICON="󰂁"
    elif [ "$CHARGE" -lt 98 ]; then
        ICON="󰂂"
    else
        ICON="󰁹"
    fi
fi

echo "%{F$COLOR}${ICON}%{F-} ${CHARGE}%"
