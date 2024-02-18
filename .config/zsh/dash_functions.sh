#!/bin/false

#
# Generally useful functions starting with a `-` to separate them from programs
# Some are used to run a command in an alternate environment of some kind,
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

-from_where(){
    if [[ -f "$1" ]]; then
        local progpath="$1"
    else
        local progpath="$(which "$1")"
        if [[ "$progpath" == *"aliased"* ]]; then
            progpath="/usr/bin/${1}"
        fi
        if ! [[ -f "$progpath" ]]; then
            print "File does not exist: ${progpath}"
            return 1
        fi
    fi
    pacman -Qo "$progpath"
    unset progpath
}

-abs(){
    realpath "$1"
}

-url(){
    print -n "file://"
    local fpath="$(realpath "$1")"
    printf '%s' "$fpath"|jq -sRr @uri|sed 's/%2F/\//g'
}

# tell me when smth finished running
-alert(){
    local prog exitc start end time
    prog=$@
    start="$(date "+%s")"
    eval "$prog"
    exitc="$?"
    end="$(date "+%s")"
    time=$((end - start))
    if (( exitc > 0)); then
        notify-send -i "script-error" \
            -a zsh \
            "Program failed with code: ${exitc}" \
            "\`${prog}\` failed after $(date -d @$time "+%M:%S")"

    else
        notify-send -i "terminal" \
            -a zsh \
            "Program finished" \
            "\`${prog}\` took $(date -d @$time "+%M:%S")"

    fi

}

# run smth in the background
-bg(){
    local stderr exitc prog start end time
    prog=$@
    (start="$(date +%s)"
    stderr="$(eval "$prog" 2>&1 >/dev/null)"
    exitc="$?"
    end="$(date +%s)"
    time=$((end - start))
    if ((exitc > 0)); then
        if [[ "$stderr" == "" ]]; then
            stderr="Stderr was empty"
        fi
        notify-send -i "script-error" \
            -a zsh "Program failed with code: ${exitc}" \
            "\`${prog}\` failed after $(date -d @$time "+%M:%S"):
${stderr}"
    else
        notify-send -i "terminal" \
            -a zsh \
            "Program finished" \
            "\`${prog}\` took $(date -d @$time "+%M:%S")"
    fi
    )& disown
    
}

