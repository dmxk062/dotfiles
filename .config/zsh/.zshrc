fpath+="$ZDOTDIR/comp"
declare -A ZSH_COLORS_RGB=(
    ["light-gray"]="#4c566a"
    ["orange"]="#d08770"
)

# handle combining unicode chars
setopt combiningchars
# cds on path
setopt autocd
# no annoying beeps
unsetopt beep


function zvm_config {
    ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
    ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
    ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK  
    ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLOCK  
    ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_BLOCK
    ZVM_MODE_INSERT=true
    ZVM_VI_SURROUND_BINDKEY=classic
    ZVM_VI_HIGHLIGHT_BACKGROUND=8
    zvm_bindkey vicmd "/" history-incremental-search-backward
}
#sources the plugin
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh


#fish-like suggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
zvm_bindkey viins '^ ' autosuggest-accept
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,bold"
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

#history
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

bindkey '^Z' push-line


#my color theme
case $KITTY_THEME in
    dark)
        export LS_COLORS="$(vivid generate ~/.config/vivid/themes/darknord.yaml)";;
    light)
        export LS_COLORS="$(vivid generate ~/.config/vivid/themes/lightnord.yaml)";;
esac


#completion opts
zstyle ':completion:*' completer _complete _expand _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} "ma=;1"
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select=-1
zstyle ':completion:*' select-prompt"%B%F{cyan}%S %l%s%f%b"
zstyle ':completion:*' list-prompt "%B%F{cyan}%S %l%s%f%b"
zstyle ':completion:*' verbose false

zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals:*'  insert-sections   true


autoload -Uz compinit
# only reload comps after reboot effectively
compinit -d "$XDG_CACHE_HOME/zcompdump-$ZSH_VERSION"
compdef _files '-redirect-' # for some reason wasnt default

#history
HISTFILE="$XDG_DATA_HOME/zsh/histfile"
HISTSIZE=4000
SAVEHIST=8000



# add whatever directories you want to be hashed(accessible via ~shortcut) here
nameddirs=(
    ["cfg"]="$HOME/.config"
    ["dl"]="$HOME/Downloads"
    ["tmp"]="$HOME/Tmp"
    ["ws"]="$HOME/ws"
    ["build"]="$HOME/ws/build"
    ["music"]="$HOME/Media/Music"
    ["docs"]="$HOME/Documents"
    ["jrnl"]="$HOME/Documents/journal/journal/"
    ["school"]="$HOME/Documents/school"
    ["mnt"]="/mnt"
    ["arc"]="$HOME/.avfs"
    ["media"]="/run/media/$USER"
    ["games"]="$HOME/Games"
)

#autopairing for quotes, brackets etc
source $ZDOTDIR/autopair.zsh
source $ZDOTDIR/variables.zsh
source $ZDOTDIR/functions.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/prompt.zsh
source $ZDOTDIR/fzf.zsh
autopair-init

#syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
source "$ZDOTDIR/highlight"



#zoxide
eval "$(zoxide init zsh)"



export BAT_THEME="Nord"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT='-c'
