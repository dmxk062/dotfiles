function enable_git(){
     # eval "$(ssh-agent -s)" >/dev/null 2>&1
     ssh-add "$HOME/.local/share/keys/git"
}


# faster, way faster than proper `clear`
c(){
    print -n "[H[2J"
}

alias -- "-gtk_debug"="env GTK_DEBUG=interactive" \
   "-gnome"="env XDG_CURRENT_DESKTOP=gnome"

# a better `watch`
function -mon {
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
        IFS=$'\n' output=($(eval -- "${command[@]}"))
        print -n "\e]0;$output[1]\a"
        print -n "[H[2J"
        print -n "Every $interval $unit: \`${command[@]}\`\n\n${output}"
        sleep "$interval"
    done

}


# tell me when smth finished running
function -alert {
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
function -bg {
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



source $ZDOTDIR/handlers.zsh

# functions to use modules
source $ZDOTDIR/modules.zsh

# load all the modules i always want
+mod fun  silent
+mod proc silent
+mod math silent
+mod pkg  silent
+mod net  silent
+mod fs   silent
+mod json silent
+mod virt silent
+mod git  silent

if [[ "$TERM" == "xterm-kitty" ]] {
    +mod kitty silent
}

# desktop stuff
+mod sound silent
