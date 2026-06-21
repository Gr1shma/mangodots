#!/usr/bin/env bash
# Prints a network status string. Requires NetworkManager (nmcli).

if ! command -v nmcli >/dev/null 2>&1; then
    echo " no nmcli"
    exit 0
fi

wifi_line=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | grep '^yes')
if [ -n "$wifi_line" ]; then
    ssid=$(echo "$wifi_line" | cut -d: -f2)
    echo "  $ssid"
    exit 0
fi

eth_state=$(nmcli -t -f DEVICE,TYPE,STATE dev 2>/dev/null | awk -F: '$2=="ethernet" && $3=="connected"{print $1; exit}')
if [ -n "$eth_state" ]; then
    echo "  $eth_state"
    exit 0
fi

echo "  Disconnected"
