#!/bin/false

#
# Functions used to run a command in an alternate environment of some kind,
# be it using environment variables or just in another tab
#

-gtk_debug(){
    export GTK_DEBUG=interactive
    "$@" & disown
}

-gnome(){
    env XDG_CURRENT_DESKTOP=gnome "$@"    
}


-win(){
    kitty @ launch --type=window -- zsh -ic "$@"
}

-tab(){
    kitty @ launch --type=tab -- zsh -ic "$@"
}

