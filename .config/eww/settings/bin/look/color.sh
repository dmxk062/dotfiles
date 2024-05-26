#!/usr/bin/env bash
cd || exit # so the pwd isnt fucked up
colorfile="$XDG_CONFIG_HOME/eww/style/color.scss"

if [[ $1 == 'get' ]]
then
    if grep -q 'dark.scss' "$colorfile"
    then
        eww -c $XDG_CONFIG_HOME/eww/settings update look_colorscheme="dark"
        eww -c $XDG_CONFIG_HOME/eww/shell update look_colorscheme="dark"
    else
        eww -c $XDG_CONFIG_HOME/eww/settings update look_colorscheme="light"
        eww -c $XDG_CONFIG_HOME/eww/shell update look_colorscheme="light"
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
    unlink $XDG_CONFIG_HOME/gtk-4.0/gtk.css
    ln -s $XDG_CONFIG_HOME/gtkcss/4.0/gtk-light.css $XDG_CONFIG_HOME/gtk-4.0/gtk.css
    color="light"
else
    sed -i 's/light.scss/dark.scss/' $XDG_CONFIG_HOME/eww/style/color.scss
    sed -i 's/light/dark/' $XDG_CONFIG_HOME/rofi/style/color.rasi
    sed -i 's/light.conf/dark.conf/' $XDG_CONFIG_HOME/hypr/theme/colors.conf
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    unlink $XDG_CONFIG_HOME/swaylock/config
    ln -s $XDG_CONFIG_HOME/swaylock/config.dark $XDG_CONFIG_HOME/swaylock/config
    unlink $XDG_CONFIG_HOME/gtk-4.0/gtk.css
    ln -s $XDG_CONFIG_HOME/gtkcss/4.0/gtk-dark.css $XDG_CONFIG_HOME/gtk-4.0/gtk.css
    color="dark"
fi
for EWW in settings shell
do
    eww -c $XDG_CONFIG_HOME/eww/$EWW reload
done
if [[ $1 != "noeww" ]]; then
    $HOME/.local/bin/eww_settings.sh
fi
killall hyprmon.sh
sleep 0.1
eww -c $XDG_CONFIG_HOME/eww/settings update look_colorscheme="$color"
eww -c $XDG_CONFIG_HOME/eww/shell update look_colorscheme="$color"
eww -c $XDG_CONFIG_HOME/eww/shell open desktop_area --screen 0
$XDG_CONFIG_HOME/eww/settings/bin/audio_state.sh
$XDG_CONFIG_HOME/eww/settings/bin/sinks_sources.sh upd sinks & disown
$XDG_CONFIG_HOME/eww/settings/bin/sinks_sources.sh upd sources & disown
sassc $XDG_CONFIG_HOME/nwg-drawer/drawer.scss > $XDG_CONFIG_HOME/nwg-drawer/drawer.css
sassc $XDG_CONFIG_HOME/swaync/style.scss > $XDG_CONFIG_HOME/swaync/style.css
sassc $XDG_CONFIG_HOME/wofi/style.scss > $XDG_CONFIG_HOME/wofi/style.css
killall nwg-drawer
sleep 0.2
swaync-client -rs
$XDG_CONFIG_HOME/eww/shell/dock/bin/nwg_drawer.sh --initial
$XDG_CONFIG_HOME/eww/shell/bin/hyprmon.sh monitor & disown
