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
case $KITTY_THEME in
    dark)
        export LS_COLORS="$(vivid generate ~/.config/vivid/themes/darknord.yaml)";;
    light)
        export LS_COLORS="$(vivid generate ~/.config/vivid/themes/lightnord.yaml)";;
esac


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

# add whatever directories you want to be hashed(accessible via ~shortcut) here

local -A DIRSHORTCUTS=(
    ["cfg"]="$HOME/.config"
    ["dl"]="$HOME/Downloads"
    ["tmp"]="$HOME/Tmp"
    ["ws"]="$HOME/ws"
    ["build"]="$HOME/ws/build"
    ["music"]="$HOME/Media/Music"
    ["docs"]="$HOME/Documents"
    ["school"]="$HOME/Documents/school"
    ["mnt"]="/mnt"
    ["media"]="/run/media/$USER"
)

for shortcut in ${(k)DIRSHORTCUTS}; do
    hash -d ${shortcut}=${DIRSHORTCUTS[$shortcut]}
done

unset DIRSHORTCUTS
#------------------------------------------------------------------------------

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

PROMPT="%B%F{magenta}%S %n %s %B%F{cyan}%S󰉋 %(4~|%-1~/…/%24<..<%2~%<<|%4~)%s%f%b "
# Prompt for nested things:
PS2="%B%S%_%s%f%b "
# sudo prompt
export SUDO_PROMPT="
[31;1m[30;41;1m sudo[0m[31;1m[0m " 

#autopairing for quotes, brackets etc
source $ZDOTDIR/autopair.zsh
source $ZDOTDIR/functions.zsh
source $ZDOTDIR/aliases.zsh
autopair-init

#syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
source ~/.config/zsh/highlight


#fzf
export FZF_DEFAULT_OPTS="
--color=fg:#eceff4,fg+:#8fbcbb,bg:#2e3440,bg+:#2e3440,preview-fg:#eceff4,preview-bg:#2e3440,hl:#bf616a,hl+:#bf616a
--color=info:#ebcb8b,border:#4c566a,prompt:#eceff4,pointer:#8fbcbb,marker:#8fbcbb,spinner:#8fbcbb,header:#eceff4"


#zoxide
eval "$(zoxide init zsh)"



export BAT_THEME="Nord"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT='-c'

# changes to the directory specified if started from lf
cd "$lfdir"
