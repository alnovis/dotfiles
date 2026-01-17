#!/bin/bash
# Microphone mute module for waybar

case "$1" in
    toggle)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        ;;
    *)
        if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED; then
            echo '{"text": "MIC", "tooltip": "Microphone: MUTED", "class": "muted"}'
        else
            echo '{"text": "", "tooltip": "Microphone: ON", "class": "on"}'
        fi
        ;;
esac
