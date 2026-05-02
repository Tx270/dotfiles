#!/usr/bin/env bash
set -u
set -o pipefail

tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

env EDITOR=nvim VISUAL=nvim kitty --title yazi -e yazi "$@" --cwd-file="$tmp" || true

cwd="$(cat "$tmp" 2>/dev/null || echo "")"

if [ -z "$cwd" ] || [ "$cwd" = "$HOME" ]; then
  exit 0
fi

exec kitty --directory "$cwd"
