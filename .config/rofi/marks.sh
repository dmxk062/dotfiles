#!/usr/bin/env bash

# Bookmark file format {{{
# Each line is a |-separated list of fields which are as follows:
#   - icon-name, defaults to web browser
#   - name: short name
#   - desc: description
#   - value: URL with %s placeholder
# }}}

BOOKMARKS_FILE="$XDG_CONFIG_HOME/rofi/bookmarks.psv"

if ((ROFI_RETV == 0)); then
    echo -en "\0delim\x1f\t\n"
    while IFS="|" read -r icon name desc value; do
        if [[ -z "$icon" ]]; then
            icon="internet-web-browser"
        fi
        printf "%s\n%s\0icon\x1f%s\x1finfo\x1f%s:%s\t" "$name" "$desc" "$icon" "$type" "$value"
    done < "$BOOKMARKS_FILE"
else
    if [[ -n "$ROFI_DATA" ]]; then
        printf -v url "$ROFI_DATA" "$*"
        (launch-or-inside firefox firefox --new-window "$url" >/dev/null 2>&1) &
        disown
        run_in_background firefox "$url"
    else
        IFS=":" read -r type value <<<"$ROFI_INFO"
        printf "\0data\x1f%s\t%s\0icon\x1ffsearch\x1fnonselectable\x1ftrue\t" "$value" "$1"
    fi
fi
