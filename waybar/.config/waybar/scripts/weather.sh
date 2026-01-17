#!/bin/bash
# Weather script for waybar (JSON output with tooltip)

CONFIG_FILE="$HOME/.config/waybar/scripts/weather.conf"
CACHE_FILE="/tmp/waybar-weather-cache"
CACHE_AGE=1800  # 30 minutes

# Read city from config
CITY=""
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Build URL
if [ -n "$CITY" ]; then
    URL_SHORT="wttr.in/${CITY}?format=%C|%t|%w|%h|%p"
    LOCATION="$CITY"
else
    URL_SHORT="wttr.in/?format=%C|%t|%w|%h|%p"
    LOCATION="Auto"
fi

# Function to get color based on temperature
get_temp_color() {
    local temp_num=$1
    if [ "$temp_num" -le -20 ]; then
        echo "#89b4fa"  # cold blue
    elif [ "$temp_num" -le -5 ]; then
        echo "#74c7ec"  # light blue
    elif [ "$temp_num" -le 5 ]; then
        echo "#cdd6f4"  # neutral
    elif [ "$temp_num" -le 15 ]; then
        echo "#9EBD6E"  # toyota green
    elif [ "$temp_num" -le 25 ]; then
        echo "#f9e2af"  # warm yellow
    else
        echo "#fab387"  # hot orange
    fi
}

# Check cache
if [ -f "$CACHE_FILE" ]; then
    age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE")))
    if [ $age -lt $CACHE_AGE ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Fetch weather
weather=$(curl -s --max-time 15 "$URL_SHORT" 2>/dev/null)

if [ -n "$weather" ] && [[ ! "$weather" =~ "Unknown" ]]; then
    condition=$(echo "$weather" | cut -d'|' -f1 | tr '[:lower:]' '[:upper:]' | xargs)
    temp=$(echo "$weather" | cut -d'|' -f2 | xargs)
    wind=$(echo "$weather" | cut -d'|' -f3 | xargs)
    humidity=$(echo "$weather" | cut -d'|' -f4 | xargs)
    precip=$(echo "$weather" | cut -d'|' -f5 | xargs)

    # Extract numeric temperature
    temp_num=$(echo "$temp" | grep -oE '[-]?[0-9]+' | head -1)
    temp_color=$(get_temp_color "$temp_num")

    # Shorten condition
    case "$condition" in
        *"PARTLY CLOUDY"*) condition="CLOUDY" ;;
        *"OVERCAST"*) condition="CLOUDY" ;;
        *"LIGHT RAIN"*) condition="RAIN" ;;
        *"HEAVY RAIN"*) condition="RAIN" ;;
        *"LIGHT SNOW"*) condition="SNOW" ;;
        *"HEAVY SNOW"*) condition="SNOW" ;;
        *"THUNDERSTORM"*) condition="STORM" ;;
        *"MIST"*|*"FOG"*) condition="FOG" ;;
        *"CLEAR"*) condition="CLEAR" ;;
        *"SUNNY"*) condition="SUNNY" ;;
    esac

    text="$condition $temp"

    # Build tooltip with large font and colored temperature
    tooltip_text="<span size='xx-large'><b>$LOCATION</b></span>\\n"
    tooltip_text+="<span size='x-large'>$condition</span> <span size='x-large' color='$temp_color'><b>$temp</b></span>\\n"
    tooltip_text+="<span size='large'>Wind: $wind</span>\\n"
    tooltip_text+="<span size='large'>Humidity: $humidity</span>\\n"
    tooltip_text+="<span size='large'>Precip: $precip</span>"

    # Output JSON
    output="{\"text\": \"$text\", \"tooltip\": \"$tooltip_text\"}"
    echo "$output" > "$CACHE_FILE"
    echo "$output"
else
    # Return cached or fallback
    if [ -f "$CACHE_FILE" ]; then
        cat "$CACHE_FILE"
    else
        echo '{"text": "WEATHER N/A", "tooltip": "Unable to fetch weather"}'
    fi
fi
