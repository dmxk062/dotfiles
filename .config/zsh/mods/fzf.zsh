#!/bin/false
# vim: ft=zsh

# function and utils for fzf

if [[ "$1" == "unload" ]]; then
    unfunction nz _fzf_shell_hist

    unset FZF_DEFAULT_OPTS
    return
fi

FZF_DEFAULT_OPTS="--pointer='>' --no-scrollbar --no-separator --border=rounded"
FZF_DEFAULT_OPTS+=" --color="\
prompt:cyan:bold,\
fg:white,\
fg+:cyan,\
bg:black,\
bg+:black,\
hl:cyan,\
hl+:cyan,\
info:magenta,\
border:gray,\
query:white:regular,\
preview-fg:white,\
preview-bg:black,\
pointer:cyan,\
spinner:cyan,\
marker:magenta,\
header:white

export FZF_DEFAULT_OPTS

function nz {
    local res="$(fd --hidden -I --type=file -E "*.pyc" -E "*.o" -E "*.bin" -E "*.so" -E "*.tmp" -E "*cache*" -E "*.git/*" \
        |fzf --height=18 --prompt=" ed: " --preview='bat -p --color=always -- {}')"
    if [[ -z "$res" ]]; then
        return
    fi
    local parent="${res:h}"
    local abs="${res:A}"
    (cd "$parent"; nvim "$abs")
}

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

export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS --prompt='󰉋 cd: ' --height=18 --preview='lsd {2}'"
