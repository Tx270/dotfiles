#!/usr/bin/env bash

CONFIG_DIR="$(dirname "$(realpath "$0")")"

rofi -show drun -config "$CONFIG_DIR/style.rasi"
