local utils = require("utils")
local abbrev = utils.abbrev
local map = utils.map

-- textobjects
local obj = { "x", "o" }
-- motion
local mov = { "n", "x", "o" }

-- less annoying way to exit terminal mode
map("t", "<S-Esc>", "<C-\\><C-n>")

map(mov, "<space>j", "<cmd>cnext<cr>")
map(mov, "<space>k", "<cmd>cprev<cr>")
map(mov, "<space>n", "<cmd>lnext<cr>")
map(mov, "<space>N", "<cmd>lprev<cr>")

map("n", "<space>q", function() require("quicker").toggle() end)
map("n", "<space>l", function() require("quicker").toggle { loclist = true } end)

map({ "n", "s" }, "<M-space>", function() vim.snippet.jump(1) end)
map({ "n", "s" }, "<C-space>", function() vim.snippet.jump(-1) end)

-- buffer mappings
local bufleader = "\\"

map("n", bufleader .. "l", "<cmd>bnext<cr>")
map("n", bufleader .. "h", "<cmd>bprev<cr>")

map("n", bufleader .. bufleader, function()
    local target = Bufs_for_idx[vim.v.count] or 0
    if target == 0 then
        vim.cmd("wincmd ")
        return
    end
    for _, win in pairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == target then
            vim.api.nvim_set_current_win(win)
            return
        end
    end

    local ok = pcall(vim.api.nvim_set_current_buf, target)
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
        target = vim.api.nvim_get_current_buf()
    else
        target = Bufs_for_idx[count]
    end
    if not target then
        target = vim.api.nvim_get_current_buf()
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
    local max_width = vim.api.nvim_win_get_width(0)
    local max_height = vim.api.nvim_win_get_height(0)

    local height = math.floor((max_height) * .8)
    local width = math.floor((max_width) * .8)
    vim.api.nvim_open_win(target, true, {
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
    vim.api.nvim_buf_delete(target, {})
    vim.api.nvim__redraw { tabline = true }
end)

map("n", "gt", function() indexed_tab_command("norm! gt") end)
map("n", bufleader .. "<cr>", function() indexed_tab_command("norm! gt") end)
map("n", bufleader .. "D", function() indexed_tab_command("tabclose") end)
-- clear hidden buffers
map("n", bufleader .. "C", function()
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[b].buflisted and vim.bo[b].buftype == "" and vim.fn.bufwinid(b) == -1 then
            vim.api.nvim_buf_delete(b, {})
        end
    end
end)


-- my own mark handling
local marks = require("modules.marks")
map("n", "<space>m", marks.marks_popup)
map("n", "m<space>", marks.set_first_avail_lmark)
map("n", "m_", marks.set_first_avail_gmark)
-- make mark work across all open buffers
map("n", "'", marks.jump_first_set_mark)

-- stop {} from polluting the jumplist
map(mov, "{", function() return "<cmd>keepj normal!" .. vim.v.count1 .. "{<cr>" end, { remap = false, expr = true })
map(mov, "}", function() return "<cmd>keepj normal!" .. vim.v.count1 .. "}<cr>" end, { remap = false, expr = true })

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
    if #vim.api.nvim_list_wins() > 1 then
        vim.cmd.quit()
    else
        vim.cmd.bnext()
    end
end)
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

-- select the entire buffer
map(obj, "gG", textobjs.entire_buffer)

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
    elseif type(return_val) == "string" then
        result = vim.split(return_val, "\n")
    else
        result = { tostring(return_val) }
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
