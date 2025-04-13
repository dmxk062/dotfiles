#!/usr/bin/env bash

types="$(wl-paste -l$1)"
jq --arg mime "$types" -cMsR '. as $text
|([$mime|split("\n") |map(split("[/;]"; null)|select(.[1]))|unique_by(.[1]).[]|.[0:2]|join("/")]) as $mimes|({
text: $text, mime: $mimes, 
label: ($text | split("\n")|map(select(test("[^\\s]")))[0] // "[Empty]"),
type: (
    if $text == "" then "empty"
    elif $mimes|any(startswith("image/")) then "image"
    elif $mimes|any(. == "application/vnd.portal.files") then "file"
    elif $text|test("^https?://"; null) then "url"
    else "text" end)})'
