#!/usr/bin/env python


from kitty.fast_data_types import Screen, get_options
from kitty.tab_bar import (DrawData, ExtraData, TabBarData, as_rgb)
from kitty.utils import color_as_int

import datetime

opts = get_options()
RED: int = as_rgb(color_as_int(opts.color1))
BG: int = as_rgb(color_as_int(opts.tab_bar_background))
BG_ACTIVE: int = as_rgb(color_as_int(opts.active_tab_background))
FG_ACTIVE: int = as_rgb(color_as_int(opts.active_tab_foreground))
BG_INACTIVE: int = as_rgb(color_as_int(opts.inactive_tab_background))
FG_INACTIVE: int = as_rgb(color_as_int(opts.inactive_tab_foreground))
SEP_LEFT=""
SEP_RIGHT=""
BELL="󰂚"
MAX_LEN = 16


def _draw_bubble(screen: Screen, content: str, bg: int, fg: int, index, bold: bool, left=SEP_LEFT, right=SEP_RIGHT):
    if index != 1:
        screen.cursor.x += 1

    fg_i = screen.cursor.bg
    screen.cursor.fg = bg
    screen.cursor.bg = BG
    screen.cursor.bold = bold
    screen.draw(left)
    screen.cursor.fg = fg
    screen.cursor.bg = bg
    screen.draw(content)
    screen.cursor.fg = bg
    screen.cursor.bg = BG
    screen.draw(right)
    screen.cursor.fg = fg_i


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    if len(tab.title) > MAX_LEN:
        fmt = tab.title[:MAX_LEN - 1]
        fmt += "…"
    else:
        fmt = tab.title 

    if tab.is_active:
        fg = FG_ACTIVE
        bg = BG_ACTIVE
        bold = True
        fmt = " " + fmt
    elif tab.needs_attention:
        fg = FG_ACTIVE
        bg = RED
        bold = True
        fmt = "󰵙 " + fmt
    else:
        fg = FG_INACTIVE
        bg = BG_INACTIVE
        bold = False
        if tab.has_activity_since_last_focus:
            fmt = " " + fmt
        else:
            fmt = str(index) + " " + fmt

    _draw_bubble(screen, fmt, bg, fg, index, bold )
    return screen.cursor.x
