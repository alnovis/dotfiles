#!/bin/bash
# Power profile switcher for waybar

get_profile() {
    powerprofilesctl get
}

get_icon() {
    local profile=$1
    case "$profile" in
        "performance") echo "PERF" ;;
        "balanced")    echo "BAL" ;;
        "power-saver") echo "SAVE" ;;
        *)             echo "PWR" ;;
    esac
}

get_color() {
    local profile=$1
    case "$profile" in
        "performance") echo "#fab387" ;;  # orange - high power
        "balanced")    echo "#9EBD6E" ;;  # toyota green - normal
        "power-saver") echo "#74c7ec" ;;  # blue - eco
        *)             echo "#d4d4c8" ;;
    esac
}

cycle_profile() {
    local current=$(get_profile)
    case "$current" in
        "performance") powerprofilesctl set balanced ;;
        "balanced")    powerprofilesctl set power-saver ;;
        "power-saver") powerprofilesctl set performance ;;
    esac
}

# Handle click
if [ "$1" = "cycle" ]; then
    cycle_profile
    exit 0
fi

# Output for waybar
profile=$(get_profile)
icon=$(get_icon "$profile")
color=$(get_color "$profile")

tooltip="Profile: $profile"

echo "{\"text\": \"<span color='$color'>$icon</span>\", \"tooltip\": \"$tooltip\", \"class\": \"$profile\"}"
