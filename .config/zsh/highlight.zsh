typeset -A ZSH_HIGHLIGHT_STYLES=(
    unknown-token 'fg=red,underline'
    reserved-word 'fg=cyan'
    alias 'fg=fg'
    suffix-alias 'fg=fg'
    global-alias 'fg=fg'
    builtin 'fg=fg'
    function 'fg=cyan'
    command 'fg=fg'
    precommand 'fg=blue'
    commandseparator "fg=8"
    hashed-command 'fg=fg'
    autodirectory 'fg=blue,underlined'
    path 'fg=cyan'
    path_pathseparator 'fg=cyan'
    path_prefix 'fg=blue'
    globbing 'fg=yellow'
    history-expansion 'fg=yellow'
    command-substitution 'fg=fg'
    command-substitution-unquoted 'fg=fg'
    command-substitution-quoted 'fg=fg'
    command-substitution-delimiter 'fg=yellow'
    command-substitution-delimiter-unquoted 'fg=yellow'
    command-substitution-delimiter-quoted 'fg=yellow'
    process-substitution 'fg=fg'
    process-substitution-delimiter 'fg=yellow'
    arithmetic-expansion 'fg=blue'
    single-hyphen-option 'fg=blue'
    double-hyphen-option 'fg=magenta'
    back-quoted-argument 'fg=fg'
    back-quoted-argument-unclosed 'fg=red,underline'
    back-quoted-argument-delimiter 'fg=blue'
    single-quoted-argument 'fg=green'
    single-quoted-argument-unclosed 'fg=green'
    double-quoted-argument 'fg=green'
    double-quoted-argument-unclosed 'fg=green'
    dollar-quoted-argument 'fg=yellow'
    dollar-quoted-argument-unclosed 'fg=yellow'
    dollar-double-quoted-argument 'fg=yellow'
    back-double-quoted-argument 'fg=yellow'
    back-dollar-quoted-argument 'fg=yellow'
    assign 'fg=yellow'
    redirection 'fg=magenta'
    comment 'fg=fg'
    named-fd 'fg=blue'
    numeric-fd 'fg=magenta'
    arg0 'fg=fg'
    default 'fg=fg'
    bracket-level-1 'fg=fg'
    bracket-level-2 'fg=fg'
    bracket-level-3 'fg=fg'
    bracket-level-4 'fg=fg'
    bracket-level-5 'fg=fg'
    bracket-level-6 'fg=fg'
    cursor-matchingbracket "bold,bg=8,fg=magenta"
)
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
