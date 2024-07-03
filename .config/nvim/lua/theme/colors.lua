local named_colors = {
    black = "#2E3440",
    dark_gray = "#3B4252",
    gray = "#434C5E",
    light_gray = "#4C566A",
    bright_gray = "#616E88",
    darkest_white = "#D8DEE9",
    darker_white = "#E5E9F0",
    white = "#ECEFF4",
    teal = "#8FBCBB",
    light_cyan = "#88C0D0",
    light_blue = "#81A1C1",
    blue = "#5E81AC",
    red = "#BF616A",
    orange = "#D08770",
    yellow = "#EBCB8B",
    green = "#A3BE8C",
    magenta = "#B48EAD",
}

local dark_palette = {
    bg0 = named_colors.black,
    bg1 = named_colors.dark_gray,
    bg2 = named_colors.gray,
    bg3 = named_colors.light_gray,

    fg0 = named_colors.white,
    fg1 = named_colors.darker_white,
    fg2 = named_colors.darkest_white,

    inverted = named_colors.black,
}

return {
    colors = named_colors,
    palettes = {
        dark = dark_palette
    }
}
