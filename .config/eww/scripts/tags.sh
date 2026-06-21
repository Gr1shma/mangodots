#!/usr/bin/env bash
# Streams mango tag state as JSON, one line per update, for eww deflisten.
# Uses the real mmsg CLI: `mmsg get tags <monitor>` / `mmsg watch tags <monitor>`
#
# Output shape (normalized for the widget):
# {"tags":[{"id":1,"active":true,"urgent":false,"clients":1}, ...]}

MONITOR="${1:-eDP-1}"

normalize() {
    # Reshape mmsg's {"monitor":...,"tags":[{"index":N,"is_active":B,"is_urgent":B,"client_count":N}],"active_tags":[...]}
    # into {"tags":[{"id":N,"active":B,"urgent":B,"clients":N}]}
    jq -c '{tags: [.tags[] | select(.is_active or .client_count > 0) | {id: .index, active: .is_active, urgent: .is_urgent, clients: .client_count}]}'
}

# Initial state immediately so the widget isn't blank on bar start.
mmsg get tags "$MONITOR" 2>/dev/null | normalize

# Then stream updates whenever tags change.
mmsg watch tags "$MONITOR" 2>/dev/null | while read -r line; do
    echo "$line" | normalize
done
