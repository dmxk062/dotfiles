local utils = require("utils")
local abbrev = utils.abbrev
local map = utils.map
local api = vim.api
-- textobjects
local obj = { "x", "o" }
-- motion
local mov = { "n", "x", "o" }

-- qflist {{{
-- quickly navigate qflist and loclist
map(mov, "<space>j", "<cmd>cnext<cr>")
map(mov, "<space>k", "<cmd>cprev<cr>")
map(mov, "<space>n", "<cmd>lnext<cr>")
map(mov, "<space>N", "<cmd>lprev<cr>")

-- useful for e.g. gO in help buffers
map(mov, "<C-j>", "<cmd>lnext<cr>")
map(mov, "<C-k>", "<cmd>lprev<cr>")

-- add items to qflist and loclist easily
map("n", "+q", function()
    local bufnr = api.nvim_get_current_buf()
    local cursor = api.nvim_win_get_cursor(0)
    local text = api.nvim_buf_get_lines(bufnr, cursor[1] - 1, cursor[1], false)[1]
    vim.fn.setqflist({}, "a", {
        items = { {
            bufnr = bufnr,
            lnum = cursor[1],
            text = text,
            valid = true,
        } }
    })
end)

-- toggle them
map("n", "<space>q", function() require("quicker").toggle() end)
map("n", "<space>l", function() require("quicker").toggle { loclist = true } end)
-- }}}

-- snippets {{{
-- move between snippet fields
map({ "n", "s", "i" }, "<M-space>", function() vim.snippet.jump(1) end)
map({ "n", "s", "i" }, "<C-space>", function() vim.snippet.jump(-1) end)
-- }}}

-- buffers & windows {{{
local bufleader = "\\"

map("n", bufleader .. "l", "<cmd>bnext<cr>")
map("n", bufleader .. "h", "<cmd>bprev<cr>")

-- go to the buffer given in count
map("n", bufleader .. bufleader, function()
    local target = Bufs_for_idx[vim.v.count] or 0
    if target == 0 then
        vim.cmd("wincmd ")
        return
    end
    for _, win in pairs(api.nvim_list_wins()) do
        if api.nvim_win_get_buf(win) == target then
            api.nvim_set_current_win(win)
            return
        end
    end

    local ok = pcall(api.nvim_set_current_buf, target)
    if not ok then
        vim.cmd.bprevious()
    end
end)

-- open buffer in a thing
-- vsplit, split, tab or float
local function open_buf_in(cmd)
    local target
    local count = vim.v.count
    if count == 0 then
        target = api.nvim_get_current_buf()
    else
        target = Bufs_for_idx[count]
    end
    if not target then
        target = api.nvim_get_current_buf()
    end
    vim.cmd(cmd .. " sbuffer " .. target)
end

---run cmd with the effective tab target as an argument
local function indexed_tab_command(cmd)
    local target
    local count = vim.v.count
    if count == 0 then
        target = ""
    else
        target = Tabs_for_idx[count]
    end

    vim.cmd(cmd .. " " .. target)
end

map("n", bufleader .. "v", function() open_buf_in("vert") end)
map("n", bufleader .. "s", function() open_buf_in("hor") end)
map("n", bufleader .. "t", function() open_buf_in("tab") end)
map("n", bufleader .. "f", function()
    local target = Bufs_for_idx[vim.v.count] or 0
    local max_width = api.nvim_win_get_width(0)
    local max_height = api.nvim_win_get_height(0)

    local height = math.floor((max_height) * .8)
    local width = math.floor((max_width) * .8)
    api.nvim_open_win(target, true, {
        relative = "win",
        row = math.floor((max_height - height) / 2),
        col = math.floor((max_width - width) / 2),
        width = width,
        height = height,
        border = "rounded",
    })
end)

map("n", bufleader .. "d", function()
    local target = Bufs_for_idx[vim.v.count] or 0
    api.nvim_buf_delete(target, {})
    api.nvim__redraw { tabline = true }
end)

map("n", "gt", function() indexed_tab_command("norm! gt") end)
map("n", bufleader .. "<cr>", function() indexed_tab_command("norm! gt") end)
map("n", bufleader .. "D", function() indexed_tab_command("tabclose") end)
-- clear hidden buffers
map("n", bufleader .. "C", function()
    for _, b in ipairs(api.nvim_list_bufs()) do
        if vim.bo[b].buflisted and vim.fn.bufwinid(b) == -1 then
            api.nvim_buf_delete(b, {})
        end
    end
end)
-- }}}

