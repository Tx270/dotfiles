#!/bin/bash

step=10
min=10
max=100

current=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

case "$1" in
-i)
  if [ "$current" -lt "$max" ]; then
    brightnessctl set "${step}%+"
  fi
  ;;
-d)
  if [ "$current" -gt "$min" ]; then
    brightnessctl set "${step}%-"
  else
    brightnessctl set "${min}%"
  fi
  ;;
*)
  echo "Usage: $0 [-i | -d]"
  exit 1
  ;;
esac
