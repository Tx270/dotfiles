#!/bin/bash

source ~/.cache/wal/colors.sh

if [[ "$1" == "--play-pause" ]]; then
  [[ -f "$HOME/.cache/player" ]] && playerctl --player="$(cat "$HOME/.cache/player")" play-pause
  exit 0
fi

LAST_PLAYER_FILE="$HOME/.cache/player"
MAX_LEN=70

players=($(playerctl --list-all 2>/dev/null | sort))
[[ ${#players[@]} -eq 0 || ${players[0]} == "No" ]] && echo "" && exit 0

truncate() {
  local str="$1"
  [[ ${#str} -le $MAX_LEN ]] && echo "$str" && return
  echo "${str:0:$(($MAX_LEN - 1))}…"
}

for p in "${players[@]}"; do
  if [[ $(playerctl --player="$p" status 2>/dev/null) == "Playing" ]]; then
    echo "$p" >"$LAST_PLAYER_FILE"
    artist=$(playerctl --player="$p" metadata artist 2>/dev/null)
    title=$(playerctl --player="$p" metadata title 2>/dev/null)
    truncate "%{F$color1}%{T4}%{F-}%{T-} ${title} - ${artist}"
    exit 0
  fi
done

if [[ -f "$LAST_PLAYER_FILE" ]]; then
  last=$(cat "$LAST_PLAYER_FILE")
  if [[ " ${players[*]} " == *" $last "* ]]; then
    if [[ $(playerctl --player="$last" status 2>/dev/null) == "Paused" ]]; then
      artist=$(playerctl --player="$last" metadata artist 2>/dev/null)
      title=$(playerctl --player="$last" metadata title 2>/dev/null)
      truncate "%{F$color1}%{T1}󰏤%{F-}%{T-} ${title} - ${artist}"
      exit 0
    fi
  fi
fi

for p in "${players[@]}"; do
  if [[ $(playerctl --player="$p" status 2>/dev/null) == "Paused" ]]; then
    echo "$p" >"$LAST_PLAYER_FILE"
    artist=$(playerctl --player="$p" metadata artist 2>/dev/null)
    title=$(playerctl --player="$p" metadata title 2>/dev/null)
    truncate "%{F$color1}%{T1}󰏤%{F-}%{T-} ${title} - ${artist}"
    exit 0
  fi
done

exit 0
