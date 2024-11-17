local utils = require("utils")
local abbrev = utils.abbrev
local map = utils.map

-- less annoying way to exit terminal mode
map("t", "<S-Esc>", "<C-\\><C-n>")

-- for some reason smth else remaps those
map("i", "<M-k>", "<esc>k")
map("i", "<M-j>", "<esc>j")

map({ "n", "x", "o" }, "]q", "<cmd>cnext<cr>")
map({ "n", "x", "o" }, "[q", "<cmd>cprev<cr>")

local tableader = "\\"

-- tabs 1 - 9
for i = 1, 9 do
    map("n", tableader .. i, i .. "gt", { silent = true })
end

map("n", tableader .. "h", "<cmd>tabprevious<cr>")
map("n", tableader .. "l", "<cmd>tabnext<cr>")

map("n", tableader .. "t", ":tabnew ")
map("n", tableader .. "v", ":vsp ")
map("n", tableader .. "s", ":sp ")

-- stop {} from polluting the jumplist
map({ "x", "o", "n" }, "{", function() return "<cmd>keepj normal!" .. vim.v.count1 .. "{<cr>" end,
    { remap = false, expr = true })
map({ "x", "o", "n" }, "}", function() return "<cmd>keepj normal!" .. vim.v.count1 .. "}<cr>" end,
    { remap = false, expr = true })

-- use <space>q for macros instead, i dont use them that often
map("n", "<space>q", "q")

-- faster to exit
map("n", "q", "<cmd>q<CR>")
abbrev("c", "Q", "q!")

-- shortcuts to enable/disable spelling
abbrev("c", "spen", "setlocal spell spelllang=en_us")
abbrev("c", "spde", "setlocal spell spelllang=de_at")
abbrev("c", "spoff", "setlocal spell& spelllang&")

-- open a shell in a kitty window of some kind
-- works even for remote oil buffers via ssh
local shellleader = "<space>s"
map("n", shellleader .. "w", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "window") end)
map("n", shellleader .. "v",
    function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "window", { location = "vsplit" }) end)
map("n", shellleader .. "s",
    function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "window", { location = "hsplit" }) end)
map("n", shellleader .. "W", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "os-window") end)
map("n", shellleader .. "t", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "tab") end)
map("n", shellleader .. "o", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "overlay") end)

-- exit terminal mode with a single chord instead of 2
map("t", "<C-Esc>", "<C-\\><C-n>")

-- useful in insert mode, especially with lshift and rshift as bs and del
map("i", "<C-BS>", "<C-w>")
map("i", "<C-Del>", "<esc>\"_cw")

-- my own custom textobjects
local textobjs = require("textobjs")

map({ "x", "o" }, "ae", textobjs.entire_buffer)

-- these work with all diagnostics
map("n", "<space>d", vim.diagnostic.open_float)
map("n", "<space>Dc", function() vim.diagnostic.setqflist() end)
map("n", "<space>Dl", function() vim.diagnostic.setloclist() end)
map({ "x", "o" }, "id", textobjs.diagnostic)
map({ "x", "o" }, "iDe", textobjs.diagnostic_error)
map({ "x", "o" }, "iDw", textobjs.diagnostic_warn)
map({ "x", "o" }, "iDi", textobjs.diagnostic_info)
map({ "x", "o" }, "iDh", textobjs.diagnostic_hint)


-- indents, very useful for e.g. python
-- skips lines with spaces and tries to generally be as simple to use as possible
-- a includes one line above and below
map({ "x", "o" }, "ii", textobjs.indent_inner)
map({ "x", "o" }, "ai", textobjs.indent_outer)

local operators = require("operators")

-- evaluate lua and insert result in buffer
operators.map_function("<space>el", function(mode, region, extra, get)
    local code = get()
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
operators.map_function("<space>eq", function(mode, region, extra, get)
    local expressions = get()
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
operators.map_function("g=", function(mode, region, extra, get)
    local split
    if mode == "char" then
        local content = table.concat(get(), "")
        split = vim.split(content, ",")
    else
        split = get()
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
-- allows me to repeat commands like theyre regular mappings
operators.map_function("g:", function(mode, region, extra, get)
    if extra.repeated then
        vim.cmd(string.format("%d,%d%s", region[1][1], region[2][1], extra.saved.cmd))
    else
        local cmdstr = string.format(":%d,%d", region[1][1], region[2][1])
        vim.api.nvim_feedkeys(cmdstr, "n", false)

        vim.api.nvim_create_autocmd("CmdlineLeave", {
            once = true,
            callback = function()
                local command_line = vim.fn.getcmdline()
                local command = command_line:match("^%d+,%d+(.*)$")
                if not command then
                    command = ""
                end
                extra.saved.cmd = command
            end
        })
    end
    return nil
end)
