#!/usr/bin/env python

import os
import re
import i3ipc
import json

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

REGEX_NAMES = [
    ("^Minecraft.*", "minecraft"),
    ("^nv:.*", "neovim"),
]

CLASS_OVERRIDES = {
    "zenity": "dialog-info",
    "nm-connection-editor": "networkmanager",
}

def get_icon(icon_name, size=48, fallback="window-manager"):
    if not icon_name:
        icon_name = fallback
    icon_theme = Gtk.IconTheme.get_default()
    icon = icon_theme.lookup_icon(icon_name, size, 0)
    if icon:
        return icon.get_filename()
    else:
        return get_icon(None)

def get_for_ws(workspace: i3ipc.Con, output):
    on_ws = []
    for w in workspace.descendants():
        if not w.pid:
            continue
        app_id = (w.app_id or w.window_class or None)
        app_id = CLASS_OVERRIDES.get(app_id, app_id)

        # overrides
        for override in REGEX_NAMES:
            if re.match(override[0], w.name):
                app_id = override[1]

        # past this point, we have no clue
        # give smth that at least helps us a bit
        if not app_id:
            if w.window_instance:
                app_id = "xorg"
            else:
                app_id = "wayland"

        rect = {
            "x": 0,
            "y": 0,
            "width": 0,
            "height": 0
        }

        width_scale = 1920 / output.rect.width
        height_scale = 1080 / output.rect.height

        rect["x"] = (w.rect.x - output.rect.x) * width_scale
        rect["y"] = (w.rect.y - output.rect.y) * height_scale

        rect["width"] = w.rect.width * width_scale
        rect["height"] = w.rect.height * height_scale

        on_ws.append({
            "float": w.type == "floating_con",
            "app_id": app_id,
            "id": w.id,
            "name": w.name,
            "pid": w.pid,
            "focused": w.focused,
            "rect": rect,
            "icon": get_icon(app_id)
        })
    return sorted(on_ws, key=lambda w: w["float"])

def sort_by_name(ws):
    name = ws["ws"]
    if name[0] == "s":
        return int(name[1:]) - 1000
    else:
        return int(name)

def update(i3, e):
    root = i3.get_tree()
    
    workspaces = []
    for output in root.nodes:
        if output.name == "__i3":
            continue

        for workspace in output.nodes:
            workspaces.append({
                    "wins": get_for_ws(workspace, output),
                    "focused": workspace.focused,
                    "wsnum": workspace.num,
                    "ws": workspace.name
            })

    sorted_ws = sorted(workspaces, key=sort_by_name)

    if len(sorted_ws[-1]["wins"]) != 0:
        sorted_ws.append({
            "wins": [],
            "focused": False,
            "wsnum": sorted_ws[-1]["wsnum"]+1,
            "ws": str(sorted_ws[-1]["wsnum"]+1),
        })

    print(json.dumps(sorted_ws), flush=True)

if __name__ == "__main__":
    i3 = i3ipc.Connection()
    update(i3, None)
    i3.on(i3ipc.Event.WINDOW, update)
    i3.on(i3ipc.Event.WORKSPACE_FOCUS, update)
    i3.main()
