# faster, way faster than proper `clear`
function c {
    print -n "[H[2J"
}

# run program in alternate screen
function @alt {
    if [[ -t 1 ]]; then
        tput smcup
        eval "$@"
        tput rmcup
    fi
}

compdef @alt=eval

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
    cat >> "$tmpfile"
    if [[ -n "$1" && "$EDITOR" == *vim ]]; then
        $EDITOR "$tmpfile" +"setf $1" > /dev/tty < /dev/tty
    else
        $EDITOR "$tmpfile" > /dev/tty < /dev/tty
    fi
    cat "$tmpfile"
    command rm -rf "$tmpfile"
}


function hlcolor {
    while read -r hex; do
        printf '\e[48;2;%d;%d;%dm%s\n' \
            "0x${hex:1:2}" "0x${hex:3:2}" "0x${hex:5:2}" "$hex"
    done
}



source $ZDOTDIR/handlers.zsh

# load all the modules i always want
source "$ZDOTDIR/mods/fun.zsh"
source "$ZDOTDIR/mods/proc.zsh"
source "$ZDOTDIR/mods/net.zsh"
source "$ZDOTDIR/mods/fs.zsh"
source "$ZDOTDIR/mods/structured_data.zsh"
source "$ZDOTDIR/mods/git.zsh"
source "$ZDOTDIR/mods/fzf.zsh"

if [[ "$TERM" == "xterm-kitty" ]]; then
    source "$ZDOTDIR/mods/kitty.zsh"
fi
