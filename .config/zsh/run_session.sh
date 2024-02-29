#!/usr/bin/env zsh


print "Hi ${USER}!"

if [[ "${TTY}" == "/dev/tty1" ]]
then
    if [[ -n $DISPLAY ]] || [[ -n $WAYLAND_DISPLAY ]]; then
        print "There already is a display server running. Dropping you to a shell (${SHELL}).\n"
        exec $SHELL
    else
        if command -v Hyprland
        then
            print -P "%F{green}Handing off control to Hyprland now%f"
            exec Hyprland
        else
            print -P "%F{red}Hyprland is not installed%f\nDropping you to a shell (${SHELL})\n"
            exec $SHELL
        fi
    fi
else 
    print -P "You logged in at %B${TTY}%b\nTo get a graphical environment with Hyprland, please log in at %B/dev/tty1%b (press %B<C-M-F1>%b to get there)\nDropping you to a shell (${SHELL}).\n\n"
    exec $SHELL
fi
