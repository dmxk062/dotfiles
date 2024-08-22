#!/usr/bin/env bash

CITY="graz"
KEY=$(< "$XDG_DATA_HOME/keys/openweather")
eww="eww -c $XDG_CONFIG_HOME/eww/shell"

get_icon(){
    case $1 in
        2*)
            echo "storm"
            ;;
        3*)
            echo "showers-scattered"
            ;;
        5*)
            echo "showers"
            ;;
        600|601|602)
            echo "snow-scattered"
            ;;
        611|612|613)
            echo "hail"
            ;;
        615|616|620|621|622)
            echo "snow-rain"
            ;;
        7*)
            echo "clear"
            ;;
        800)
            echo "clear"
            ;;
        801|802)
            echo "few-clouds"
            ;;
        803|804)
            echo "clouds"
            ;;
    esac
}


get_daytime(){
    hour=$(date +%H)
    if ((hour > 6)) && ((hour < 20)); then
        echo ""
    else
        echo "-night"
    fi
}

get_formatted(){
    response=$(curl -sf "http://api.openweathermap.org/data/2.5/weather?appid=${KEY}&q=${city}&units=metric")
    code=$(jq '.weather.[]|.id' <<< "$response")
    icon_name=$(get_icon "$code")
    echo "$response"|jq -Mc --arg icon "weather-$icon_name$(get_daytime)" '. + {"icon": $icon}'
}

case $1 in
    upd)
        if [[ -z "$2" ]]; then
            city="$CITY"
        else
            city="$2"
        fi

        $eww update weather_load=true
        $eww update weather="$(get_formatted)" 
        $eww update weather_load=false
        $eww update last_weather="$(date +%s)"
        ;;
    change)
        city="$(zenity --entry --text="Choose new City" --entry-text="$2" --title="Weather")"
        $eww update city="$city"
        $eww update weather_load=true
        $eww update weather="$(get_formatted)" 
        $eww update weather_load=false
        $eww update last_weather="$(date +%s)"
        ;;
esac
