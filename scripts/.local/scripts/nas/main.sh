#!/bin/bash

CONFIG="$HOME/.config/nas/nas.conf"
COMMANDS_DIR="$(dirname "$0")/commands"

if [[ ! -f "$CONFIG" ]]; then
  echo "Missing config: $CONFIG" >&2
  exit 1
fi

source "$CONFIG"

if [[ -z "$1" ]]; then
  echo "Usage: nas <command> <subcommand> [args...]"
  echo
  echo "Available commands:"
  for cmd in "$COMMANDS_DIR"/*.sh; do
    basename "${cmd%.sh}"
  done
  exit 1
fi

subcommand="$1"
shift || true

command_file="$COMMANDS_DIR/${subcommand}.sh"

if [[ -f "$command_file" ]]; then
  source "$command_file"

  if [[ -z "$1" ]]; then
    echo "Usage: $0 $subcommand <subcommand> [args...]"
    echo
    echo "Available subcommands for '$subcommand':"
    declare -F | awk '{print $3}' | grep -v "^_" | sort
    exit 1
  fi

  subsubcommand="$1"
  shift || true

  if declare -f "$subsubcommand" >/dev/null; then
    "$subsubcommand" "$@"
  else
    echo "Unknown subcommand: $subsubcommand" >&2
    exit 1
  fi
else
  echo "Unknown command: $subcommand" >&2
  exit 1
fi
