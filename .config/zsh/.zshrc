# load the initial time first so we can show it in the prompt
zmodload zsh/datetime
_PROMPTTIMER=$EPOCHREALTIME
ZCACHEDIR="$XDG_CACHE_HOME/zsh-$ZSH_VERSION"
if [[ ! -d "$ZCACHEDIR" ]]; then
    mkdir -p "$ZCACHEDIR"
fi

fpath+=("$ZDOTDIR/comp")

declare -A ZSH_COLORS_RGB=(
    ["orange"]="#d08770"
)

# handle combining unicode chars
setopt combiningchars
# cds on path
setopt autocd
# no annoying beeps
unsetopt beep
# complete inside words, brackets etc 
setopt completeinword

# make directory stack better
setopt auto_pushd
setopt pushd_ignore_dups


# vi mode plugin
function zvm_config {
    ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
    ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
    ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK  
    ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLOCK  
    ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_BLOCK
    ZVM_MODE_INSERT=true
    ZVM_VI_SURROUND_BINDKEY=classic
    ZVM_VI_HIGHLIGHT_BACKGROUND=8
    zvm_bindkey vicmd "/" history-incremental-search-backward
}
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh


# fish-like suggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
zvm_bindkey viins '^ ' autosuggest-accept
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,bold"
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# history
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

bindkey '^Z' push-line


# semi lazily generate and load colors for ls etc
if [[ -z "$LS_COLORS" ]]; then
    color_cache="$ZCACHEDIR/ls_colors"
    if [[ ! -f "$color_cache" ]]; then
        print -n "export LS_COLORS='" > "$color_cache"
        vivid generate "$XDG_CONFIG_HOME/vivid/themes/nord.yaml" >> "$color_cache"
        print -n "'" >> "$color_cache"
    fi
    source "$color_cache"
    unset color_cache
fi

# does pretty much what it says
# does not complete inside quotes (duh)
function __complete_galias {
    if [[ -n "$PREFIX" && -z "$QIPREFIX" ]]; then
        local expl
        _description aliases expl 'alias'
        compadd "${expl[@]}" -- ${(M)${(k)galiases}:#$PREFIX*}
    fi
    return 1
}

#completion opts
zstyle ':completion:*' completer __complete_galias _complete _expand _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} "ma=100;94"
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select=30
zstyle ':completion:*' select-prompt"%B%F{cyan}%S %l%s%f%b"
zstyle ':completion:*' list-prompt "%B%F{cyan}%S %l%s%f%b"
zstyle ':completion:*' verbose false
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals:*'  insert-sections   true


autoload -Uz compinit
# only reload comps after reboot effectively
# to reload after e.g. an update, delete the file
if [[ -f "$ZCACHEDIR/compdump" ]]; then
    compinit -C -d "$ZCACHEDIR/compdump"
else
    compinit -d "$ZCACHEDIR/compdump"
    zcompile "$ZCACHEDIR/compdump"
fi
compdef _files '-redirect-' # for some reason wasnt default


#history
HISTFILE="$XDG_DATA_HOME/zsh/histfile"
HISTSIZE=4000
SAVEHIST=8000

# hashed directories (accessible via ~name)
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


# my own config
source "$ZDOTDIR/functions.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/prompt.zsh"

# syntax highlighting
source "$ZDOTDIR/highlight.zsh"

# zoxide, cache since that saves a subshell
if [[ ! -f "$ZCACHEDIR/zoxide_init.zsh" ]]; then
    zoxide init zsh > "$ZCACHEDIR/zoxide_init.zsh"
fi
source "$ZCACHEDIR/zoxide_init.zsh"

# null: gray; false, true: teal; numbers: magenta; strings: green; array, object separators: gray; keys: blue
export JQ_COLORS="0;90:0;36:0;36:0;35:0;32:0;90:0;90:1;34"

function zvm_after_init {
    source "$ZDOTDIR/pairs.zsh"
}
