#!/bin/bash

export HOME=/home/tx27
export USER=tx27
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:/usr/bin:/bin"

wallpaper=$(find "$HOME/Pictures/Backgrounds/" -type f | shuf -n1)

wal -i "$wallpaper" -q --backend wal -n -e

source "$HOME/.cache/wal/colors.sh"

for i in {0..15}; do
    export color$i
done
export background="$wallpaper"

template="$HOME/.config/wal/templates/lightdm"
output="$HOME/.config/lightdm/mini-greeter.conf"
envsubst < "$template" > "$output"
chmod 640 "$output"

sed -E -i 's/(= )([0-9a-fA-F]{2})([0-9a-fA-F]{6})$/\1\3/' "$HOME/.cache/wal/colors-polybar"

cat >"$HOME/.cache/wal/colors.rasi" <<EOF
* {
  background: ${color0}FF;
  background-alt: ${color0}FF;
  foreground: ${foreground}FF;
  selected: ${color4}FF;
  active: ${color2}FF;
  urgent: ${color5}FF;
}
EOF

cp "$HOME/.cache/wal/dunstrc" "$HOME/.config/dunst/dunstrc"
cp "$HOME/.cache/wal/colors.Xresources" "$HOME/.Xresources"
