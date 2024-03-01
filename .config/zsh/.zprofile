export VISUAL="nvim"
export EDITOR="nvim"
export PAGER="bat"
export npm_config_prefix="$HOME/.local"
export MOZ_ENABLE_WAYLAND=1      
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#e5e9f0,bg:#3b4252,hl:#81a1c1
    --color=fg+:#e5e9f0,bg+:#3b4252,hl+:#81a1c1
    --color=info:#eacb8a,prompt:#bf6069,pointer:#b48dac
    --color=marker:#a3be8b,spinner:#b48dac,header:#a3be8b'


PATH=$PATH:/home/dmx/.config/scripts/:$HOME/.local/bin/:$HOME/.local/share/cargo/bin/

eval $(ssh-agent -s) > /dev/null 2>&1
if [[ $(tty) == /dev/tty* ]]
then
    exec $ZDOTDIR/run_session.sh
fi
