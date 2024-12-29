#!/usr/bin/env python
import json
import sys

import gi

gi.require_version("Playerctl", "2.0")

from gi.repository import GLib, Playerctl

PLAYER_POSITIONS = {}


def do_meta(pl, meta, *_):
    out = {}

    name = pl.props.player_name
    out["has_player"] = True
    out["player"] = name or None
    out["playing"] = pl.props.status == "Playing"
    out["position"] = PLAYER_POSITIONS.get(pl, 0)
    out["length"] = meta["mpris:length"]
    out["has_progress"] = bool(out["length"] and out["position"])
    if out["has_progress"]:
        out["progress"] = out["position"] / out["length"]

    artists = meta["xesam:artist"]
    num_artists = len(artists)
    if num_artists == 0:
        out["artist"] = None
    elif num_artists == 1:
        out["artist"] = artists[0]
    elif num_artists == 2:
        out["artist"] = "&".join(artists)
    else:
        out["artist"] = "&".join([",".join(artists[:-1]), artists[-1]])
    out["album"] = meta["xesam:album"]
    out["title"] = meta["xesam:title"]

    sys.stdout.write(json.dumps(out) + "\n")
    sys.stdout.flush()


def on_play_pause(player, *_):
    do_meta(player, player.props.metadata)

def assert_not_none(man):
    if not len(man.props.player_names):
        sys.stdout.write(json.dumps({"has_player": False}) + "\n")
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
