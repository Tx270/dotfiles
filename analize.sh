#!/bin/bash

NET_IFACE=$(ip route | awk '/^default/ { print $5 }')

ETH_IFACE=$(ip link | awk -F: '/^[0-9]+: [e][n].*: / { gsub(" ", "", $2); print $2 }' | head -n 1)

# Run 'xinput list' to find your trackpads id
INPUT_ID=9
NET_IFACE=$NET_IFACE
ETH_IFACE=$ETH_IFACE
