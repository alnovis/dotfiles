#!/bin/bash
# Auto-enable DND during screen sharing
# Monitors pipewire for screen capture nodes

LAST_STATE=""

while true; do
    # Check for active screen capture in pipewire
    if pw-dump 2>/dev/null | grep -q '"media.class": "Video/Source"'; then
        if [ "$LAST_STATE" != "sharing" ]; then
            dunstctl set-paused true
            LAST_STATE="sharing"
        fi
    else
        if [ "$LAST_STATE" = "sharing" ]; then
            dunstctl set-paused false
            LAST_STATE="idle"
        fi
    fi
    sleep 2
done
