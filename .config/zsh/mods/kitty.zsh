#!/bin/false
# vim: ft=zsh

if [[ "$1" == "load" ]] {


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

autoload -Uz _ktty

function ktty {
    local type="${1}"
    local cmd="${@:2}"

    if [[ -z "$cmd" ]] {
        clone-in-kitty --type="$type"
    } else {
        kitty @ launch --cwd="$PWD" --no-response --type="$type" -- zsh -ic -- "${cmd[@]}"
    }
}

compdef _ktty ktty


alias -- "-w"="ktty window" \
    "-W"="ktty os-window" \
    "-t"="ktty tab" \
    "-o"="ktty overlay" \
    "-we"="ktty window $EDITOR" \
    "-We"="ktty os-window $EDITOR" \
    "-te"="ktty tab $EDITOR" \
    "-oe"="ktty overlay $EDITOR"

} elif [[ "$1" == "unload" ]] {

unfunction ktty

unalias -- "-w" "-W" "-t" "-o" "-we" "-We" "-te" "-oe"

}
