#!/bin/bash
# VPN module for waybar

VPN_CONNECTIONS="a.novikov Cosco"

get_active_vpn() {
    nmcli -t -f NAME,TYPE connection show --active | grep ':vpn$' | cut -d: -f1
}

toggle_vpn() {
    pkill -x wofi 2>/dev/null

    local active=$(get_active_vpn)

    # Build menu with active marker
    local menu=""
    for vpn in $VPN_CONNECTIONS; do
        if echo "$active" | grep -q "^$vpn$"; then
            menu+="* $vpn\n"
        else
            menu+="$vpn\n"
        fi
    done

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

    local choice=$(echo -e "$menu" | wofi --dmenu -p "VPN" --location=top_right -W 200 -H 100 -x -35 -y 25)

    kill $MONITOR_PID 2>/dev/null

    [ -z "$choice" ] && return

    # Remove "* " prefix if present
    choice=$(echo "$choice" | sed 's/^\* //')

    # Toggle: disconnect if active, connect if not
    if echo "$active" | grep -q "^$choice$"; then
        nmcli connection down "$choice"
    else
        kitty --title "VPN: $choice" -e nmcli --ask connection up "$choice"
    fi
}

case "$1" in
    toggle)
        toggle_vpn
        ;;
    *)
        active=$(get_active_vpn)
        if [ -n "$active" ]; then
            echo "{\"text\": \"VPN\", \"tooltip\": \"Connected: $active\", \"class\": \"connected\"}"
        else
            echo "{\"text\": \"VPN\", \"tooltip\": \"Click to connect\", \"class\": \"disconnected\"}"
        fi
        ;;
esac
