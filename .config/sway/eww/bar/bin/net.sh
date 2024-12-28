#!/usr/bin/env bash
DEV="$(ip route | grep default | cut -d' ' -f5)"

sar -n DEV 4 --iface="$DEV" | while read -r _ _ ident _ _ recvd sent _; do
    if [[ "$ident" == "$DEV" ]]; then
	nice_sent="$(numfmt --from=iec --to=iec "${sent}K")"
	nice_recvd="$(numfmt --from=iec --to=iec "${recvd}K")"
	printf '{"iface":"%s", "sent":"%s", "received":"%s", "raw_sent":%s, "raw_received": %s}\n' \
	    "$DEV" "$nice_sent" "$nice_recvd" "$sent" "$recvd"
    fi
done
