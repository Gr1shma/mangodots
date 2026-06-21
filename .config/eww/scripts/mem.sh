#!/usr/bin/env bash
# Prints whole-number memory usage percentage.
awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%d", (t-a)/t*100}' /proc/meminfo
