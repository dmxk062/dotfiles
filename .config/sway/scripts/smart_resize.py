#!/usr/bin/env python

"""
Smart window resizing to match the direction

Usage:
    nop resize <left|right|up|down> <amount>
"""

import i3ipc

def get_parent_with_orientation(con: i3ipc.Con, direction: str):
    con = con.parent
    while True:
        parent = con.parent
        if not parent:
            return con
        if parent.orientation == direction:
            return parent

        con = parent

def do_resize(i3: i3ipc.Connection, direction, amount):
    current = i3.get_tree().find_focused()
    parent = get_parent_with_orientation(current, "horizontal" if direction in ("left", "right") else "vertical")

    prect = parent.rect
    rect = current.rect

    is_left = rect.x == prect.x
    is_top = rect.y == prect.y

    if (is_left and direction == "left") or (not is_left and direction == "right"):
        current.command(f"resize shrink width {amount}px")
    elif (is_left and direction == "right") or (not is_left and direction == "left"):
        current.command(f"resize grow width {amount}px")
    elif (is_top and direction == "up") or (not is_top and direction == "down"):
        current.command(f"resize shrink height {amount}px")
    elif (is_top and direction == "down") or (not is_top and direction == "up"):
        current.command(f"resize grow height {amount}px")
    

def on_event(i3, event):
    cmd: str = event.binding.command
    if cmd.startswith("nop resize"):
        do_resize(i3, *(cmd.split(" ")[-2:]))

def main():
    i3 = i3ipc.Connection()
    i3.on(i3ipc.Event.BINDING, on_event)
    i3.main()


if __name__ == "__main__":
    main()
