#!/usr/bin/env bash
DEVICE="${1:-$(ls /sys/class/backlight 2>/dev/null | head -n 1)}"
BASE="/sys/class/backlight/$DEVICE"

if [ -z "$DEVICE" ] || [ ! -d "$BASE" ]; then
    echo "󰃞  0%"
    exit 0
fi

cur=$(cat "$BASE/brightness" 2>/dev/null || echo 0)
max=$(cat "$BASE/max_brightness" 2>/dev/null || echo 1)
pct=$((cur * 100 / max))

if [ "$pct" -ge 70 ]; then
    icon="󰃠"
elif [ "$pct" -ge 30 ]; then
    icon="󰃟"
else
    icon="󰃞"
fi

echo "$icon  ${pct}%"
