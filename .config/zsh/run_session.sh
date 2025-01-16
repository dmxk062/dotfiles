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
            XDG_CURRENT_DESKTOP=sway
            export XDG_CURRENT_DESKTOP
            exec dbus-run-session sway
        else
            print -P "%F{red}sway is not installed%f\nDropping you to a shell (${SHELL})\n"
            exec $SHELL
        fi
    fi
else 
    exec $SHELL
fi
