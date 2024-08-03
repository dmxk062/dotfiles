#!/usr/bin/env bash

DEEPL_URL="https://api-free.deepl.com/v2"
declare -A LANGUAGE_NAMES=(
[EN]="English"
[ZH]="Chinese"
[DE]="German"
[BG]="Bulgarian"
[CS]="Czech"
[DA]="Danish"
[EL]="Greek"
[EN_GB]="English (UK)"
[EN_US]="English (US)"
[ES]="Spanish"
[ET]="Estonian"
[FI]="Finnish"
[FR]="French"
[HU]="Hungarian"
[ID]="Indonesian"
[IT]="Italian"
[JA]="Japanese"
[KO]="Korean"
[LT]="Lithuanian"
[LV]="Latvian"
[NB]="Norwegian"
[NL]="Dutch"
[PL]="Polish"
[PT_BR]="Portuguese (Brazil)"
[PT_PT]="Portuguese (Europe)"
[RO]="Romanian"
[RU]="Russian"
[SK]="Slovak"
[SL]="Slovenian"
[SV]="Swedish"
[TR]="Turkish"
[UK]="Ukrainian"
)


deepl_request() {
    local request_json="$1"
    local auth_key="$( < "$XDG_DATA_HOME/keys/deepl")"
    if [[ -z "$auth_key" ]]; then
        echo ""
        return 1
    fi

    curl -s --request POST \
        --header "Authorization: DeepL-Auth-Key $auth_key" \
        --header "Content-Type: application/json" \
        --data "$request_json" \
        "$DEEPL_URL/translate"
}

translate() {
    local target="${1:-EN}"
    local origin="${2}"
    local buffer="" line

    while read -r line; do
        buffer+="$line"
    done

    buffer="$(echo "$buffer"|jq -Rs .)"

    local request_body
    if [[ -n "$origin" ]]; then
        request_body='{"text":['"$buffer"'],"target_lang":"'"$target"'","source_lang":"'"$origin"'"}'
    else
        request_body='{"text":['"$buffer"'],"target_lang":"'"$target"'"}'
    fi

    deepl_request "$request_body"|jq -r '.translations.[0]|"\(.detected_source_language)\t\(.text)"'
}

display_translation() {
    local origin="$1" target="$2" text="$3"
    local response="$(notify-send "$origin to $target" -i "translator" -a "EWW" \
        --action="copy"="Copy to Clipboard"\
        --action="edit"="Edit Translation"\
        -- "$text")"

    case "$response" in
        (copy) echo "$text"|wl-copy;;
        (edit)
            tmp="$(mktemp --suffix=".txt")"
            echo "$text" > "$tmp"
            xdg-open "$tmp"
            ;;
    esac
}

eww -c "$XDG_CONFIG_HOME/eww/shell" close rc_popup
case "$1" in
    (selection) 
        target="$2"
        clip="$(wl-paste -p)"
        if [[ -z "$clip" ]]; then
            exit
        fi
        IFS=$'\t' read -r lang text < <(translate "$target" "$3" <<< "$clip")
        if [[ "$text" == "null" ]]; then
            exit
        fi
        if [[ "$target" == "$lang" ]]; then
            notify-send "Text was already in ${LANGUAGE_NAMES[$target]}" -i "translator" -a "EWW"
        else
            display_translation "${LANGUAGE_NAMES[$lang]}" "${LANGUAGE_NAMES[$target]}" "$text"
        fi
        ;;
esac
