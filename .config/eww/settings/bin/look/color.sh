#!/usr/bin/env bash

colorfile="$XDG_CONFIG_HOME/eww/style/color.scss"

if [[ $1 == 'get' ]]
then
    if grep -q 'dark.scss' "$colorfile"
    then
        eww -c $XDG_CONFIG_HOME/eww/settings update look_colorscheme="dark"
        makoctl mode -a "dark_theme"
    else
        eww -c $XDG_CONFIG_HOME/eww/settings update look_colorscheme="light"
    fi
    exit
fi

if grep -q 'dark.scss' "$colorfile"
then
    sed -i 's/dark.scss/light.scss/' $XDG_CONFIG_HOME/eww/style/color.scss
    sed -i 's/dark/light/' $XDG_CONFIG_HOME/rofi/style/color.rasi
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    sed -i 's/dark.conf/light.conf/' $XDG_CONFIG_HOME/hypr/theme/colors.conf
    unlink $XDG_CONFIG_HOME/swaylock/config
    ln -s $XDG_CONFIG_HOME/swaylock/config.light $XDG_CONFIG_HOME/swaylock/config
    makoctl mode -r "dark_theme"
    color="light"
else
    sed -i 's/light.scss/dark.scss/' $XDG_CONFIG_HOME/eww/style/color.scss
    sed -i 's/light/dark/' $XDG_CONFIG_HOME/rofi/style/color.rasi
    sed -i 's/light.conf/dark.conf/' $XDG_CONFIG_HOME/hypr/theme/colors.conf
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    unlink $XDG_CONFIG_HOME/swaylock/config
    ln -s $XDG_CONFIG_HOME/swaylock/config.dark $XDG_CONFIG_HOME/swaylock/config
    makoctl mode -a "dark_theme"
    color="dark"
fi
for EWW in settings shell
do
    eww -c $XDG_CONFIG_HOME/eww/$EWW reload
done
$HOME/.local/bin/eww_settings.sh
killall hyprmon.sh
sleep 0.1
$XDG_CONFIG_HOME/eww/shell/bin/hyprmon.sh monitor & disown
eww -c $XDG_CONFIG_HOME/eww/settings update look_colorscheme="$color"
eww -c $XDG_CONFIG_HOME/eww/shell open desktop_area --screen 0
$XDG_CONFIG_HOME/eww/settings/bin/audio_state.sh
$XDG_CONFIG_HOME/eww/settings/bin/sinks_sources.sh upd sinks & disown
$XDG_CONFIG_HOME/eww/settings/bin/sinks_sources.sh upd sources & disown
# sassc $XDG_CONFIG_HOME/gtklock/style.scss > $XDG_CONFIG_HOME/gtklock/style.css
