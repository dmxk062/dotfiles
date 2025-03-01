# make it easier to use nvr inside neovim
# e.g. `cmd | sp` just opens a split with the results

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
