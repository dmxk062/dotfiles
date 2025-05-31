#!/bin/false
# vim: ft=zsh

# wrappers around fzf for my most common use cases

if [[ "$1" == "unload" ]]; then
    unfunction fed fcd _fzf_shell_hist

    unset FZF_DEFAULT_OPTS
    return
fi

FZF_DEFAULT_OPTS="--pointer='' --no-scrollbar --no-separator --border=none --no-bold"
FZF_DEFAULT_OPTS+=" --color="\
prompt:cyan,\
fg:white,\
bg:black,\
bg+:gray,\
gutter:black,\
hl:yellow:underline,\
hl+:yellow:underline,\
info:magenta,\
border:gray,\
query:white:regular,\
preview-fg:white,\
preview-bg:black,\
spinner:cyan,\
marker:magenta,\
header:white

export FZF_DEFAULT_OPTS

# find & edit
function fed {
    local res="$(fd $@ --type=file|fzf --height=18 --prompt=" ed: " --preview='bat -p --color=always -- {}')"
    if [[ -z "$res" ]]; then
        return
    fi
    local parent="${res:h}"
    local abs="${res:A}"
    (cd "$parent"; "$EDITOR" "$abs")
}
compdef nz=fd

# find * cd
function fcd {
    local res="$(fd $@ --type=dir | fzf --height=18 --prompt="cd: " --preview='lsd -l -- {}')"
    if [[ -n "$res" ]]; then
        cd "$res"
    fi
}
compdef fcd=fd

# search shell history
function _fzf_shell_hist {
    local res="$(fc -n -l $HISTSIZE|awk '!seen[$2]++'|fzf --no-sort --tac --height=18 --prompt="hist: " -q "^$BUFFER")"
    if [[ -n "$res" ]]; then
        BUFFER="${res}"
        zle end-of-line
    fi
    zle reset-prompt
}
zle -N fzf-shell-hist _fzf_shell_hist
bindkey '^[/' fzf-shell-hist

export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS --prompt='cd: ' --height=18 --preview='lsd -l {2}'"
