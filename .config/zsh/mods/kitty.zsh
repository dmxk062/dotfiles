#!/bin/false
# vim: ft=zsh

if [[ "$1" == "unload" ]]; then

    unfunction ktty

    unalias -- "@w" "@W" "@t" "@o" "@we" "@We" "@te" "@oe"
    return
fi

# manually activate shell integration for the parts i care about
if [[ ! -n "$KITTY_SHELL_INTEGRATION_ENABLED" && -n "$KITTY_INSTALLATION_DIR" && "$TERM" == "xterm-kitty" ]] {
    export KITTY_SHELL_INTEGRATION="no-cursor no-title"
    autoload -Uz -- "$KITTY_INSTALLATION_DIR/shell-integration/zsh/kitty-integration"
    KITTY_SHELL_INTEGRATION_ENABLED=1
    kitty-integration
    
    unfunction kitty-integration
}

if [[ "$KITTY_SHELL_INTEGRATION_ENABLED" != 1 ]] {
    return 1
}


function ktty {
    local type="${1}"
    local cmd="${@:2}"

    if [[ -z "$cmd" ]] {
        clone-in-kitty --type="$type"
    } else {
        kitty @ launch --cwd="$PWD" --no-response --type="$type" -- zsh -ic -- "${cmd[@]}"
    }
}

function kitty-win-go-left { kitty @ action neighboring_window left }
function kitty-win-go-down { kitty @ action neighboring_window down }
function kitty-win-go-up { kitty @ action neighboring_window up }
function kitty-win-go-right { kitty @ action neighboring_window right }

zle -N kitty-win-go-left
zle -N kitty-win-go-down
zle -N kitty-win-go-up
zle -N kitty-win-go-right

zvm_bindkey vicmd "^Wh" kitty-win-go-left
zvm_bindkey vicmd "^Wj" kitty-win-go-down
zvm_bindkey vicmd "^Wk" kitty-win-go-down
zvm_bindkey vicmd "^Wl" kitty-win-go-down

autoload -Uz _ktty
compdef _ktty ktty


alias -- "@w"="ktty window" \
    "@W"="ktty os-window" \
    "@t"="ktty tab" \
    "@o"="ktty overlay" \
    "@we"="ktty window $EDITOR" \
    "@We"="ktty os-window $EDITOR" \
    "@te"="ktty tab $EDITOR" \
    "@oe"="ktty overlay $EDITOR"

