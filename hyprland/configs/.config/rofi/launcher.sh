#!/usr/bin/env bash
set -e

CONFIG_DIR="$(dirname "$(realpath "$0")")"
VALID=(apps power confirm battery screenshot clipboard)

arg="${1#--}"

if [[ " ${VALID[*]} " =~ " $arg " ]]; then
  "$CONFIG_DIR/$arg/launch.sh"
else
  echo "Usage: $0 --apps | --power | --confirm | --battery | --screenshot | --clipboard"
  exit 1
fi
