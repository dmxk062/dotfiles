#!/bin/false
# vim: ft=zsh

if [[ "$1" == "unload" ]]; then
    unalias sparse-clone sparse-add unstage
    unfunction gac

    return
fi

alias sparse-clone="git clone --filter=blob:none --sparse" \
    sparse-add="git sparse-checkout add"\
    unstage="git restore --staged -- "

