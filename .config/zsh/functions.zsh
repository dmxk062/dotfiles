function enable_git(){
     # eval "$(ssh-agent -s)" >/dev/null 2>&1
     ssh-add "$HOME/.local/share/keys/git"
}


# faster, way faster than proper `clear`
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
+mod fs   silent

# desktop stuff
+mod sound silent

