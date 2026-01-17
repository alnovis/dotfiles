#!/bin/bash
# DND (Do Not Disturb) module for waybar

case "$1" in
    toggle)
        dunstctl set-paused toggle
        ;;
    *)
        if [ "$(dunstctl is-paused)" = "true" ]; then
            echo '{"text": "DND", "tooltip": "Do Not Disturb: ON", "class": "on"}'
        else
            echo '{"text": "", "tooltip": "Do Not Disturb: OFF", "class": "off"}'
        fi
        ;;
esac
