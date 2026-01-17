#!/bin/bash
# Custom Bluetooth module for waybar

get_connected_devices() {
    bluetoothctl devices Connected 2>/dev/null | cut -d' ' -f2
}

get_device_info() {
    local mac=$1
    bluetoothctl info "$mac" 2>/dev/null
}

get_battery() {
    local mac=$1
    local battery=""

    # Try bluetoothctl first - format is "Battery Percentage: 0x64 (100)"
    battery=$(bluetoothctl info "$mac" 2>/dev/null | grep "Battery Percentage" | grep -oE '\([0-9]+\)' | tr -d '()')

    if [ -z "$battery" ] || [ "$battery" = "0" ]; then
        # Try upower as fallback
        local upower_path="/org/bluez/hci0/dev_${mac//:/_}"
        local upower_bat=$(upower -i "$upower_path" 2>/dev/null | grep percentage | awk '{print $2}' | tr -d '%')
        if [ -n "$upower_bat" ] && [ "$upower_bat" != "0" ]; then
            battery=$upower_bat
        fi
    fi

    echo "$battery"
}

# Check if Bluetooth is powered
bt_status=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')

if [ "$bt_status" != "yes" ]; then
    echo '{"text": "BT", "tooltip": "Disabled", "class": "disabled"}'
    exit 0
fi

# Get connected devices
devices=$(get_connected_devices)

if [ -z "$devices" ]; then
    echo '{"text": "BT", "tooltip": "No devices", "class": "disconnected"}'
    exit 0
fi

# Process connected devices
tooltip=""
min_battery=100
device_count=0
has_battery=false

for mac in $devices; do
    info=$(get_device_info "$mac")
    name=$(echo "$info" | grep "Alias:" | cut -d' ' -f2-)
    battery=$(get_battery "$mac")

    if [ -n "$tooltip" ]; then
        tooltip+="\n"
    fi
    tooltip+="$name"

    if [ -n "$battery" ] && [ "$battery" -gt 0 ] 2>/dev/null; then
        tooltip+=": $battery%"
        has_battery=true
        if [ "$battery" -lt "$min_battery" ]; then
            min_battery=$battery
        fi
    fi

    ((device_count++))
done

# Determine text and class based on battery level
if [ "$has_battery" = true ] && [ "$min_battery" -lt 20 ]; then
    if [ "$min_battery" -lt 10 ]; then
        class="critical"
    else
        class="warning"
    fi
    text="BT ${min_battery}%"
else
    class="connected"
    text="BT"
fi

# Escape tooltip for JSON
tooltip=$(echo "$tooltip" | sed 's/"/\\"/g')

echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\", \"class\": \"$class\"}"