-- marks {{{
local marks = require("modules.marks")
map("n", "<space>m", marks.marks_popup)

-- automatically generate mark name
map("n", "m<space>", marks.set_first_avail_lmark)
map("n", "m_", marks.set_first_avail_gmark)

-- make mark work across all open buffers
map("n", "'", marks.jump_first_set_mark)
-- }}}

-- fix builtin mappings {{{
-- stop {} from polluting the jumplist
map(mov, "{", function() return "<cmd>keepj normal!" .. vim.v.count1 .. "{<cr>" end, { remap = false, expr = true })
map(mov, "}", function() return "<cmd>keepj normal!" .. vim.v.count1 .. "}<cr>" end, { remap = false, expr = true })

-- exit terminal mode with a single chord instead of 2
map("t", "<M-Esc>", "<C-\\><C-n>")
map("t", "<C-w>", "<C-\\><C-n><C-w>")

-- those are hard to reach by default, I do not use Low and High, Middle is sometimes useful
-- also kinda logical, a stronger version of lh
map(mov, "L", "$")
map(mov, "H", "^")
-- }}}

-- q to close windows {{{
-- use <space>Q for macros instead, i dont use them that often
-- use reg, defaulting to "q
map("n", "<space>Q", function()
    if vim.fn.reg_recording() ~= "" then
        return "q"
    else
        local reg = vim.v.register
        return "q" .. (reg ~= '"' and reg or "q")
    end
end, { expr = true })

-- faster to close windows and cycle
map("n", "q", function()
    if #api.nvim_list_wins() > 1 then
        vim.cmd.quit()
    else
        vim.cmd.bnext()
    end
end)
-- }}}

-- abbrevs {{{
-- force quit
abbrev("c", "Q", "q!")
-- shortcuts to enable/disable spelling
abbrev("c", "spen", "setlocal spell spelllang=en_us")
abbrev("c", "spde", "setlocal spell spelllang=de_at")
abbrev("c", "spoff", "setlocal spell& spelllang&")

-- I probably never will actually use :file
-- If I need it, i can survive typing the full name
abbrev("c", "f", "find")
-- }}}

-- shells {{{
local kitty_leader = "<space>S"
map("n", kitty_leader .. "w", function() utils.kitty_shell_in { what = "window" } end)
map("n", kitty_leader .. "v", function() utils.kitty_shell_in { what = "window", location = "vsplit" } end)
map("n", kitty_leader .. "s", function() utils.kitty_shell_in { what = "window", location = "hsplit" } end)
map("n", kitty_leader .. "W", function() utils.kitty_shell_in { what = "os-window" } end)
map("n", kitty_leader .. "t", function() utils.kitty_shell_in { what = "tab" } end)
map("n", kitty_leader .. "o", function() utils.kitty_shell_in { what = "overlay" } end)

local shell_leader = "<space>s"
map("n", shell_leader .. "s", function() utils.nvim_term_in() end)
map("n", shell_leader .. "v", function() utils.nvim_term_in { location = "vertical" } end)
map("n", shell_leader .. "x", function() utils.nvim_term_in { location = "horizontal" } end)
map("n", shell_leader .. "t", function() utils.nvim_term_in { location = "tab" } end)

-- }}}

-- insert mode {{{
-- useful in insert mode, especially with lshift and rshift as bs and del
map("i", "<C-BS>", "<C-w>")
map("i", "<C-Del>", "<esc>\"_cw")
-- }}}

-- my own custom textobjects
local textobjs = require("config.textobjs")

