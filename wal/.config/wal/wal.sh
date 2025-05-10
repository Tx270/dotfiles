#!/bin/bash

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:/usr/bin:/bin"

cd ~/.config/backgrounds
wallpaper=$(find -type f | shuf -n 1)

wal -i "$wallpaper" -q --backend "wal"

cp ~/.cache/wal/dunstrc ~/.config/dunst/dunstrc
pkill dunst && dunst &

cp ~/.cache/wal/colors.Xresources ~/.Xresources
xrdb -merge ~/.Xresources

/home/tx27/.config/polybar/launch.sh

betterlockscreen -u "$wallpaper" --fx none


source "/home/tx27/.cache/wal/colors.sh"

bg="${color0}FF"
bg_alt="${color0}FF"
fg="${foreground}FF"
selected="${color4}FF"
active="${color2}FF"
urgent="${color5}FF"

cat > "/home/tx27/.cache/wal/colors.rasi" <<EOF
* {
  background: ${bg};
  background-alt: ${bg_alt};
  foreground: ${fg};
  selected: ${selected};
  active: ${active};
  urgent: ${urgent};
}
EOF

if [[ ! " $@ " =~ " -q " ]]; then
    notify-send "Changed wallpaper" "Random walpaper was choosen and color palette was modified" -u normal
fi
