#!/usr/bin/env zsh


printf "Hi ${USER}!\n"


if [[ "$(tty)" == "/dev/tty1" ]]
then
    if pgrep Hyprland > /dev/null 2>&1
    then
        printf "Hyprland is already running. Dropping you to a shell (${SHELL}).\n\n"
        exec $SHELL
    else
        if command -v Hyprland
        then
            printf "\033[32mHanding off control to Hyprland now\033[0m\n"
            exec Hyprland
        else
            printf "\033[31mHyprland is not installed\033[0m\nDropping you to a shell (${SHELL})\n\n"
        fi
    fi
else 
    printf "You logged in at \033[1m$TTY\033[0m.\nTo get a graphical environment with Hyprland, please log in at \033[1m/dev/tty1 \033[0m(press \033[1m<C-M-F1>\033[0m to get there)\nDropping you to a shell (${SHELL}).\n\n"
    exec $SHELL
fi