-- diagnostics {{{
-- these work with all diagnostics
map("n", "<space>d", vim.diagnostic.open_float)
map("n", "<space>Dq", function() vim.diagnostic.setqflist() end)
map("n", "<space>Dl", function() vim.diagnostic.setloclist() end)

-- target the area of a diagnostic with a textobject
-- <id> matches every type
map(obj, "id", textobjs.diagnostic)
map(obj, "iDe", textobjs.diagnostic_error)
map(obj, "iDw", textobjs.diagnostic_warn)
map(obj, "iDi", textobjs.diagnostic_info)
map(obj, "iDh", textobjs.diagnostic_hint)
-- }}}

-- additional textobjects {{{

-- less annoying to type
map(obj, "iq", [[i"]])
map(obj, "aq", [[a"]])
map(obj, "iQ", [[i']])
map(obj, "aQ", [[a']])

-- indents, very useful for e.g. python or other indent based languages
-- a includes one line above and below,
-- except for filetypes e.g. python where only the above line is included by default
-- aI always includes the last line too, even for python
-- v:count specifies the amount of indent levels around the one at the cursor to select
-- this uses shiftwidth, so it's not 100% reliable
map(obj, "ii", textobjs.indent_inner)
map(obj, "ai", textobjs.indent_outer)
map(obj, "aI", textobjs.indent_outer_with_last)

-- operand to arithmetic
map(obj, "io", textobjs.create_pattern_obj("([-+*/%%]%s*)[%w_%.]+()"))
map(obj, "ao", textobjs.create_pattern_obj("()[-+*/%%]%s*[%w_%.]+()"))

-- snake_case or kebab-case word
map(obj, "i_", textobjs.create_pattern_obj("([-_]?)%w+([-_]?)"))
map(obj, "a_", textobjs.create_pattern_obj("()[-_]?%w+[-_]?()"))

-- select the entire buffer
map(obj, "gG", textobjs.entire_buffer)
-- }}}

-- operators {{{
local operators = require("config.operators")

-- evaluate lua and insert result in buffer
operators.map_function("<space>el", function(mode, region, extra, get)
    local code = get()
    if not code[#code]:match("^%s*return%s+%S+") then
        code[#code] = "return " .. code[#code]
    end
    local exprs = table.concat(code, "\n") .. "\n"
    local func, err = loadstring(exprs)
    if not func then
        vim.notify(err, vim.log.levels.ERROR)
        return
    end

    local ok, return_val = pcall(func)
    local result
    if not ok then
        vim.notify(return_val, vim.log.levels.ERROR)
        return
    end

    print(type(return_val))
    if type(return_val) == "table" then
        local concat = table.concat(return_val, "\n")
        if #concat == 0 then
            result = vim.split(vim.inspect(return_val), "\n")
        else
            result = return_val
        end
    elseif type(return_val) == "nil" then
        return
    elseif type(return_val) == "string" then
        result = vim.split(return_val, "\n")
    else
        result = { tostring(return_val) }
    end

    return result, region[1], region[2]
end)

-- evalute qalculate expression/math and insert result in buffer
operators.map_function("<space>em", function(mode, region, extra, get)
    local expressions = get()
    local last_expr = expressions[#expressions]

    -- convert to decimals by default, unless specified otherwise
    -- makes it nicer for programming languages that probably dont want fractions
    if not last_expr:match("to fraction") then
        expressions[#expressions] = last_expr .. " to decimals"
    end

    local result = vim.system({ "qalc", "-t", "-f", "-" }, {
        stdin = expressions
    }):wait().stdout
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
        api.nvim_feedkeys(
            string.format("<cmd>%d,%d%s<cr>", region[1][1], region[2][1], extra.saved.cmd),
        "nt", false)
    else
        local cmdstr = string.format(":%d,%d", region[1][1], region[2][1])
        api.nvim_feedkeys(cmdstr, "n", false)

        api.nvim_create_autocmd("CmdlineLeave", {
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
-- }}}
