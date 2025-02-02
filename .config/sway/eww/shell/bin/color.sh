#!/usr/bin/env bash
cd || exit # so the pwd isnt fucked up

if [[ "$(gsettings get org.gnome.desktop.interface color-scheme)" == *dark* ]]; then
    old=dark
    target=light
else
    old=light
    target=dark
fi

if [[ "$1" == "get" ]]; then
    echo "$old"
    exit
fi

function relink_file {
    unlink "$1/$3"
    ln -s "$1/$2" "$1/$3"
}

function recompile_scss {
    sassc "$1/style.scss" >"$1/style.css"
}

gsettings set org.gnome.desktop.interface color-scheme "prefer-$target" &
sed -i "s/$old.scss/$target.scss/" "$XDG_CONFIG_HOME/sway/eww/style/color.scss" &
sed -i "s/$old/$target/" "$XDG_CONFIG_HOME/rofi/style/color.rasi" &
relink_file "$XDG_CONFIG_HOME/swaylock" config.$target config &
relink_file "$XDG_CONFIG_HOME/sway" $target color &
(
    unlink "$XDG_CONFIG_HOME/gtk-4.0/gtk.css"
    ln -s "$XDG_CONFIG_HOME/gtkcss/4.0/gtk-${target}.css" "$XDG_CONFIG_HOME/gtk-4.0/gtk.css"
) &
recompile_scss "$XDG_CONFIG_HOME/swaync"
recompile_scss "$XDG_CONFIG_HOME/wofi"

wait
eww -c "$XDG_CONFIG_HOME/sway/eww/shell/" reload &
swaync-client -rs >/dev/null &
swaymsg reload >/dev/null &
wait
