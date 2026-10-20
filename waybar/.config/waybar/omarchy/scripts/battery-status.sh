#!/bin/bash
# Omarchy battery status notification

BAT_DEV=$(upower -e 2>/dev/null | grep BAT | head -1)

if [[ -z "$BAT_DEV" ]]; then
    notify-send -u low "Battery" "No battery detected"
    exit 0
fi

battery_info=$(upower -i "$BAT_DEV" 2>/dev/null)

percentage=$(echo "$battery_info" | awk '/percentage/ { print int($2); exit }')
power_rate=$(echo "$battery_info" | awk '/energy-rate/ { rounded = sprintf("%.1f", $2); sub(/\.0$/, "", rounded); print rounded; exit }')
state=$(echo "$battery_info" | awk '/state/ { print $2; exit }')
time_remaining=$(echo "$battery_info" | awk '/time to/ { print $4 " " $5; exit }')
energy_full=$(echo "$battery_info" | awk '/energy-full:/ { rounded = sprintf("%.0f", $2); print rounded; exit }')

[[ -z "$power_rate" ]] && power_rate="0"
[[ -z "$energy_full" ]] && energy_full="0"

if [[ "$state" == "charging" ]]; then
    [[ -n "$time_remaining" ]] && time_str="  ·  ${time_remaining} to full" || time_str=""
    notify-send -u low "Omarchy Battery" "󰁹    Battery ${percentage}%${time_str}  ·   ${power_rate}W / ${energy_full}Wh"
elif [[ "$state" == "discharging" ]]; then
    [[ -n "$time_remaining" ]] && time_str="  ·  ${time_remaining} left" || time_str=""
    notify-send -u low "Omarchy Battery" "󰁹    Battery ${percentage}%${time_str}  ·   ${power_rate}W / ${energy_full}Wh"
else
    notify-send -u low "Omarchy Battery" "󰁹    Battery ${percentage}%  ·  ${state^}  ·  ${energy_full}Wh"
fi
