ZSH_LOADED_MODULES=""
ZSH_MODULE_DIR="$ZDOTDIR/mods"
ZSH_MODULES=($(for file in "$ZSH_MODULE_DIR/"*; do
    print "${file:t}"
done))

function +mod {
    local module="$1"
    local out="/dev/stderr"

    if [[ "$2" == "silent" ]]; then
        out="/dev/null"
    fi

    if [[ -z "$module" ]]; then
        return
    fi
    
    if ! [[ "$ZSH_MODULES" == *"$module"* ]]; then
        print -P "%B%F{red}Error: Module '$module' not found%f%b" > $out
        return 1
    fi
    
    if [[ "$ZSH_LOADED_MODULES" == *"$module"* ]]; then
        print -P "%B%F{yellow}Warning: Module '$module' is already in use, Reloading" > $out
    fi

    source "$ZSH_MODULE_DIR/$module" "load"
    print -P "%B%F{green}Loaded module '$module'" > $out

    ZSH_LOADED_MODULES+="$module "
}

function -mod {
    local module="$1"
    local out="/dev/stderr"

    if [[ "$2" == "silent" ]]; then
        out="/dev/null"
    fi

    if [[ -z "$module" ]]; then
        return
    fi

    if ! [[ "$ZSH_LOADED_MODULES" == *"$module"* ]]; then
        print -P "%B%F{red}Error: Module '$module' is not loaded%f%b" > $out
        return 1
    fi

    if ! [[ "$ZSH_MODULES" == *"$module"* ]]; then
        print -P "%B%F{red}Error: Module '$module' not found%f%b" > $out
        return 1
    fi

    source "$ZSH_MODULE_DIR/$module" "unload"
    print -P "%B%F{blue}Unloaded module '$module'" > $out

    ZSH_LOADED_MODULES="${ZSH_LOADED_MODULES//"$module "/}"
}

function mods {
    local module
    for module in "${(@)ZSH_MODULES}"; do
        if [[ "$ZSH_LOADED_MODULES" == *"$module"* ]]; then
            print -P -- "%F{green}+$module%f"
        else
            print -P -- "%F{blue}-$module%f"
        fi
    done
}
