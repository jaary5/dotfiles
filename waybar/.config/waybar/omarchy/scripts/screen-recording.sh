#!/bin/bash
# Omarchy screen recording indicator & toggle

is_recording() {
    pgrep -x gpu-screen-recorder >/dev/null 2>&1 || \
    pgrep -x wf-recorder >/dev/null 2>&1 || \
    pgrep -x wl-screenrec >/dev/null 2>&1
}

stop_recording() {
    pkill -SIGINT -x gpu-screen-recorder 2>/dev/null
    pkill -SIGINT -x wf-recorder 2>/dev/null
    pkill -SIGINT -x wl-screenrec 2>/dev/null
}

if [[ "$1" == "--toggle" || "$1" == "-t" ]]; then
    if is_recording; then
        stop_recording
        sleep 0.5
        notify-send -u normal "Screen Recording" "󰻂    Recording saved"
    else
        notify-send -u low "Screen Recording" "No active recording"
    fi
    pkill -RTMIN+8 waybar 2>/dev/null
    exit 0
fi

if is_recording; then
    echo '{"text": "󰻂", "tooltip": "Screen recording in progress (Click to stop)", "class": "active"}'
else
    echo '{"text": ""}'
fi
