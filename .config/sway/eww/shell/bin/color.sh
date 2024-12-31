#!/usr/bin/env bash
cd || exit # so the pwd isnt fucked up

colorscheme="$(gsettings get org.gnome.desktop.interface color-scheme)"

if [[ "$1" == "get" ]]; then
    if [[ "$colorscheme" == *light* ]]; then
        echo "true"
    else
        echo "false"
    fi
    exit
fi

if [[ "$colorscheme" == *dark* ]]; then
    sed -i 's/dark.scss/light.scss/' "$XDG_CONFIG_HOME"/sway/eww/style/color.scss
    sed -i 's/dark/light/' "$XDG_CONFIG_HOME"/rofi/style/color.rasi
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    unlink "$XDG_CONFIG_HOME"/swaylock/config
    ln -s "$XDG_CONFIG_HOME"/swaylock/config.light "$XDG_CONFIG_HOME"/swaylock/config
    unlink "$XDG_CONFIG_HOME"/sway/color
    ln -s "$XDG_CONFIG_HOME"/sway/light "$XDG_CONFIG_HOME"/sway/color
    unlink "$XDG_CONFIG_HOME"/gtk-4.0/gtk.css
    ln -s "$XDG_CONFIG_HOME"/gtkcss/4.0/gtk-light.css "$XDG_CONFIG_HOME"/gtk-4.0/gtk.css
else
    sed -i 's/light.scss/dark.scss/' "$XDG_CONFIG_HOME"/sway/eww/style/color.scss
    sed -i 's/light/dark/' "$XDG_CONFIG_HOME"/rofi/style/color.rasi
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    unlink "$XDG_CONFIG_HOME"/swaylock/config
    ln -s "$XDG_CONFIG_HOME"/swaylock/config.dark "$XDG_CONFIG_HOME"/swaylock/config
    unlink "$XDG_CONFIG_HOME"/sway/color
    ln -s "$XDG_CONFIG_HOME"/sway/dark "$XDG_CONFIG_HOME"/sway/color
    unlink "$XDG_CONFIG_HOME"/gtk-4.0/gtk.css
    ln -s "$XDG_CONFIG_HOME"/gtkcss/4.0/gtk-dark.css "$XDG_CONFIG_HOME"/gtk-4.0/gtk.css
fi

eww -c "$XDG_CONFIG_HOME/sway/eww/shell/" reload
sleep 0.5
sassc "$XDG_CONFIG_HOME"/swaync/style.scss > "$XDG_CONFIG_HOME"/swaync/style.css
sassc "$XDG_CONFIG_HOME"/wofi/style.scss > "$XDG_CONFIG_HOME"/wofi/style.css
sleep 0.2
swaync-client -rs
swaymsg reload
