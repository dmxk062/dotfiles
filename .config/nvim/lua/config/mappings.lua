local utils = require("config.utils")
local abbrev = utils.abbrev
local map = utils.map
local api = vim.api
local fn = vim.fn

-- textobjects
local obj = { "x", "o" }
-- motion
local mov = { "n", "x", "o" }

-- my own custom textobjects
local textobjs = require("config.textobjs")
-- create custom operators easily
local operators = require("config.operators")

-- unmap unused {{{
map("n", "gQ", "<nop>") -- ex mode is just plain annoying
-- }}}

-- qflist {{{
-- quickly navigate qflist and loclist

-- qflist: optimized for larger lists
map(mov, "<space>j", "<cmd>cnext<cr>")
map(mov, "<space>k", "<cmd>cprev<cr>")
map(mov, "<space>0", "<cmd>cfirst<cr>")
map(mov, "<space>$", "<cmd>clast<cr>")

-- loclist: optimized for much smaller lists
map(mov, "<C-j>", "<cmd>lnext<cr>")
map(mov, "<C-k>", "<cmd>lprev<cr>")
map(mov, "<space>L0", "<cmd>lfirst<cr>")
map(mov, "<space>L$", "<cmd>llast<cr>")

-- clear them
map("n", "<space>Qc", function() fn.setqflist({}, "r") end)
map("n", "<space>Lc", function() fn.setloclist(0, {}, "r") end)

-- add current line to list
local function add_qf_item(where)
    local bufnr = api.nvim_get_current_buf()
    local cursor = api.nvim_win_get_cursor(0)
    local text = api.nvim_buf_get_lines(bufnr, cursor[1] - 1, cursor[1], false)[1]

    local listfunc = where == "loclist"
        and function(...) return fn.setloclist(bufnr, ...) end
        or fn.setqflist

    listfunc({}, "a", {
        items = { {
            bufnr = bufnr,
            lnum = cursor[1],
            text = text,
            valid = true,
        } }
    })
end

-- remove entry on current line from list
local function rem_qf_item(where)
    local bufnr = api.nvim_get_current_buf()
    local cursor = api.nvim_win_get_cursor(0)

    local getfn = where == "loclist"
        and function(...) return fn.getloclist(bufnr, ...) end
        or fn.getqflist

    local items = getfn()
    if #items == 0 then
        return
    end

    local new_entries = {}
    local found_to_rm = false
    for i, entry in ipairs(items) do
        if entry.bufnr == bufnr and entry.lnum == cursor[1] then
            found_to_rm = true
        else
            table.insert(new_entries, entry)
        end
    end

    if found_to_rm then
        local setfn = where == "loclist"
            and function(...) return fn.setloclist(bufnr, ...) end
            or fn.setqflist

        setfn({}, "r", { items = new_entries })
    end
end

map("n", "+q", function() add_qf_item() end)
map("n", "+l", function() add_qf_item("loclist") end)

map("n", "-q", function() rem_qf_item() end)
map("n", "-l", function() rem_qf_item("loclist") end)

map("n", "<space>Qr", function() require("quicker").refresh() end)
map("n", "<space>Lr", function() require("quicker").refresh(0) end)

-- toggle them
map("n", "<space>q", function() require("quicker").toggle { min_height = 8 } end)
map("n", "<space>l", function() require("quicker").toggle { min_height = 8, loclist = true } end)
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

---open buffer
---@param cmd "vert"|"hor"|"tab"
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
    local max_width = vim.o.columns
    local max_height = vim.o.lines

    local height = math.floor((max_height) * .6)
    local width = math.floor((max_width) * .6)
    api.nvim_open_win(target, true, {
        relative = "editor",
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
end)

map("n", bufleader .. "<cr>", function() indexed_tab_command("norm! gt") end)
map("n", bufleader .. "<space>", function() indexed_tab_command("norm! gt") end)
map("n", bufleader .. "D", function() indexed_tab_command("tabclose") end)

-- clear hidden buffers
map("n", bufleader .. "C", function()
    for _, b in ipairs(api.nvim_list_bufs()) do
        if vim.bo[b].buflisted and fn.bufwinid(b) == -1 then
            api.nvim_buf_delete(b, {})
        end
    end
end)
-- }}}

-- marks {{{
local marks = require("config.marks")
map("n", "<space>m", marks.marks_popup) -- show all marks in the current context

-- automatically generate mark name
map("n", "m<space>", marks.set_first_avail_lmark)
map("n", "m_", marks.set_first_avail_gmark)

-- make mark work across all open buffers
map("n", "'", marks.jump_first_set_mark)
-- }}}

-- scratch buffers {{{
local scratchleader = "<space>s"
local scratch = require("config.scratch")
map("n", scratchleader .. "l", function()
    scratch.open_scratch("eval", {
        type = "lua",
        del_on_hide = false,
        temporary_file = false,
        position = "float",
    })
end)


map("n", scratchleader .. "w", function()
    scratch.open_scratch("notes.md", {
        type = "md",
        del_on_hide = false,
        temporary_file = false,
        position = "float",
    })
end)
-- }}}

-- fix builtin mappings {{{
-- stop {} from polluting the jumplist
map(mov, "{", function() return "<cmd>keepj normal!" .. vim.v.count1 .. "{<cr>" end, { remap = false, expr = true })
map(mov, "}", function() return "<cmd>keepj normal!" .. vim.v.count1 .. "}<cr>" end, { remap = false, expr = true })

-- exit terminal mode with a single chord instead of 2
map("t", "<M-Esc>", "<C-\\><C-n>")
map("t", "<C-w>", "<C-\\><C-n><C-w>")

-- those are hard to reach by default, I do not use Low and High
-- also kinda logical, a stronger version of lh
map(mov, "L", "$")
map(mov, "H", "^")
-- }}}

-- q to close windows {{{
-- use <C-q> for macros instead, i dont use them that often
-- use reg, defaulting to "q
map("n", "<C-q>", function()
    if fn.reg_recording() ~= "" then
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
abbrev("c", "Qa", "qa!")

-- shortcuts to enable/disable spelling
abbrev("c", "spen", "setlocal spell spelllang=en_us")
abbrev("c", "spde", "setlocal spell spelllang=de_at")
abbrev("c", "spoff", "setlocal nospell spelllang=")

-- I probably never will actually use :file
-- If I need it, i can survive typing the full name
abbrev("c", "f", "find")
-- so useful
abbrev("c", "vf", "vertical sf")
-- }}}

-- shells {{{
local shell_leader = "<space>s"
map("n", shell_leader .. "s", function() utils.nvim_term_in { position = "horizontal" } end)
map("n", shell_leader .. "v", function() utils.nvim_term_in { position = "vertical" } end)
map("n", shell_leader .. "x", function() utils.nvim_term_in { position = "replace" } end)
map("n", shell_leader .. "f", function() utils.nvim_term_in { position = "float" } end)
-- }}}

-- insert mode {{{
-- useful in insert mode, especially with lshift and rshift as bs and del
map("i", "<C-BS>", "<C-w>")
map("i", "<C-Del>", "<esc>\"_cw")
-- }}}

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

--[[ indents, very useful for e.g. python or other indent based languages
a includes one line above and below,
except for filetypes e.g. python where only the above line is included by default
aI always includes the last line too, even for python
v:count specifies the amount of indent levels around the one at the cursor to select
this uses shiftwidth, so it's not 100% reliable --]]
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

-- evaluate lua {{{
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
-- }}}

-- evaluate math (qalc) {{{
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
-- }}}

-- sort region {{{
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
-- }}}

-- command in region {{{
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
                local command_line = fn.getcmdline()
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

-- edit region in split {{{
local region_edit_hlns = api.nvim_create_namespace("region_edit")

-- edit a region of a file in a new window and bufferview
-- changes will be synced on write
operators.map_function("<space>w", function(mode, region, extra, get)
    local lines = get("line")
    local main_buffer = api.nvim_get_current_buf()
    local ft = vim.bo.filetype
    local name = api.nvim_buf_get_name(main_buffer)

    local buffer = api.nvim_create_buf(true, true)
    api.nvim_buf_set_lines(buffer, 0, -1, false, lines)

    vim.bo[buffer].filetype = ft
    vim.bo[buffer].bufhidden = "delete"
    vim.bo[buffer].buftype = "acwrite"
    vim.bo[buffer].modified = false

    api.nvim_buf_set_name(buffer, string.format("%s [%d:%d]", name, region[1][1], region[2][1]))
    vim.b[buffer]._jhk_type = "region"


    local original_region = {
        region[1][1] - 1,
        region[2][1]
    }

    local function highlight_mirrored()
        api.nvim_buf_clear_namespace(main_buffer, region_edit_hlns, 0, -1)
        api.nvim_buf_set_extmark(main_buffer, region_edit_hlns, original_region[1], 0, {
            end_line = original_region[2],
            hl_group = "Visual",
        })
    end

    local augroup = api.nvim_create_augroup("region_edit" .. name .. "#" .. main_buffer, { clear = true })
    api.nvim_create_autocmd("BufWriteCmd", {
        group = augroup,
        buffer = buffer,
        callback = function()
            local text = api.nvim_buf_get_lines(buffer, 0, -1, false)
            api.nvim_buf_set_lines(main_buffer, original_region[1], original_region[2], false, text)
            original_region[2] = original_region[1] + #text
            vim.bo[buffer].modified = false

            highlight_mirrored()
        end
    })

    local function on_close()
        api.nvim_buf_clear_namespace(main_buffer, region_edit_hlns, 0, -1)
        api.nvim_del_augroup_by_id(augroup)
    end

    api.nvim_create_autocmd("BufDelete", {
        group = augroup,
        buffer = buffer,
        callback = on_close
    })

    utils.open_window_smart(buffer, { enter = true })
    highlight_mirrored()
end)
-- }}
