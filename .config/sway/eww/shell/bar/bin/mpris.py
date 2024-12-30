#!/usr/bin/env python
import json
import sys

import gi

gi.require_version("Playerctl", "2.0")

from gi.repository import GLib, Playerctl

PLAYER_POSITIONS = {}

def get_timestamp(mseconds):
    minutes, seconds = divmod(mseconds / 1000000, 60)
    return f"{minutes:.0f}:{seconds:02.0f}"

def do_meta(pl, meta, *_):
    out = {}

    name = pl.props.player_name
    out["has_player"] = True
    out["player"] = name or None
    out["playing"] = pl.props.status == "Playing"
    position = PLAYER_POSITIONS.get(pl, 0)
    length = meta["mpris:length"]
    if (length and position):
        out["has_progress"] = True
        out["nice_time"] = get_timestamp(position) + "/" + get_timestamp(length) 
    else:
        out["has_progress"] = False

    artists = meta["xesam:artist"]
    num_artists = len(artists)
    if num_artists == 0:
        artist = None
    elif num_artists == 1:
        artist = artists[0]
    elif num_artists == 2:
        artist = "&".join(artists)
    else:
        artist = "&".join([",".join(artists[:-1]), artists[-1]])
    out["artist"] = artist
    out["album"] = meta["xesam:album"]
    out["title"] = meta["xesam:title"]

    nice_title = ""
    if artist and artist != "":
        nice_title += artist
    if out["album"]:
        nice_title += ", " + out["album"]
    if out["title"]:
        nice_title += " - " + out["title"]

    out["nice_title"] = nice_title

    sys.stdout.write(json.dumps(out) + "\n")
    sys.stdout.flush()


def on_play_pause(player, *_):
    do_meta(player, player.props.metadata)

def assert_not_none(man):
    if not len(man.props.player_names):
        sys.stdout.write(json.dumps({"has_player": False, "playing": False}) + "\n")
        sys.stdout.flush()
        return False
    return True

def on_new_or_disappear(man, name):
    if assert_not_none(man):
        init_player(name)


def poll_position():
    for pl in manager.props.players:
        if pl.props.playback_status == Playerctl.PlaybackStatus.PLAYING:
            PLAYER_POSITIONS[pl] = pl.get_position()
            do_meta(pl, pl.props.metadata)
    return True


def init_player(name):
    player = Playerctl.Player.new_from_name(name)
    player.connect("metadata", do_meta, manager)
    player.connect("playback-status::playing", on_play_pause, manager)
    player.connect("playback-status::paused", on_play_pause, manager)
    manager.manage_player(player)


if __name__ == "__main__":
    manager = Playerctl.PlayerManager()
    manager.connect("name-appeared", on_new_or_disappear)
    manager.connect("name-vanished", on_new_or_disappear)

    [init_player(name) for name in manager.props.player_names]

    if assert_not_none(manager):
        player = Playerctl.Player()
        do_meta(player, player.props.metadata)

    GLib.timeout_add_seconds(1.5, poll_position)
    try:
        loop = GLib.MainLoop()
        loop.run()
    except (KeyboardInterrupt, Exception) as e:
        loop.quit()
