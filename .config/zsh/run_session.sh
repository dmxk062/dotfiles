#!/usr/bin/env zsh


printf "Hi ${USER}!\n"


if [[ "${TTY}" == "/dev/tty1" ]]
then
    if [[ -n $DISPLAY ]]
    then
        echo -en "There already is a display server running. Dropping you to a shell (${SHELL}).\n\n"
        exec $SHELL
    else
        if command -v Hyprland
        then
            echo -en "\033[32mHanding off control to Hyprland now\033[0m\n"
            exec Hyprland
        else
            echo -en "\033[31mHyprland is not installed\033[0m\nDropping you to a shell (${SHELL})\n\n"
            exec $SHELL
        fi
    fi
else 
    echo -en "You logged in at \033[1m${TTY}\033[0m.\nTo get a graphical environment with Hyprland, please log in at \033[1m/dev/tty1 \033[0m(press \033[1m<C-M-F1>\033[0m to get there)\nDropping you to a shell (${SHELL}).\n\n"
    exec $SHELL
fi
