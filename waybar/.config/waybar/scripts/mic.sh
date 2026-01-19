#!/bin/bash
# Microphone mute module for waybar
# Mutes ALL audio input sources (built-in + BT)

get_all_input_sources() {
    # Get all input sources (not monitors)
    pactl list sources short | grep -E "input|bluez_input" | grep -v "monitor" | awk '{print $1}'
}

case "$1" in
    toggle)
        # Determine target state from default source
        if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED; then
            STATE="0"  # unmute
        else
            STATE="1"  # mute
        fi

        # Mute/unmute all input sources
        for id in $(get_all_input_sources); do
            pactl set-source-mute "$id" "$STATE" 2>/dev/null
        done
        ;;
    *)
        if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED; then
            echo '{"text": "MIC", "tooltip": "Microphone: MUTED", "class": "muted"}'
        else
            echo '{"text": "", "tooltip": "Microphone: ON", "class": "on"}'
        fi
        ;;
esac
