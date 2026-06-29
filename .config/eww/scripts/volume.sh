#!/usr/bin/env bash
# Prints "VOL%" or " muted". Requires pamixer.

if ! command -v pamixer >/dev/null 2>&1; then
    echo "no pamixer"
    exit 0
fi

if pamixer --get-mute 2>/dev/null | grep -q true; then
    echo " muted"
else
    vol=$(pamixer --get-volume 2>/dev/null || echo 0)
    echo " ${vol}%"
fi
