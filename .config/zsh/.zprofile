#
# ~/.zsh_profile
#
#GTK_THEME="Orchis-Teal"
export GTK_THEME="Orchis-Teal-Dark-Nord"
#GTK_THEME="Jasper-Dark-Nord"
export BAT_THEME="Nord"
export VISUAL="nvim"
export EDITOR="nvim"
export PAGER="bat"
export npm_config_prefix="$HOME/.local"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
PATH=$PATH:/home/dmx/.config/scripts/:$HOME/.local/bin/:$HOME/.cargo/bin/
export MOZ_ENABLE_WAYLAND=1      
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#e5e9f0,bg:#3b4252,hl:#81a1c1
    --color=fg+:#e5e9f0,bg+:#3b4252,hl+:#81a1c1
    --color=info:#eacb8a,prompt:#bf6069,pointer:#b48dac
    --color=marker:#a3be8b,spinner:#b48dac,header:#a3be8b'
exec $ZDOTDIR/run_session.sh
