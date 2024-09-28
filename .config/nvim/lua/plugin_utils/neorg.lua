local M = {}

-- utilities and rewrites of core neorg components that fit my preferences better

M.hl_ns = vim.api.nvim_create_namespace("neorg-conceals")

local function set_extmark(buf, row_start, col_start, text, hl, extra)
    local opts = {
        virt_text = { { text, hl } },
        virt_text_pos = "overlay",
        end_col = col_start,
        end_row = row_start,
        invalidate = true,
        virt_text_win_col = nil,
        hl_group = nil,
        conceal = nil,
        id = nil,
        hl_eol = nil,
        virt_text_hide = nil,
        hl_mode = "combine",
        virt_lines = nil,
        virt_lines_above = nil,
        virt_lines_leftcol = nil,
        ephemeral = nil,
        right_gravity = nil,
        end_right_gravity = nil,
        priority = nil,
        strict = nil, -- default true
        sign_text = nil,
        sign_hl_group = nil,
        number_hl_group = nil,
        line_hl_group = nil,
        cursorline_hl_group = nil,
        spell = nil,
        ui_watched = nil,
    }

    if extra then
        for k, v in pairs(extra) do
            opts[k] = v
        end
    end

    vim.api.nvim_buf_set_extmark(buf, M.hl_ns, row_start, col_start, opts)
end

local function tbl_reverse(tbl)
    local res = {}
    for i = 1, #tbl do
        res[i] = tbl[#tbl - i + 1]
    end
    return res
end

local function code_to_unichar(code)
    if code <= 0x7f then
        return string.char(code)
    elseif code <= 0x7FF then
        return string.char(
            0xC0 + math.floor(code / 0x40),
            0x80 + (code % 0x40)
        )
    elseif code <= 0xFFFF then
        return string.char(
            0xE0 + math.floor(code / 0x1000),
            0x80 + math.floor((code / 0x40) % 0x40),
            0x80 + (code % 0x40)
        )
    end
end

local function ordered_alphabet(start, num_letters, suffix)
    return function(i)
        local res = {}
        while i > 0 do
            res[#res + 1] = code_to_unichar(start + (i - 1) % num_letters)
            i = math.floor((i - 1) / num_letters)
        end
        return table.concat(tbl_reverse(res)) .. suffix
    end
end

local roman_numeral_table = {
    { 1000, "m" },
    { 900,  "cm" },
    { 500,  "d" },
    { 400,  "cd" },
    { 100,  "c" },
    { 90,   "xc" },
    { 50,   "l" },
    { 40,   "xl" },
    { 10,   "x" },
    { 9,    "ix" },
    { 5,    "v" },
    { 4,    "iv" },
    { 1,    "i" }
}

local function roman_numerals(i)
    local result = {}

    for _, numeral in ipairs(roman_numeral_table) do
        local value = numeral[1]
        local symbol = numeral[2]
        while i >= value do
            result[#result+1] = symbol
            i = i - value
        end
    end

    return table.concat(result)
end

local ordered_icon_formats = {
    numeric = function(i)
        return tostring(i) .. "."
    end,
    latin_lower = ordered_alphabet(string.byte("a"), 26, ")"),
    latin_upper = ordered_alphabet(string.byte("A"), 26, "."),
    greek_lower = ordered_alphabet(0x03b1, 24, ")"),
    greek_upper = ordered_alphabet(0x0391, 24, "."),
    roman_lower = function(i) return roman_numerals(i) .. ")" end,
    roman_upper = function(i) return roman_numerals(i):upper() .. "." end,
}

---@param node TSNode
---@param buf integer
---@return integer
local function get_ordered_index(node, buf)
    local level = vim.treesitter.get_node_text(node, buf):find("%s") - 1
    local header_node = node:parent()

    local sibling = header_node:prev_named_sibling()
    local count = 1

    while sibling and (sibling:type() == header_node:type()) do
        local sibling_level = vim.treesitter.get_node_text(sibling, buf):find("%s") - 1
        if sibling_level < level then
            break
        elseif sibling_level == level then
            count = count + 1
        end
        sibling = sibling:prev_named_sibling()
    end

    return count
end

function M.render_ordered(list)
    ---@param buf integer
    ---@param node TSNode
    return function(_, buf, node)
        local row_start, col_start = node:range()
        local node_text = vim.treesitter.get_node_text(node, buf)
        local len = (node_text:find("%s") or node_text:len() + 1) - 1
        local index = get_ordered_index(node, buf)
        local icon_key = list[len] or list[#list]
        local icon_fun = ordered_icon_formats[icon_key]

        local icon = icon_fun(index)

        local text = (" "):rep(len - 1) .. icon
        local _, first_unicode_end = text:find("[%z\1-\127\194-\244][\128-\191]*", len)

        local hl = "@neorg.lists.ordered.prefix.norg"
        set_extmark(buf, row_start, col_start, text:sub(1, first_unicode_end), hl)
        if vim.fn.strcharlen(text) > len then
            set_extmark(buf, row_start, col_start + len, text:sub(first_unicode_end + 1), hl,
                { virt_text_pos = "inline" })
        end
    end
end

return M
