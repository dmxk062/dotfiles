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

-uri(){
    local fpath="$(realpath "$1")"
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

