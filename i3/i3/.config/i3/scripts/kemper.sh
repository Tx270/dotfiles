#!/bin/bash

export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export PULSE_RUNTIME_PATH="$XDG_RUNTIME_DIR/pulse"
export XAUTHORITY="/home/tx27/.Xauthority"

SINK_NAME="alsa_output.usb-Kemper_Profiler_SPA4RXRBoJE-01.analog-surround-40"

pactl set-default-sink "$SINK_NAME"

for input in $(pactl list short sink-inputs | cut -f1); do
    pactl move-sink-input "$input" "$SINK_NAME"
done

