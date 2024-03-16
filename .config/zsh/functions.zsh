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

function y {
    wl-copy --type=text
}



function qi(){
    echo "Calculator"
    printf "\033]0;qalc\007"
    qalc
}

ft(){
    file --brief --dereference --mime-type "$@"
}

url(){
    local file="${*//+/ }"
    file="${file//file:\/\//}"
    file="${file//\%/\\x}"
    file="$(echo -e "$file")"
    if [[ -d "$file" ]]; then
        cd "$file"
    elif [[ -f "$file" ]]; then
        case "$(file --dereference --mime-type --brief "$file")" in
            text/*)
                nvim "$file"
                ;;
        esac
    fi
}



# open(){
# # fancy openener
#
# local files_edit=()
#
# if [[ "$1" == "-g" ]] || [[ "$1" == "--gui" ]]; then
#     local gui=true
#     shift
# fi
#
# local files=("$@")
# if [[ "$files" == "" ]]; then
#     print "zsh: open: exepected at least 1 argument"
#     return 1
# fi
#
# for file in "${files[@]}"; do
#     local mimetype="$(file --dereference --brief --mime-type "$file")"
#     case $mimetype in 
#         text/*|application/json|inode/x-empty|application/x-subrip|application/javascript|application/x-elc)
#         files_edit+=("$file")
#             ;;
#     esac
# done
#
# if [[ "${#files_edit}" -gt 0 ]]; then
#     if $gui; then
#         for file in ${files_edit[@]}; do
#             print -n "Opening ${file}: "
#             xdg-open "$file" & disown
#         done
#     else
#         $VISUAL -O ${files_edit[@]}
#     fi
# fi
# }
#
#
# faster than the clear binary, yes 
c(){
    print -n "[H[2J"
}

req(){
    curl -s "$@"
}

jreq(){
    local url="$1"
    shift
    local jqopts="${(j:,:)@}"
    curl -s "$url"|jq -r "${jqopts:-.}"
}

# some aliases depending on this:

alias get_public_ip="jreq ipinfo.io .ip"

# we love functional programming

source $ZDOTDIR/handler_functions.zsh
source $ZDOTDIR/dash_functions.sh
source $ZDOTDIR/modules.zsh

# load all the modules i always want
+mod fun  silent
+mod proc silent
+mod math silent
