#!/usr/bin/env bash
# Prints whole-number CPU usage percentage, sampled over 0.3s.
read -r _ u1 n1 s1 i1 _ </proc/stat
sleep 0.3
read -r _ u2 n2 s2 i2 _ </proc/stat

prev_idle=$i1
idle=$i2
prev_total=$((u1 + n1 + s1 + i1))
total=$((u2 + n2 + s2 + i2))

diff_idle=$((idle - prev_idle))
diff_total=$((total - prev_total))

if [ "$diff_total" -le 0 ]; then
    echo 0
else
    echo $(((100 * (diff_total - diff_idle)) / diff_total))
fi
