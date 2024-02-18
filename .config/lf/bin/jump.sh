#!/usr/bin/env bash

type="$1"


case $type in
    dir)
        selection="$(fd --type directory -aLd 8 | fzf --header="Jump" --preview 'lsd {}')"
        ;;
    files)
        selection="$(fd --type file -aLd 8 | fzf --header="Select file" --preview "$XDG_CONFIG_HOME/lf/bin/pv.sh 'fzf' '{}' ")"
        ;;
    all)
        ;;
esac
