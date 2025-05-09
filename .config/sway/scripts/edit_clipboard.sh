#!/usr/bin/env bash
TMPFILE="$XDG_RUNTIME_DIR/clipboard"

MODE=$1
wl-paste $MODE > "$TMPFILE"
kitty "$EDITOR" "$TMPFILE"
wl-copy $MODE < "$TMPFILE"
rm "$TMPFILE"
