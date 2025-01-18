#!/usr/bin/env sh

pactl --format=json list "$1" | jq -c 'map({
    index: .index,
    id: .name,
    name: .description,
    port: .active_port,
    ports: .ports | [.[] | select(.availability == "available")] | map({
	id: .name,
	name: .description
    })
})'
