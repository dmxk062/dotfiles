---@param col1 string
---@param col2 string
---@param alpha decimal
local function blend(col1, col2, alpha)
    local r1, g1, b1 = tonumber(col1:sub(2, 3), 16), tonumber(col1:sub(4, 5), 16), tonumber(col1:sub(6, 7), 16)
    local r2, g2, b2 = tonumber(col2:sub(2, 3), 16), tonumber(col2:sub(4, 5), 16), tonumber(col2:sub(6, 7), 16)

    local rr = math.floor((r1 * alpha) + (r2 * (1 - alpha)))
    local gr = math.floor((g1 * alpha) + (g2 * (1 - alpha)))
    local br = math.floor((b1 * alpha) + (b2 * (1 - alpha)))

    return string.format("#%02X%02X%02x", rr, gr, br)
end

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
    purple = blend("#B48EAD", "#5E81AC", 0.7),
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

local light_palette = {
    bg0 = named_colors.white,
    bg1 = named_colors.darker_white,
    bg2 = named_colors.darkest_white,
    bg3 = blend(named_colors.bright_gray, named_colors.darkest_white, 0.2),

    fg0 = named_colors.black,
    fg1 = named_colors.dark_gray,
    fg2 = named_colors.bright_gray,

    inverted = named_colors.black,
}

return {
    colors = named_colors,
    palettes = {
        dark = dark_palette,
        light = light_palette,
        default = dark_palette,
    },
    blend = blend,
}
