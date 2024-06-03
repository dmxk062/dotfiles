#!/usr/bin/false
# vim: ft=zsh

# tools and utilities for python


if [[ "$1" == "load" ]] {

# writes a python script with the arguments on the cmdline passed to it and runs it
# path to the script is appended to the $WPY_SCRIPTS global array

function wpy {
    declare -ga WPY_SCRIPTS
    local script

    local function new_script() {
        mkdir -p -- "$XDG_CACHE_HOME/zsh/wpy"
        local script="$(mktemp --tmpdir="$XDG_CACHE_HOME/zsh/wpy" --suffix=".py")"
        echo "#!/usr/bin/env python
import os, sys, shutil, math

" > "$script"
    chmod +x "$script"
    print -- "$script"
    }

    local function edit_script() {
        local script="$1"
        if [[ "$EDITOR" == *"vi"* ]] {
            "$EDITOR" +4 -c "startinsert" -- "$script"
        } else {
            $EDITOR "$script"
        }
    }

    local function run_script() {
        local script="$1"   
        shift
        "$script" "$argv"
    }

    case $1 in 
        (*)
            script="$(new_script)"
            edit_script "$script"
            WPY_SCRIPTS+="$script"
            run_script "$script" "$argv"
            ;;
    esac
}

} elif [[ "$1" == "unload" ]] {

unfunction wpy

}
