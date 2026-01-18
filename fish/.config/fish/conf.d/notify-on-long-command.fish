# Notify when long-running commands finish
set -g __notify_threshold 20

function __notify_on_command_finish --on-event fish_postexec
    set -l last_status $status
    set -l duration (math $CMD_DURATION / 1000)

    # Skip if command was too short
    test $duration -lt $__notify_threshold; and return

    # Skip if terminal is focused
    set -l active_class (hyprctl activewindow -j 2>/dev/null | grep -o '"class":"[^"]*"' | cut -d'"' -f4)
    test "$active_class" = "kitty"; and return

    # Get command name
    set -l cmd (string split ' ' -- $argv[1])[1]

    # Format duration
    if test $duration -ge 60
        set -l mins (math -s0 $duration / 60)
        set -l secs (math -s0 $duration % 60)
        set duration_str "$mins"m" $secs"s
    else
        set duration_str (math -s0 $duration)s
    end

    # Send notification
    if test $last_status -eq 0
        notify-send -a "kitty" "Done" "$cmd ($duration_str)"
    else
        notify-send -a "kitty" -u critical "Failed" "$cmd ($duration_str) exit: $last_status"
    end
end
