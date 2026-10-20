#!/bin/bash
# Omarchy notification silencing (DND) indicator & toggle

if [[ "$1" == "--toggle" || "$1" == "-t" ]]; then
    if which swaync-client >/dev/null 2>&1; then
        swaync-client -d -t >/dev/null 2>&1
        is_dnd=$(swaync-client -D 2>/dev/null)
        if [[ "$is_dnd" == "true" ]]; then
            notify-send -u low "Notifications" "󰂛    Silenced notifications"
        else
            notify-send -u low "Notifications" "󰂚    Enabled notifications"
        fi
    elif which makoctl >/dev/null 2>&1; then
        makoctl mode -t do-not-disturb >/dev/null 2>&1
        if makoctl mode | grep -q 'do-not-disturb'; then
            notify-send -u low "Notifications" "󰂛    Silenced notifications"
        else
            notify-send -u low "Notifications" "󰂚    Enabled notifications"
        fi
    fi
    pkill -RTMIN+10 waybar 2>/dev/null
    exit 0
fi

# Query current state
is_silenced=false

if which swaync-client >/dev/null 2>&1; then
    [[ "$(swaync-client -D 2>/dev/null)" == "true" ]] && is_silenced=true
elif which makoctl >/dev/null 2>&1; then
    makoctl mode 2>/dev/null | grep -q 'do-not-disturb' && is_silenced=true
fi

if [[ "$is_silenced" == "true" ]]; then
    echo '{"text": "󰂛", "tooltip": "Notifications silenced (Click to enable notifications)", "class": "active"}'
else
    echo '{"text": ""}'
fi
