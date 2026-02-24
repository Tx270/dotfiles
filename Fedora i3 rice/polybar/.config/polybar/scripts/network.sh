#!/bin/bash

source "$HOME/.cache/wal/colors.sh"

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
    prev_status=$(cat "$cache_file" 2>/dev/null)
    if [ "$prev_status" = "online" ]; then ttl=$cache_ttl; else ttl=10; fi
    if [ "$age" -lt "$ttl" ]; then
      echo "$prev_status"
      return
    fi
  fi
  if check_internet; then echo "online" >"$cache_file"; else echo "offline" >"$cache_file"; fi
  cat "$cache_file"
}

should_ignore_cache() {
  if [ -f "$event_file" ]; then
    event_timestamp=$(cat "$event_file")
    current_timestamp=$(date +%s)
    time_diff=$((current_timestamp - event_timestamp))
    if [ "$time_diff" -lt 120 ]; then return 0; fi
  fi
  return 1
}

get_connected_wifi_iface() {
  iw dev | awk '$1=="Interface"{print $2}' | while read -r i; do
    if iw dev "$i" link 2>/dev/null | grep -q "Connected"; then
      echo "$i"
      break
    fi
  done
}

get_eth_iface() {
  for p in /sys/class/net/*; do
    n=$(basename "$p")
    [ "$n" = "lo" ] && continue
    [ -d "/sys/class/net/$n/wireless" ] && continue
    [ -f "/sys/class/net/$n/type" ] || continue
    t=$(cat "/sys/class/net/$n/type" 2>/dev/null)
    [ "$t" -eq 1 ] || continue
    echo "$n"
    break
  done
}

wifi_iface=$(get_connected_wifi_iface)
eth_iface=$(get_eth_iface)

icon=""
ssid_text=""

if [ -n "$wifi_iface" ]; then
  signal_dbm=$(iw dev "$wifi_iface" link | awk '/signal:/ {print $2}')
  if [[ "$signal_dbm" =~ ^-?[0-9]+$ ]]; then signal=$((100 + signal_dbm)); else signal=0; fi
  if should_ignore_cache; then net_status="checking"; else net_status=$(get_cached_status); fi
  if [ "$signal" -gt 70 ]; then
    icon="󰤨"
  elif [ "$signal" -gt 40 ]; then
    icon="󰤥"
  elif [ "$signal" -gt 20 ]; then
    icon="󰤟"
  else
    icon="󰤯"
  fi
  if [ "$net_status" != "online" ] && [ "$net_status" != "checking" ]; then icon="󰤭"; fi
  ssid=$(iw dev "$wifi_iface" link | sed -n 's/.*SSID: \(.*\)$/\1/p')
  if [ -n "$ssid" ]; then
    if [ "${#ssid}" -gt 15 ]; then ssid_text=" ${ssid:0:15}…"; else ssid_text=" $ssid"; fi
  fi

elif [ -n "$eth_iface" ] && [ "$(cat /sys/class/net/$eth_iface/carrier 2>/dev/null)" = "1" ]; then
  if should_ignore_cache; then net_status="checking"; else net_status=$(get_cached_status); fi
  if [ "$net_status" = "online" ]; then icon="󰈁"; else icon="󰈂"; fi

else
  if should_ignore_cache; then net_status="checking"; else net_status=$(get_cached_status); fi
  icon="󰈂"
fi

echo "%{T3}%{F$color9}$icon%{F-}%{T1}$ssid_text"

