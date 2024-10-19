# faster, way faster than proper `clear`
function c {
    print -n "[H[2J"
}

alias -- "@gtk_debug"="env GTK_DEBUG=interactive" \
   "@gnome"="env XDG_CURRENT_DESKTOP=gnome"

# a better `watch`
function @mon {
    local interval="$1"
    if [[ "$interval" =~ ^[+-]?[0-9]*\.?[0-9]+$ ]]; then
        shift
    else
        interval=1
    fi
    local -a command=("${@}") unit 
    if ((interval == 1)) {
        unit=second
    } else {
        unit=seconds
    }
    local output
    while true; do
        local IFS=$'\n' output=($(eval -- "${command[@]}"))
        print -n "\e]0;$output[1]\a"
        print -n "[H[2J"
        print -n "Every $interval $unit: \`${command[@]}\`\n\n${output}"
        # more accurate than calling out to non built in `sleep`
        read -t "$interval" _ -n 0
    done

}


# tell me when smth finished running
function @alert {
    local prog exitc start end time
    prog=$@
    start="$(date "+%s")"
    eval "$prog"
    exitc="$?"
    end="$(date "+%s")"
    time=$((end - start))
    if (( exitc > 0)) {
        notify-send -i "script-error" \
            -a zsh \
            "Program failed with code: ${exitc}" \
            "\`${prog}\` failed after $(date -d @$time "+%M:%S")"

    } else {
        notify-send -i "terminal" \
            -a zsh \
            "Program finished" \
            "\`${prog}\` took $(date -d @$time "+%M:%S")"

    }

}

# run smth in the background
function @bg {
    local stderr exitc prog start end time
    prog=$@
    (start="$(date +%s)"
    stderr="$(eval "$prog" 2>&1 >/dev/null)"
    exitc="$?"
    end="$(date +%s)"
    time=$((end - start))
    if ((exitc > 0)) {
        if [[ "$stderr" == "" ]] {
            stderr="Stderr was empty"
        }
        notify-send -i "script-error" \
            -a zsh "Program failed with code: ${exitc}" \
            "\`${prog}\` failed after $(date -d @$time "+%M:%S"):
${stderr}"
    } else {
        notify-send -i "terminal" \
            -a zsh \
            "Program finished" \
            "\`${prog}\` took $(date -d @$time "+%M:%S")"
    }
    )& disown
    
}

function chars2codes {
    local char
    while read -u0 -k1 -r char; do
        printf "%x\n" "'$char"
    done
}

function codes2chars {
    local code
    while read -r code; do
        printf "\\U$code"
    done
}

function lcd {
    cd "$(command lf -print-last-dir "$@")"
}

# simple clone of the tool with the same name
function vipe {
    local tmpfile="$(mktemp)"
    cat > "$tmpfile"
    $EDITOR "$tmpfile" > /dev/tty < /dev/tty
    cat "$tmpfile"
    command rm -rf "$tmpfile"
}



source $ZDOTDIR/handlers.zsh

# load all the modules i always want
source "$ZDOTDIR/mods/fun.zsh" load
source "$ZDOTDIR/mods/pkg.zsh" load
source "$ZDOTDIR/mods/proc.zsh" load
source "$ZDOTDIR/mods/net.zsh" load
source "$ZDOTDIR/mods/fs.zsh" load
source "$ZDOTDIR/mods/structured_data.zsh" load
source "$ZDOTDIR/mods/git.zsh" load

if [[ "$TERM" == "xterm-kitty" ]]; then
    source "$ZDOTDIR/mods/kitty.zsh" load
fi

if [[ -n "$WAYLAND_DISPLAY" ]]; then
    source "$ZDOTDIR/mods/gui.zsh" load
fi
