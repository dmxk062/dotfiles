function enable_git(){
     # eval "$(ssh-agent -s)" >/dev/null 2>&1
     ssh-add "$HOME/.local/share/keys/git"
}


# faster, way faster than proper `clear`
c(){
    print -n "[H[2J"
}

function -gtk_debug {
    export GTK_DEBUG=interactive
    "$@" & disown
}

function -gnome {
    env XDG_CURRENT_DESKTOP=gnome "$@"    
}

# a better `watch`
function -mon {
    local interval="$1"
    if [[ "$interval" =~ ^[0-9]+$ ]]; then
        shift
    else
        interval=1
    fi
    local command="$*"
    if ((interval == 1)) {
        unit=second
    } else {
        unit=seconds
    }
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

if [[ $KITTY_SHELL_INTEGRATION_ENABLED == 1 ]] {
# special kitty dependant stuff
function -win {
    if [[ -z "$1" ]] {
        clone-in-kitty --type=window
    } else {
        kitty @ launch --type=window \
        -- zsh -ic "cd $PWD;$*" > /dev/null
    }
}

function -tab {
    if [[ -z "$1" ]] {
        clone-in-kitty --type=tab
    } else { 
        kitty @ launch --type=tab \
        -- zsh -ic "cd $PWD;$*" > /dev/null
    }
}
function -ol {
    if [[ -z "$1" ]] {
        clone-in-kitty --type=overlay
    } else {
        kitty @ launch --type=overlay \
        -- zsh -ic "cd $PWD;$*" > /dev/null
    }
}
function -wed {
    kitten edit --type=window "$1" >/dev/null 2>&1
}
function -ted {
    kitten edit --type=tab "$1" >/dev/null 2>&1
}
function -ed {
    kitten edit --type=overlay "$1" >/dev/null 2>&1
}
alias -- "-t"="-tab"
alias -- "-w"="-win"

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


# dynamic sudo thingy
function -root {
    if [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]] {
        pkexec "$@"
    } else {
        sudo "$@"
    }
}

function -s {
    sudo "$@"
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

# desktop stuff
+mod sound silent

