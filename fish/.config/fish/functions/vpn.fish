function vpn --description 'VPN connection manager'
    set -l vpn_list "a.novikov" "Cosco"
    set -l openvpn "a.novikov"
    set -l cisco "Cosco"

    switch $argv[1]
        case up
            if test -n "$argv[2]"
                kitty --title "VPN: $argv[2]" -e nmcli --ask connection up "$argv[2]"
            else
                for v in $vpn_list
                    echo "Connecting $v..."
                    kitty --title "VPN: $v" -e nmcli --ask connection up "$v" &
                end
            end

        case down
            if test -n "$argv[2]"
                nmcli connection down "$argv[2]"
            else
                for v in $vpn_list
                    nmcli connection down "$v" 2>/dev/null
                end
                echo "All VPNs disconnected"
            end

        case o ovpn openvpn
            switch $argv[2]
                case up
                    kitty --title "VPN: $openvpn" -e nmcli --ask connection up "$openvpn"
                case down
                    nmcli connection down "$openvpn"
                case '*'
                    echo "Usage: vpn o <up|down>"
            end

        case c cisco
            switch $argv[2]
                case up
                    kitty --title "VPN: $cisco" -e nmcli --ask connection up "$cisco"
                case down
                    nmcli connection down "$cisco"
                case '*'
                    echo "Usage: vpn c <up|down>"
            end

        case status
            echo "VPN Status:"
            set -l active (nmcli -t -f NAME,TYPE connection show --active | grep ':vpn$' | cut -d: -f1)
            if test -n "$active"
                for name in $active
                    echo "  ✓ $name"
                end
            else
                echo "  No active VPN"
            end

        case '*'
            echo "Usage: vpn <command> [connection]"
            echo ""
            echo "Commands:"
            echo "  up [name]     Connect (all if no name)"
            echo "  down [name]   Disconnect (all if no name)"
            echo "  o up|down     OpenVPN ($openvpn)"
            echo "  c up|down     Cisco ($cisco)"
            echo "  status        Show active VPNs"
    end
end
