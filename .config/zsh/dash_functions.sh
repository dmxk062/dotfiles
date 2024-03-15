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

# a better `watch`
-mon(){
    local interval="$1"
    if [[ "$interval" =~ ^[0-9]+$ ]]; then
        shift
    else
        interval=1
    fi
    local command="$*"
    if ((interval == 1)); then
        unit=second
    else
        unit=seconds
    fi
    local output old_output
    while true; do
        output="$(eval "$command")"
        print -n "\e]0;$output\a"
        print -n "[H[2J"
        print -n "Every $interval $unit: \`$command\`\n\n$output"
        if [[ "$output" != "$old_output" ]]; then
            print -n "\a"
        fi
        old_output=$output
        sleep "$interval"
    done

}

if [[ $KITTY_SHELL_INTEGRATION_ENABLED == 1 ]]; then
# special kitty dependant stuff
-win(){
    if [[ -z "$1" ]]; then
        clone-in-kitty --type=window
    else
    kitty @ launch --type=window \
        -- zsh -ic "cd $PWD;$*" > /dev/null
    fi
}

-tab(){
    if [[ -z "$1" ]]; then
        clone-in-kitty --type=tab
    else
    kitty @ launch --type=tab \
        -- zsh -ic "cd $PWD;$*" > /dev/null
    fi
}
-ol(){
    if [[ -z "$1" ]]; then
        clone-in-kitty --type=overlay
    else
    kitty @ launch --type=overlay \
        -- zsh -ic "cd $PWD;$*" > /dev/null
    fi
}
-wed(){
    kitten edit --type=window "$1" >/dev/null 2>&1
}
-ted(){
    kitten edit --type=tab "$1" >/dev/null 2>&1
}
-ed(){
    kitten edit --type=overlay "$1" >/dev/null 2>&1
}
alias -- "-t"="-tab"
alias -- "-w"="-win"
fi


-abs(){
    realpath "$1"
}

-uri(){
    local fpath
    fpath="$(realpath "$1")"
    if [[ "$fpath" == "/run/user/$UID/gvfs/sftp"* ]]; then
        local sftppath="${fpath/"\/run\/user\/$UID\/gvfs\/sftp:"/}"
        local host="${sftppath/host=/}"
        host="${host/"\/"*/}"
        local remote_path="${sftppath#*/}"
        print "sftp://${host}/${remote_path}"
        return 0
    fi
    print -n "file://"
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


# dynamic sudo thingy
-root(){
    if [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
        pkexec "$@"
    else
        sudo "$@"
    fi
}

-s(){
    sudo "$@"
}
