#configures vi mode plugin

declare -A ZSH_COLORS_RGB=(
    ["light-gray"]="#4c566a"
)


function zvm_config() {
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
  ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK  
  ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLOCK  
  ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
  ZVM_MODE_INSERT=true
  ZVM_VI_HIGHLIGHT_BACKGROUND=$ZSH_COLORS_RGB[light-gray]
  zvm_bindkey vicmd "/" history-incremental-search-backward
}
#sources the plugin
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# kitty
if [[ -n "$KITTY_INSTALLATION_DIR" ]]&&[[ "$TERM" == "xterm-kitty" ]]; then
    export KITTY_SHELL_INTEGRATION="no-cursor no-title"
    autoload -Uz -- "$KITTY_INSTALLATION_DIR/shell-integration/zsh/kitty-integration"
    KITTY_SHELL_INTEGRATION_ENABLED=1
    kitty-integration
    unfunction kitty-integration
fi

#completion
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

#fish-like suggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=$ZSH_COLORS_RGB[light-gray],bold"
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

#history
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down
# [[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
# [[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search


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
# only reload comps after reboot effectively
compinit -d "$XDG_CACHE_HOME/zcompdump-$ZSH_VERSION"


#history
HISTFILE=~/.local/share/zsh/histfile
HISTSIZE=4000
SAVEHIST=8000


#cds on path
setopt autocd


#no annoying beeps
unsetopt beep

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
    ["arc"]="$HOME/.avfs"
    ["media"]="/run/media/$USER"
)

for shortcut in ${(k)DIRSHORTCUTS}; do
    hash -d ${shortcut}="${DIRSHORTCUTS[$shortcut]}"
done

unset DIRSHORTCUTS
#------------------------------------------------------------------------------


#autopairing for quotes, brackets etc
source $ZDOTDIR/autopair.zsh
source $ZDOTDIR/variables.zsh
source $ZDOTDIR/functions.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/prompt.zsh
autopair-init

#syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
source "$ZDOTDIR/highlight"


#fzf
export FZF_DEFAULT_OPTS="
--color=fg:#eceff4,fg+:#8fbcbb,bg:#2e3440,bg+:#2e3440,preview-fg:#eceff4,preview-bg:#2e3440,hl:#bf616a,hl+:#bf616a
--color=info:#ebcb8b,border:#4c566a,prompt:#eceff4,pointer:#8fbcbb,marker:#8fbcbb,spinner:#8fbcbb,header:#eceff4"


#zoxide
eval "$(zoxide init zsh)"



export BAT_THEME="Nord"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT='-c'
