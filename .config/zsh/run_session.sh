#!/usr/bin/env zsh


print "Hi ${USER}!"

if [[ "${TTY}" == "/dev/tty1" ]]
then
    if [[ -n $DISPLAY ]] || [[ -n $WAYLAND_DISPLAY ]]; then
        print "There already is a display server running. Dropping you to a shell (${SHELL}).\n"
        exec $SHELL
    else
        if command -v sway
        then
            print -P "%F{green}Handing off control to sway now%f"
            XDG_CURRENT_DESKTOP=sway:wlroots
            export XDG_CURRENT_DESKTOP
            exec sway
        else
            print -P "%F{red}sway is not installed%f\nDropping you to a shell (${SHELL})\n"
            exec $SHELL
        fi
    fi
else 
    print -P "You logged in at %B${TTY}%b\nTo get a graphical environment with sway, please log in at %B/dev/tty1%b (press %B<C-M-F1>%b to get there)\nDropping you to a shell (${SHELL}).\n\n"
    exec $SHELL
fi
