export VISUAL="nvim"
export EDITOR="nvim"
export PAGER="bat -p"
export npm_config_prefix="$HOME/.local"
export MOZ_ENABLE_WAYLAND=1      

path+=("$HOME/.config/zsh/scripts" "$HOME/.local/bin")

eval $(ssh-agent -s) > /dev/null 2>&1
ssh-add "$HOME/.local/share/keys/git" 2>&1
if [[ $(tty) == /dev/tty* ]]
then
    exec $ZDOTDIR/run_session.sh
fi
