# make it easier to use nvr inside neovim
# e.g. `cmd | sp` just opens a split with the results

unalias nv
function nv {
    nvr "${@:--}"
}

function sp {
    nvr -o "${@:--}" 
}

function vsp {
    nvr -O "${@:--}" 
}

function tab {
    nvr -p "${@:--}" 
}

alias qf="nvr -q -"

# vimgrep
function vg {
    rg --vimgrep "$@" | nvr -q -
}
compdef vg=rg

EDITOR=nvr
export GIT_EDITOR="nvr -cc Sp -c 'se bufhidden=delete' --remote-wait"
ZVM_VI_EDITOR=(nvr -cc Sp -c 'se bufhidden=delete' --remote-wait)
