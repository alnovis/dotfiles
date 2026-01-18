#!/bin/bash
# Notification indicator for waybar

UNREAD_FILE="/tmp/dunst-unread-count"
UNREAD_APPS_FILE="/tmp/dunst-unread-apps"
LAST_DISPLAYED_FILE="/tmp/dunst-last-displayed"
APPEAR_TIME_FILE="/tmp/dunst-appear-time"
NOTIFICATION_TIMEOUT=10  # seconds - match your dunst normal timeout

# Don't show if DND is on
if [ "$(dunstctl is-paused)" = "true" ]; then
    echo '{"text": "", "class": "empty"}'
    exit 0
fi

displayed=$(dunstctl count displayed)
now=$(date +%s)

# Get last displayed count
[ ! -f "$LAST_DISPLAYED_FILE" ] && echo "0" > "$LAST_DISPLAYED_FILE"
last_displayed=$(cat "$LAST_DISPLAYED_FILE")

# Get unread count
[ ! -f "$UNREAD_FILE" ] && echo "0" > "$UNREAD_FILE"
unread=$(cat "$UNREAD_FILE")

# New notification appeared - record time
if [ "$displayed" -gt "$last_displayed" ]; then
    echo "$now" > "$APPEAR_TIME_FILE"
fi

# Notifications disappeared - check if timeout or user-dismissed
if [ "$displayed" -lt "$last_displayed" ] && [ -f "$APPEAR_TIME_FILE" ]; then
    appear_time=$(cat "$APPEAR_TIME_FILE")
    elapsed=$((now - appear_time))

    # Only count as unread if enough time passed (likely timeout, not user click)
    if [ "$elapsed" -ge "$NOTIFICATION_TIMEOUT" ]; then
        dismissed=$((last_displayed - displayed))
        unread=$((unread + dismissed))
        echo "$unread" > "$UNREAD_FILE"

        # Get app names from recent history
        app=$(dunstctl history | jq -r '.data[0][0].appname.data // empty' 2>/dev/null)
        if [ -n "$app" ]; then
            echo "$app" >> "$UNREAD_APPS_FILE"
        fi
    fi
fi

echo "$displayed" > "$LAST_DISPLAYED_FILE"

# Total = unread + currently displayed
total=$((unread + displayed))

if [ "$total" -gt 0 ]; then
    # Build tooltip with app names
    if [ -f "$UNREAD_APPS_FILE" ] && [ -s "$UNREAD_APPS_FILE" ]; then
        apps=$(sort "$UNREAD_APPS_FILE" 2>/dev/null | uniq -c | sort -rn | awk '{print $2 " (" $1 ")"}' | tr '\n' ', ' | sed 's/, $//')
        tooltip="$total unread: $apps"
    else
        tooltip="$total unread"
    fi
    # Escape quotes for JSON
    tooltip=$(echo "$tooltip" | sed 's/"/\\"/g')
    echo "{\"text\": \"[$total]\", \"tooltip\": \"$tooltip\", \"class\": \"unread\"}"
else
    echo '{"text": "", "class": "empty"}'
fi
