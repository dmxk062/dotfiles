#!/usr/bin/env bash

colorfile="$XDG_CONFIG_HOME/eww/style/color.scss"

if [[ $1 == 'get' ]]
then
    if grep -q 'dark.css' "$colorfile"
    then
        eww -c $XDG_CONFIG_HOME/eww/settings update colorscheme="dark"
    else
        eww -c $XDG_CONFIG_HOME/eww/settings update colorscheme="light"
    fi
    exit
fi

if grep -q 'dark.scss' "$colorfile"
then
    sed -i 's/dark.scss/light.scss/' $XDG_CONFIG_HOME/eww/style/color.scss
    sed -i 's/dark/light/' $XDG_CONFIG_HOME/rofi/style/color.rasi
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    color="light"
else
    sed -i 's/light.scss/dark.scss/' $XDG_CONFIG_HOME/eww/style/color.scss
    sed -i 's/light/dark/' $XDG_CONFIG_HOME/rofi/style/color.rasi
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    color="dark"
fi
for EWW in settings shell
do
    eww -c $XDG_CONFIG_HOME/eww/$EWW reload
done
$HOME/.local/bin/eww_settings.sh
sleep 0.1
eww -c $XDG_CONFIG_HOME/eww/settings update colorscheme="$color"
eww -c $XDG_CONFIG_HOME/eww/shell open rightclick_area --screen 0
$XDG_CONFIG_HOME/eww/settings/bin/audio_state.sh
$XDG_CONFIG_HOME/eww/settings/bin/sinks_sources.sh upd sinks & disown
$XDG_CONFIG_HOME/eww/settings/bin/sinks_sources.sh upd sources & disown
sassc $XDG_CONFIG_HOME/gtklock/style.scss > $XDG_CONFIG_HOME/gtklock/style.css
