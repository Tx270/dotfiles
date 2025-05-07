#!/bin/bash

wifi_interface="wlan0"
ethernet_interface="enp0s3"
test_url="http://nmcheck.gnome.org/check_network_status.txt"
cache_file="/tmp/internet_status"
cache_ttl=60
event_file="/tmp/network_event"

check_internet() {
  curl -s --max-time 2 "$test_url" | grep -q "NetworkManager is online"
}

get_cached_status() {
  if [ -f "$cache_file" ]; then
    last_mod=$(stat -c %Y "$cache_file")
    now=$(date +%s)
    age=$((now - last_mod))
    if [ "$age" -lt "$cache_ttl" ]; then
      cat "$cache_file"
      return
    fi
  fi
  if check_internet; then
    echo "online" > "$cache_file"
  else
    echo "offline" > "$cache_file"
  fi
  cat "$cache_file"
}

should_ignore_cache() {
  if [ -f "$event_file" ]; then
    event_timestamp=$(cat "$event_file")
    current_timestamp=$(date +%s)
    time_diff=$((current_timestamp - event_timestamp))
    if [ "$time_diff" -lt 120 ]; then
      return 0
    fi
  fi
  return 1
}

icon=""
ssid_text=""

if ip link show "$wifi_interface" &>/dev/null && iw dev "$wifi_interface" link | grep -q "Connected"; then
  signal=$(grep 'signal' /proc/net/wireless | awk '{ print int($3 * 100 / 70) }')
  if should_ignore_cache; then
    net_status="checking"
  else
    net_status=$(get_cached_status)
  fi
  if [ "$signal" -gt 70 ]; then icon="󰤨"
  elif [ "$signal" -gt 40 ]; then icon="󰤥"
  elif [ "$signal" -gt 20 ]; then icon="󰤟"
  else icon="󰤯"; fi
  if [ "$net_status" != "online" ] && [ "$net_status" != "checking" ]; then
    icon="󰤭"
  fi

  ssid=$(iw dev "$wifi_interface" link | grep 'SSID' | cut -d ' ' -f2-)
  if [ -n "$ssid" ]; then
    if [ "${#ssid}" -gt 15 ]; then
      ssid_text=" ${ssid:0:15}…"
    else
      ssid_text=" $ssid"
    fi
  fi
elif ip link show "$ethernet_interface" | grep -q "state UP"; then
  if should_ignore_cache; then
    net_status="checking"
  else
    net_status=$(get_cached_status)
  fi
  icon=$([ "$net_status" = "online" ] && echo "󰈁" || echo "󰈂")
fi

echo "%{F#cba6f7}$icon$ssid_text%{F-}"

