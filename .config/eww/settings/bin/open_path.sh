#!/bin/zsh -i

eww -c $HOME/.config/eww/settings/ close settings
kitty --class="popup" -e lf "$1"
eww -c $HOME/.config/eww/settings/ open settings --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')

