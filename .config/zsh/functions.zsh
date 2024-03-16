# fancy command not found that opens files



function enable_git(){
     # eval "$(ssh-agent -s)" >/dev/null 2>&1
     ssh-add "$HOME/.local/share/keys/git"
}

# function to use a workspace in ~/ws

function ws(){
    [ -z $1 ]&& return
    cd $HOME/ws/$1||return 1
    enable_git
    print -P "%B󰌌%b working on %F{green}%{\x1b[3m%}$1%{\x1b[0m%}"
}

function md(){
    for dir in $@
    do
        mkdir -p $dir
    done
}
function mcd {
    mkdir -p "$1"
    cd "$1"
}


ft(){
    file --brief --dereference --mime-type "$@"
}


c(){
    print -n "[H[2J"
}



source $ZDOTDIR/handler_functions.zsh
source $ZDOTDIR/dash_functions.sh

# functions to use modules
source $ZDOTDIR/modules.zsh

# load all the modules i always want
+mod fun  silent
+mod proc silent
+mod math silent
+mod pkg  silent
+mod net  silent
