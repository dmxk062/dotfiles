#configures vi mode plugin
function zvm_config() {
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
  ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK  
  ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLOCK  
  ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
  ZVM_MODE_INSERT=true
}
#sources the plugin
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh



#completion
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

#fish-like suggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#4c566a,bold"
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

#history
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down
[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search


#my color theme
export LS_COLORS="$(vivid generate ~/.config/vivid/themes/dmxnord.yaml)"


#completion opts
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select=-1
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' verbose false
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"


#history
HISTFILE=~/.local/share/zsh/histfile
HISTSIZE=4000
SAVEHIST=8000


#cds on path
setopt autocd


#no annoying beeps
unsetopt beep

DISABLE_AUTO_TITLE="true"
# enables commenting with # in interactive shells
setopt INTERACTIVE_COMMENTS


#Prompt
PROMPT="%B%F{magenta}%S %n %s %B%F{cyan}%S󰉋 %(4~|%-1~/…/%24<..<%2~%<<|%4~)%s%f%b "
#Prompt for nested things:
PS2="%B%S%_%s%f%b "
#sudo prompt
export SUDO_PROMPT="
[31;1m[30;41;1m sudo[0m[31;1m[0m " 

#pkexec
alias guido="pkexec"

#paths
hash -d cfg=$HOME/.config
hash -d eww=$HOME/.config/eww
hash -d ags=$HOME/.config/ags
hash -d tmp=$HOME/Tmp
hash -d music=$HOME/Media/Music/
hash -d school=$HOME/Documents/school/


#nice to have aliases
alias c="clear"
alias q="exit"
alias x="exit"
alias :q="exit" #vim muscle memory lol
#save me from my own stupidity
alias rm="rm -i"


#some fancy aliases for several ls commands
alias ls='ls --color=auto' #use color with ls
alias ll='lsd -l' #Ls Long using lsd to quickly get a lot of info
alias lla='lsd -lA' #List Long All
alias llo='lsd -l --permission=octal' #List Long Octal
alias llao='lsd -lA --permission=octal' #List Long All Octal
alias la='lsd -A' #List All
alias lr='lsd --tree --depth 3 ' #List Recursive
alias l='lsd' #l as a short alias for lsd, so it doesn't conflict with ls 
#nicer grep for interactive usage
alias grep='grep --color=auto'
#all the other aliases, mostly for apps
source ~/.config/zsh/aliases
#some aliases for kitty
if [[ "$TERM" == "xterm-kitty" ]]
then
    function wnv(){
        kitty @ launch --type=window zsh -ic "nvim $@ -O"
    }
    function wlf(){
        kitty @ launch --type=window zsh -ic "lf $PWD"
    }
    function wzs(){
        kitty @ launch --type=window zsh -i $@
    }
    function tnv(){
        kitty @ launch --type=tab zsh -ic "nvim $@ -O"
    }
    function tlf(){
        kitty @ launch --type=tab zsh -ic "lf $PWD"
    }
    function tzs(){
        kitty @ launch --type=tab zsh -i $@
    }
fi



function alert(){ #alert function to notify after a command.
  outcome=$?
  if (( $outcome == 0))
  then
    notify-send --urgency=critical -i "terminal" "Process completed."
    return $outcome
  else 
    notify-send --urgency=critical -i "error" "Process failed with exit code: $outcome"
    return $outcome
  fi 
}
function preexec() {
  timer=$(($(date +%s%0N)/1000000))
}

function precmd() {
    if [ $timer ]; then
        now=$(($(date +%s%0N)/1000000))
        elapsed=$(($now-$timer))
        if [[ $elapsed -gt 60000 ]] 
        then
            elapsed_f="$(($elapsed/60000.0))"
            elapsed_u="$(printf "%.2f\n" "$elapsed_f")m"
        elif [[ $elapsed -gt 500 ]]
        then
            elapsed_f="$(($elapsed/1000.0))"
            elapsed_u="$(printf "%.2f\n" "$elapsed_f")s"
        else
            elapsed_u="${elapsed}ms"
        fi
        RPS1="%F%(?.%F{green}.%F{red})%S%(?.. exit: %?)%s %F{yellow}%S󰥔 ${elapsed_u} %s%f"
        unset timer
    fi
    print -Pn "\e]0;zsh: %~\a"
}

#autopairing for quotes, brackets etc
source ~/.config/zsh/autopair.zsh
autopair-init

#syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
source ~/.config/zsh/highlight


#fzf
export FZF_DEFAULT_OPTS="
--color=fg:#eceff4,fg+:#8fbcbb,bg:#2e3440,bg+:#2e3440,preview-fg:#eceff4,preview-bg:#2e3440,hl:#bf616a,hl+:#bf616a
--color=info:#ebcb8b,border:#4c566a,prompt:#eceff4,pointer:#8fbcbb,marker:#8fbcbb,spinner:#8fbcbb,header:#eceff4"

function fzvm(){
    nvim "$(find . -type f -o -path ./.local/share/Steam -prune -o -path ./.steam -prune -o -path ./Games -prune -o -print |fzf --preview 'bat --color=always -pp {}')"
}
function fzcd(){
    cd "$(find . -type d -path ./.local/share/Steam -prune -o -path ./.steam -prune -o -path ./Games -prune -o -print |fzf --preview 'lsd -l {}')"
}

#zoxide
eval "$(zoxide init zsh)"


#fancy command not found that opens files
function command_not_found_handler {
    printf 'zsh: command not found: %s\n' "$1"
    file="$1"
    if [[ -f "./$1" ]]
    then
        printf 'zsh: file %s found. Open it in %s? [y/N] ' "$file" "$EDITOR"
        read -k 1 answer
        if [[ "$answer" == "y" || "$answer" == "Y" ]]
        then 
            $EDITOR "$file"
        fi
    else 
        local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
        local entries=(${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"})
        if (( ${#entries[@]} ))
        then
            printf "zsh: but it is available in the following package(s):\n"
            local pkg
            for entry in "${entries[@]}"
            do
                local fields=(${(0)entry})
                if [[ "$pkg" != "${fields[2]}" ]]
                then
                    printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
                fi
                pkg="${fields[2]}"
            done
        else
            printf "zsh: could not find a package that provides /usr/bin/%s in the repos. search the AUR? [y/N] " "$file"
            read -k 1 answer
            if [[ "$answer" == "y" || "$answer" == "Y" ]]
            then
                printf "\n"
                yay -Ssa "$file"
            fi
        fi
    fi
    return 127
}
# changes to the directory specified if started from lf
cd "$lfdir"

 export MANROFFOPT='-c'
 function enable_git(){
     eval "$(ssh-agent -s)"
     ssh-add ~/.ssh/git_id
}
function ws(){
    cd ~/ws/$1
    enable_git
    git status
}

function md(){
    for dir in $@
    do
        mkdir -p $dir
    done
}
