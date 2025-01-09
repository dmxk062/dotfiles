#!/usr/bin/env python

import i3ipc

SPLIT_RATIO = 1.61

def switch_split_direction(i3: i3ipc.Connection, e):
    win = i3.get_tree().find_focused()
    if not win or win.type == "floating_con":
        return

    if win.fullscreen_mode == 1:
        return

    if win.parent.layout == "stacked" or win.parent.layout == "tabbed":
        return

    new_layout = "splitv" if win.rect.height > win.rect.width / SPLIT_RATIO else "splith"
    if new_layout != win.parent.layout:
        i3.command(new_layout)


def main():
    i3 = i3ipc.Connection()
    i3.on(i3ipc.Event.WINDOW, switch_split_direction)
    i3.main()


if __name__ == "__main__":
    main()
