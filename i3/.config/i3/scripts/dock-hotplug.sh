#!/bin/bash

udevadm trigger --subsystem-match=usb --action=add

pkill -x polybar

while pgrep -x polybar >/dev/null; do
    sleep 0.2
done

i3-msg restart
