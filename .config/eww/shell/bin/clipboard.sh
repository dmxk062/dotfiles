#!/usr/bin/env bash


wl-paste -w sh -c 'echo $CLIPBOARD_STATE'|while read -r state; do
    case $state in
        nil|clear)
            content_type=""
            content=""
            ;;
        data|sensitive)
            content_type="$(wl-paste -l)"
            if echo "$content_type"|grep -q "image"; then 
                type="image"
                content="$(wl-paste --type=image|sed -e 's/ /\\ /g' -e 's/\n/\\n/g')"
            elif echo "$content_type"|grep -q "text"; then
                type="text"
                content="$(printf "%Q" "$(wl-paste --type=text)")"
            fi
            ;;
    esac
    printf '{
    "data":"%s",
    "type":"%s"
}' "$content" "$type"
done
