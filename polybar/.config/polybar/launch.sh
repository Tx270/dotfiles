#!/bin/bash

MODE="$(<$HOME/.config/mode)"

if pgrep -x "polybar" >/dev/null; then
  exit 0
fi

if command -v xrandr >/dev/null; then
  while IFS= read -r m; do
    MONITOR="$m" polybar --reload "$MODE" &
  done < <(xrandr --query | grep " connected" | cut -d" " -f1)
else
  polybar --reload "$MODE" &
fi
