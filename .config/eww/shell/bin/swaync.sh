#!/usr/bin/env bash

case $1 in
    listen)
        stdbuf -oL swaync-client -s
        ;;
esac
