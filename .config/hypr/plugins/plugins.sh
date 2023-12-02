#!/usr/bin/env bash
PLUGDIR="$XDG_CONFIG_HOME/hypr/plugins"

mode="$1"
plugin="$2"


load(){
    hyprctl plugin load "${PLUGDIR}/${1}.so" > /dev/null
}
unload(){
    hyprctl plugin unload "${PLUGDIR}/${1}.so" > /dev/null
}
plugin_loaded(){
    hyprctl plugin list| grep -q "$1" > /dev/null
}
case $mode in
    load)
        load "$plugin"
        ;;
    unload)
        unload "$plugin"
        ;;
    reload)
        if plugin_loaded "$plugin"
        then
            unload "$plugin"
            hyprctl plugin load "${PLUGDIR}/${plugin}.so"
        else
            echo "Plugin ${plugin} is not loaded"
        fi
        ;;
    toggle)
        if plugin_loaded "$plugin"
        then
            unload "$plugin"
            exit 1
        else
            load "$plugin"
            exit 
        fi
        ;;
esac
        
