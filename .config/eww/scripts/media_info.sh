#!/usr/bin/env bash
# ~/.config/eww/scripts/media_info.sh
# Outputs JSON: {title, artist, album, art, player, status, shuffle, loop}

CACHE_IMG="/tmp/eww_cover.png"
DEFAULT_IMG="$HOME/.config/eww/default_cover.png"

get_mpd_art() {
    song_file=$(mpc current -f "%file%" 2>/dev/null)
    [ -z "$song_file" ] && return
    music_dir="${XDG_MUSIC_DIR:-$HOME/Music}"
    song_dir=$(dirname "$music_dir/$song_file")
    for cover in cover.jpg cover.png folder.jpg folder.png album.jpg album.png; do
        [ -f "$song_dir/$cover" ] && echo "$song_dir/$cover" && return
    done
    find "$song_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \) 2>/dev/null | head -1
}

player="none"
status="Stopped"
title="No Media"
artist="Nothing playing"
album=""
art="$DEFAULT_IMG"
shuffle="Off"
loop="None"
volume=0
pos=0
len=0

# --- Try MPRIS (playerctl) first ---
if playerctl -a status &>/dev/null; then
    player="mpris"
    # Get the actual player name (e.g. firefox, chromium, spotify)
    player_name=$(playerctl -l 2>/dev/null | head -1 | cut -d. -f1 | tr '[:upper:]' '[:lower:]')
    status=$(playerctl status 2>/dev/null || echo "Stopped")
    title=$(playerctl metadata title 2>/dev/null)
    artist=$(playerctl metadata artist 2>/dev/null)
    album=$(playerctl metadata album 2>/dev/null)
    shuffle=$(playerctl shuffle 2>/dev/null || echo "Off")
    loop=$(playerctl loop 2>/dev/null || echo "None")
    pos=$(playerctl position 2>/dev/null | cut -d. -f1 || echo 0)
    len=$(playerctl metadata mpris:length 2>/dev/null)
    [ -n "$len" ] && len=$((len / 1000000)) || len=0
    arturl=$(playerctl metadata mpris:artUrl 2>/dev/null)
    if [ -n "$arturl" ]; then
        if [[ "$arturl" =~ ^https?:// ]]; then
            curl -fsSL -o "$CACHE_IMG" "$arturl" 2>/dev/null && art="$CACHE_IMG"
        elif [[ "$arturl" =~ ^file:// ]]; then
            art="${arturl#file://}"
        elif [ -f "$arturl" ]; then
            art="$arturl"
        fi
    fi
fi

# --- Fall back to MPD (mpc) ---
if [ "$player" = "none" ]; then
    mpd_out=$(mpc status 2>/dev/null)
    if echo "$mpd_out" | grep -qE '\[playing\]|\[paused\]'; then
        player="mpd"
        echo "$mpd_out" | grep -q '\[playing\]' && status="Playing" || status="Paused"
        title=$(mpc current -f "%title%" 2>/dev/null)
        [ -z "$title" ] && title=$(mpc current 2>/dev/null)
        artist=$(mpc current -f "%artist%" 2>/dev/null)
        album=$(mpc current -f "%album%" 2>/dev/null)
        shuffle=$(mpc status | grep -oP 'random: \K\w+' | head -1 | sed 's/on/On/;s/off/Off/')
        loop=$(mpc status | grep -oP 'repeat: \K\w+' | head -1 | sed 's/on/Track/;s/off/None/')
        pos=$(mpc status | grep -oP '\d+:\d+' | head -1 | awk -F: '{print $1*60+$2}')
        len=$(mpc status | grep -oP '\d+:\d+' | tail -1 | awk -F: '{print $1*60+$2}')
        mpd_art=$(get_mpd_art)
        [ -n "$mpd_art" ] && art="$mpd_art"
    fi
fi

# --- Determine display text (title-only for browsers) ---
browser_names="firefox|chromium|brave|chrome|opera|vivaldi|epiphany|falkon"
if [[ "${player_name:-}" =~ ^($browser_names) ]]; then
    display_text="${title:-No Media}"
else
    if [ -n "${artist:-}" ] && [ -n "${title:-}" ]; then
        display_text="${artist} - ${title}"
    else
        display_text="${title:-No Media}"
    fi
fi

jq -nc \
    --arg title "${title:-No Media}" \
    --arg artist "${artist:-Unknown Artist}" \
    --arg album "${album:-}" \
    --arg art "$art" \
    --arg player "$player" \
    --arg player_name "${player_name:-none}" \
    --arg status "$status" \
    --arg shuffle "${shuffle:-Off}" \
    --arg loop "${loop:-None}" \
    --arg display_text "$display_text" \
    --argjson pos "${pos:-0}" \
    --argjson len "${len:-0}" \
    '{title:$title,artist:$artist,album:$album,art:$art,player:$player,player_name:$player_name,status:$status,shuffle:$shuffle,loop:$loop,display_text:$display_text,pos:$pos,len:$len}'
