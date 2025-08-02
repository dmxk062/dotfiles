#!/bin/sh

wl-paste $1 |
	stdbuf -o 0 espeak --ipa |
	zenity --title="Speaking" --text-info
