#!/bin/bash
# WiFi menu for waybar using wofi

CACHE_FILE="/tmp/wifi-list-cache"
CACHE_AGE=10  # seconds

# Kill any existing wofi
pkill -x wofi 2>/dev/null

# Update cache in background
update_cache() {
    nmcli -t -f SSID,SIGNAL,SECURITY device wifi list 2>/dev/null | grep -v '^--' | sort -t: -k2 -nr | uniq > "$CACHE_FILE.tmp"
    mv "$CACHE_FILE.tmp" "$CACHE_FILE"
}

# Check if cache needs refresh
if [ ! -f "$CACHE_FILE" ] || [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -gt $CACHE_AGE ]; then
    update_cache &
fi

# Use cache if exists, otherwise wait for scan
if [ -f "$CACHE_FILE" ]; then
    networks=$(cat "$CACHE_FILE")
else
    networks=$(nmcli -t -f SSID,SIGNAL,SECURITY device wifi list | grep -v '^--' | sort -t: -k2 -nr | uniq)
fi

if [ -z "$networks" ]; then
    notify-send "WiFi" "No networks found"
    exit 1
fi

# Get current connection
current_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2)

# Format for wofi: "SSID (SIGNAL%) [SECURITY]"
menu=""
while IFS=: read -r ssid signal security; do
    [ -z "$ssid" ] && continue
    if [ "$ssid" = "$current_ssid" ]; then
        prefix="* "
    else
        prefix=""
    fi
    if [ -n "$security" ]; then
        menu+="$prefix$ssid ($signal%) [$security]\n"
    else
        menu+="$prefix$ssid ($signal%)\n"
    fi
done <<< "$networks"

# Monitor Hyprland events and close wofi on focus change
(
    socat -u UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - 2>/dev/null | while read -r line; do
        if [[ "$line" == activewindow* ]]; then
            pkill -x wofi 2>/dev/null
            break
        fi
    done
) &
MONITOR_PID=$!

# Show menu
chosen=$(echo -e "$menu" | wofi --dmenu -p "WiFi" --location=top_right -W 300 -H 200 -x -35 -y 25)

# Cleanup monitor
kill $MONITOR_PID 2>/dev/null

[ -z "$chosen" ] && exit 0

# Extract SSID (remove "* " prefix if present)
ssid=$(echo "$chosen" | sed 's/^\* //' | sed 's/ ([0-9]*%).*//')

# Check if already saved
if nmcli -t -f NAME connection show | grep -q "^$ssid$"; then
    nmcli connection up "$ssid"
else
    # New network - need password
    kitty --title "WiFi: $ssid" -e nmcli --ask device wifi connect "$ssid"
fi
