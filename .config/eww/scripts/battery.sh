#!/usr/bin/env bash
# Prints {"capacity":NN,"icon":"X","charging":true/false} for eww defpoll.

BAT="${1:-BAT1}"
BASE="/sys/class/power_supply/$BAT"

if [ ! -d "$BASE" ]; then
    echo '{"capacity":0,"icon":"","charging":false}'
    exit 0
fi

capacity=$(cat "$BASE/capacity" 2>/dev/null || echo 0)
status=$(cat "$BASE/status" 2>/dev/null || echo Unknown)

charging="false"
[ "$status" = "Charging" ] && charging="true"

if [ "$capacity" -ge 95 ]; then
    icon=""
elif [ "$capacity" -ge 70 ]; then
    icon=""
elif [ "$capacity" -ge 30 ]; then
    icon=""
elif [ "$capacity" -ge 15 ]; then
    icon=""
else
    icon=""
fi

if [ "$charging" = "true" ]; then
    icon=" $icon"
fi

printf '{"capacity":%s,"icon":"%s","charging":%s}\n' "$capacity" "$icon" "$charging"
