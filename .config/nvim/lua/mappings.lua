local utils = require("utils")

-- less annoying way to exit terminal mode
utils.map("t", "<S-Esc>", "<C-\\><C-n>")

-- for some reason smth else remaps those
utils.map("i", "<M-k>", "<esc>k")
utils.map("i", "<M-j>", "<esc>j")

-- move visual selection around
utils.map("x", "K", ":m '<-2<cr>gv=gv")
utils.map("x", "J", ":m '>+1<cr>gv=gv")

local tableader = "\\"

-- tabs 1 - 9
for i = 1, 9 do
    utils.map("n", tableader .. i, i .. "gt", { silent = true })
end

utils.map("n", tableader .. "h", "<cmd>tabprevious<cr>")
utils.map("n", tableader .. "l", "<cmd>tabnext<cr>")

utils.map("n", tableader .. "t", ":tabnew ")
utils.map("n", tableader .. "v", ":vsp ")
utils.map("n", tableader .. "s", ":sp ")

-- stop {} from polluting the jumplist
utils.map({ "x", "o", "n" }, "{", function() return "<cmd>keepj normal!" .. vim.v.count1 .. "{<cr>" end, { remap = false, expr = true })
utils.map({ "x", "o", "n" }, "}", function() return "<cmd>keepj normal!" .. vim.v.count1 .. "}<cr>" end, { remap = false, expr = true })

-- use <space>@ for macros instead, i dont use them that often
utils.map("n", "<space>@", "q")

-- faster to exit
utils.map("n", "q", "<cmd>q<CR>")
utils.abbrev("c", "Q", "q!")

-- shortcuts to enable/disable spelling
utils.abbrev("c", "spen", "setlocal spell spelllang=en_us")
utils.abbrev("c", "spde", "setlocal spell spelllang=de_at")
utils.abbrev("c", "spoff", "setlocal spell& spelllang&")

-- open a shell in a kitty window of some kind
-- works even for remote oil buffers via ssh
local shellleader = "<space>s"
utils.map("n", shellleader .. "w", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "window") end)
utils.map("n", shellleader .. "v", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "window", { location = "vsplit" }) end)
utils.map("n", shellleader .. "s", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "window", { location = "hsplit" }) end)
utils.map("n", shellleader .. "W", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "os-window") end)
utils.map("n", shellleader .. "t", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "tab") end)
utils.map("n", shellleader .. "o", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "overlay") end)

-- exit terminal mode with a single chord instead of 2
utils.map("t", "<C-Esc>", "<C-\\><C-n>")

-- my own custom textobjects
local textobjs = require("textobjs")

-- these work with all diagnostics
utils.map("n", "<space>d", vim.diagnostic.open_float)
utils.map({ "x", "o" }, "idd", textobjs.diagnostic)
utils.map({ "x", "o" }, "ide", function() textobjs.diagnostic("error") end)
utils.map({ "x", "o" }, "idw", function() textobjs.diagnostic("warn") end)
utils.map({ "x", "o" }, "idi", function() textobjs.diagnostic("info") end)
utils.map({ "x", "o" }, "idh", function() textobjs.diagnostic("hint") end)


-- indents, very useful for e.g. python
-- skips lines with spaces and tries to generally be as simple to use as possible
-- a includes one line above and below
utils.map({ "x", "o" }, "ii", function() textobjs.indent(false) end)
utils.map({ "x", "o" }, "ai", function() textobjs.indent(true) end)

-- an arbitrary selection on the screen between two points using leap
---@TODO decided whether to remove this
utils.map({ "x", "o" }, "iS", function() textobjs.leap_selection(false) end)
utils.map({ "x", "o" }, "aS", function() textobjs.leap_selection(true) end)

-- Custom Operators {{{
local operators = require("operators")

-- evaluate lua and insert result in buffer
operators.map_function("<space>el", function(mode, region, extra, get_content)
    local code = get_content()
    if not code[#code]:match(".*return%s+%S+") then
        code[#code] = "return " .. code[#code]
    end
    local exprs = table.concat(code, "\n") .. "\n"
    local return_val = loadstring(exprs)()
    local result
    if type(return_val) == "table" or type(return_val) == "userdata" then
        result = vim.split(vim.inspect(return_val), "\n")
    elseif type(return_val) == "nil" then
        result = {}
    else
        result = vim.split(return_val, "\n")
    end

    return result, region[1], region[2]
end)

-- evalute qalculate expression/math and insert result in buffer
operators.map_function("<space>eq", function(mode, region, extra, get_content)
    local expressions = get_content()
    local result = vim.system({ "qalc", "-t", "-f", "-" }, { stdin = expressions }):wait().stdout
    if not result then
        return nil
    end

    local output = vim.split(result, "\n")
    if #(output[#output]) then
        table.remove(output, #output)
    end
    return output, region[1], region[2]
end)

local sort_functions = {
    numeric = function(x, y)
        local xnumeric = x:match("^[+-]?%d*%.?%d+")
        local ynumeric = y:match("^[+-]?%d*%.?%d+")
        -- sort alphabetic
        local xnum = xnumeric and tonumber(xnumeric) or nil
        local ynum = ynumeric and tonumber(ynumeric) or nil
        if (not xnum) and (not ynum) then
            -- fall back to alphabetic comparisons
            return x < y
        end

        -- sort pure text at the end of the list
        return (xnum or math.huge) < (ynum or math.huge)
    end,

    string = function(x, y)
        return x < y
    end
}

-- sort selection/object:
-- charwise: csv
-- linewise: lines
-- preserves indent/spacing
operators.map_function("g=", function(mode, region, extra, get_content)
    local split
    if mode == "char" then
        local content = table.concat(get_content(), "")
        split = vim.split(content, ",")
    else
        split = get_content()
    end

    local to_sort = {}
    local indents = {}
    for i, val in ipairs(split) do
        indents[i], to_sort[i] = val:match("^(%s*)(.-)%s*$")
    end

    local sort_fun
    if to_sort[1]:match("^[+-]?%d*%.?%d+") then
        sort_fun = sort_functions.numeric
    else
        sort_fun = sort_functions.string
    end

    table.sort(to_sort, sort_fun)
    local sorted = {}
    for i, val in ipairs(to_sort) do
        table.insert(sorted, indents[i] .. val)
    end

    local output
    if mode == "char" then
        output = { table.concat(sorted, ", ") }
    else
        output = sorted
    end

    return output, region[1], region[2]
end)

-- open a cmdline in a region specified by a textobject or motion
operators.map_function("g:", function(mode, region, extra, get)
    local cmdstr = string.format(":%d,%d", region[1][1], region[2][1])
    vim.api.nvim_feedkeys(cmdstr, "n", false)
    return nil
end)
-- }}}
