#!/usr/bin/env bash
EWW="$XDG_CONFIG_HOME/sway/eww/shell"

function write_cur {
    if [[ "$(nmcli radio wifi)" != "enabled" ]]; then
        echo '{"powered": false, "connected": false, "ssid": "", "signal": 0, "security": ""}'
        return
    fi

    nmcli -g ACTIVE,SIGNAL,SECURITY,SSID device wifi list | awk -F":" '
    $1 == "yes" {
        printf "{\"powered\": true,\"connected\":true,\"ssid\":\"%s\",\"security\":\"%s\",\"signal\":%s}\n", $4, $3, $2;
        fflush();
        exit 1; 
    }' && echo '{"powered": true,"connected": false,"ssid":"","signal":0,"security":0}'
}

function get_avail {
    eww -c "$EWW" update wifi-searching=true
    nmcli device wifi rescan
    nmcli -g ACTIVE,SIGNAL,SECURITY,SSID device wifi list | while IFS=":" read -r active signal security ssid; do
        if [[ "$active" == "yes" ]]; then
            bactive="true"
        else
            bactive="false"
        fi

        printf '{"connected":%s, "ssid":"%s", "signal":%s, "security":"%s"}' $bactive "$ssid" "$signal" "$security"
    done | jq -s 'map(select(.ssid != ""))|unique_by(.ssid)|sort_by(.signal)|reverse'
    eww -c "$EWW" update wifi-searching=false
}

case "$1" in
    listen) 
        write_cur
	nmcli monitor | while read -r line; do
	    write_cur
	done
        ;;
    list)
        get_avail
        ;;
    upd)
        eww -c "$EWW" update wifis="$(get_avail)"
        ;;
    connect)
	ssid="$2"
	needs_auth="$3"
	eww -c "$EWW" update wifi-connecting=true
	if nmcli connection up "$ssid"; then
	    eww -c "$EWW" update wifi-connecting=false
	    exit 1
	fi

	if [[ -z "$needs_auth" ]]; then
	    if nmcli device wifi connect "$ssid"; then
		eww -c "$EWW" update wifi-connecting=false
		exit 1
	    fi
	fi

	password="$(zenity --password)"
	if ! nmcli device wifi connect "$ssid" password "$password"; then
	    notify-send "Failed to connect" \
		"Failed to connect to $ssid" \
		-i network-wireless-error
	fi
	;;
esac