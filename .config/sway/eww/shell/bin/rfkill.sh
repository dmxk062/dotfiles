#!/bin/sh

upd() {
    rfkill | jq -ncR '[inputs|split("\\s+"; null)|
        select(.[0] == "")|
            {key: .[2], value: (.[4] == "blocked" or .[5] == "blocked")}]|from_entries'
}

upd
rfkill event | while read -r _; do
    upd
done
