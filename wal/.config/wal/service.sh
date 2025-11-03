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

cat > "$HOME/.config/fzf/fzf.conf" <<EOF
--border sharp
--list-border sharp
--input-border sharp
--header-border sharp
--preview-border sharp
--height 40%
--layout reverse
--scroll-off=200
--padding 1,2
--border-label 'fzf'
--input-label 'Input'
--header-label 'File Type'
--preview '/home/tx27/.config/fzf/fzf-preview.sh {}'
--bind 'result:transform-list-label:
if [[ -z $FZF_QUERY ]]; then
echo " $FZF_MATCH_COUNT items ";
else echo " $FZF_MATCH_COUNT matches for [$FZF_QUERY] ";
fi'
--bind 'focus:transform-preview-label:[[ -n {} ]] && printf " Previewing [%s] " {}'
--bind 'focus:+transform-header:file --brief {} || echo "No file selected"'
--bind 'ctrl-r:change-list-label(Reloading the list)+reload(sleep 2; git ls-files)'
EOF

cp "$HOME/.cache/wal/dunstrc" "$HOME/.config/dunst/dunstrc"
cp "$HOME/.cache/wal/colors.Xresources" "$HOME/.Xresources"
