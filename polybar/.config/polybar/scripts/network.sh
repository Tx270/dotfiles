#!/bin/bash

source "$HOME/.cache/wal/colors.sh"

NET_IFACE=$(ip route | awk '/^default/ { print $5 }')
ETH_IFACE=$(ip link | awk -F: '/^[0-9]+: en/{gsub(" ", "", $2); print $2}' | head -n 1)
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
    echo "online" >"$cache_file"
  else
    echo "offline" >"$cache_file"
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

if ip link show "$NET_IFACE" &>/dev/null && iw dev "$NET_IFACE" link | grep -q "Connected"; then
  signal_dbm=$(iw dev "$NET_IFACE" link | grep 'signal:' | awk '{print $2}')
  if [[ "$signal_dbm" =~ ^-?[0-9]+$ ]]; then
    signal=$((100 + signal_dbm))
  else
    signal=0
  fi

  if should_ignore_cache; then
    net_status="checking"
  else
    net_status=$(get_cached_status)
  fi
  if [ "$signal" -gt 70 ]; then
    icon="󰤨"
  elif [ "$signal" -gt 40 ]; then
    icon="󰤥"
  elif [ "$signal" -gt 20 ]; then
    icon="󰤟"
  else icon="󰤯"; fi
  if [ "$net_status" != "online" ] && [ "$net_status" != "checking" ]; then
    icon="󰤭"
  fi

  ssid=$(iw dev "$NET_IFACE" link | grep 'SSID' | cut -d ' ' -f2-)
  if [ -n "$ssid" ]; then
    if [ "${#ssid}" -gt 15 ]; then
      ssid_text=" ${ssid:0:15}…"
    else
      ssid_text=" $ssid"
    fi
  fi
elif ip link show "$ETH_IFACE" | grep -q "state UP"; then
  if should_ignore_cache; then
    net_status="checking"
  else
    net_status=$(get_cached_status)
  fi
  icon=$([ "$net_status" = "online" ] && echo "󰈁" || echo "󰈂")
fi

echo "%{T3}%{F$color9}$icon%{F-}%{T1}$ssid_text"
