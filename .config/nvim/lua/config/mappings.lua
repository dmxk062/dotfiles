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

-- Unmap Unused {{{
map("n", "gQ", "<nop>") -- ex mode is just plain annoying
-- }}}

-- qflist / loclist {{{
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
            col = cursor[2] + 1,
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

-- Snippets {{{
-- move between snippet fields
map({ "n", "s", "i" }, "<M-space>", function() vim.snippet.jump(1) end)
map({ "n", "s", "i" }, "<C-space>", function() vim.snippet.jump(-1) end)
-- }}}

-- Buffers & Windows {{{
local bufleader = "\\"

map("n", "<C-s>", "<cmd>b #<cr>") -- faster altfile, mnemonic: [s]econd

local function get_buf_idx()
    local target
    local count = vim.v.count
    if count == 0 then
        target = api.nvim_get_current_buf()
    else
        target = Bufs_for_idx[count]
    end
    if not target or not api.nvim_buf_is_valid(target) then
        vim.notify("No Buffer " .. count, vim.log.levels.ERROR)
        return
    end

    return target
end

-- go to the buffer given in count
map("n", bufleader .. bufleader, function()
    local target = get_buf_idx()
    if not target then return end

    local win = fn.bufwinid(target)
    if win > 0 then
        api.nvim_set_current_win(win)
        return
    end

    local ok = pcall(api.nvim_set_current_buf, target)
    if not ok then
        vim.cmd.bprevious()
    end
end)


---@param dir config.win.position
---@param opts config.win.opts?
local function open_buf_in(dir, opts)
    local target = get_buf_idx()
    if not target then return end

    utils.win_show_buf(target, vim.tbl_extend("force", { position = dir }, opts or {}))
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

-- show a buffer by its index in the statusbar
map("n", bufleader .. "v", function() open_buf_in("vertical") end)
map("n", bufleader .. "s", function() open_buf_in("horizontal") end)
map("n", bufleader .. "V", function() open_buf_in("vertical", { direction = "left" }) end)
map("n", bufleader .. "S", function() open_buf_in("horizontal", { direction = "above" }) end)
map("n", bufleader .. "t", function() open_buf_in("tab") end)
map("n", bufleader .. "f", function() open_buf_in("float") end)
map("n", bufleader .. "a", function() open_buf_in("autosplit") end)

map("n", bufleader .. "d", function()
    local target = get_buf_idx()
    if not target then return end

    api.nvim_buf_delete(target, {})
end)
map("n", bufleader .. "h", function()
    local target = get_buf_idx()
    if not target then return end

    local win = fn.bufwinid(target)
    if win == -1 then
        vim.notify("No open Window for Buffer " .. vim.v.count, vim.log.levels.ERROR)
        return
    end
    api.nvim_win_close(win, false)
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

-- Scratch Buffers {{{
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

map("n", scratchleader .. "<space>", function()
    vim.ui.input({
        prompt = "Scratch",
        completion = "customlist,v:lua.require'config.scratch'.complete"
    }, function(value)
        if not value then
            return
        end

        scratch.open_scratch(value, {
            position = "float"
        })
    end)
end)

map("n", scratchleader .. "s", function()
    local bufname = vim.fn.expand("%:t")
    scratch.open_file_scratch{
        position = "float",
        type = "md"
    }
end)
-- }}}

-- Fix Builtin Mappings {{{
-- stop {} from polluting the jumplist
map(mov, "{", function() return "<cmd>keepj normal!" .. vim.v.count1 .. "{<cr>" end, { remap = false, expr = true })
map(mov, "}", function() return "<cmd>keepj normal!" .. vim.v.count1 .. "}<cr>" end, { remap = false, expr = true })

-- those are hard to reach by default, I do not use Low and High
-- also kinda logical, a stronger version of lh
map(mov, "L", "$")
map(mov, "H", "^")
-- }}}

-- Q to close Windows {{{
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

-- Abbrevs {{{
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

-- Terminal {{{
local terminal = require("config.terminal")
local termleader = "<space>t"
map("n", termleader .. "s", function() terminal.open_term { position = "horizontal" } end)
map("n", termleader .. "v", function() terminal.open_term { position = "vertical" } end)
map("n", termleader .. "x", function() terminal.open_term { position = "replace" } end)
map("n", termleader .. "f", function() terminal.open_term { position = "float" } end)
map("n", termleader .. "a", function() terminal.open_term { position = "autosplit" } end)

-- lf, integrates nicely by calling nvr when it needs to open stuff
map("n", termleader .. "l", function() terminal.open_term { position = "vertical", cmd = { "lf" } } end)
map("n", termleader .. "L", function() terminal.open_term { position = "horizontal", cmd = { "lf" } } end)

-- various other useful programs, capital letter means regular split, lower case vsplit
map("n", termleader .. "p", function()
    terminal.open_term {
        position = "vertical",
        cmd = { "python" },
        title = "python"
    }
end)
map("n", termleader .. "P", function()
    terminal.open_term {
        position = "horizontal",
        cmd = { "python" },
        title = "python"
    }
end)
map("n", termleader .. "q", function()
    terminal.open_term {
        position = "vertical",
        cmd = { "qalc" },
        title = "qalc",
        size = { 60, 20 },
    }
end)
map("n", termleader .. "Q", function()
    terminal.open_term {
        position = "horizontal",
        cmd = { "qalc" },
        title = "qalc",
        size = { 10, 20 },
    }
end)

-- exit terminal mode with a single chord instead of 2
map("t", "<M-Esc>", "<C-\\><C-n>")
map("t", "<C-w>", "<C-\\><C-n><C-w>")
-- }}}

-- Insert Mode {{{
-- useful in insert mode, especially with lshift and rshift as bs and del
map("i", "<C-BS>", "<C-w>")
map("i", "<C-Del>", "<esc>\"_cw")
-- }}}

-- Diagnostics {{{
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

-- Additional Textobjects {{{
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
this uses shiftwidth, so it's not 100% reliable ]]
map(obj, "ii", textobjs.indent_inner)
map(obj, "ai", textobjs.indent_outer)
map(obj, "aI", textobjs.indent_outer_with_last)

map(obj, "iz", textobjs.foldmarker_inner)
map(obj, "az", textobjs.foldmarker_outer)

-- operand to arithmetic
map(obj, "io", textobjs.create_pattern_obj("([-+*/%%]%s*)[%w_%.]+()"))
map(obj, "ao", textobjs.create_pattern_obj("()[-+*/%%]%s*[%w_%.]+()"))

-- snake_case or kebab-case word
map(obj, "i_", textobjs.create_pattern_obj("([-_]?)%w+([-_]?)"))
map(obj, "a_", textobjs.create_pattern_obj("()[-_]?%w+[-_]?()"))

-- select the entire buffer
map(obj, "gG", textobjs.entire_buffer)
-- }}}

-- Evaluate Lua {{{
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

-- Evaluate Math (qalc) {{{
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

-- Sort Region {{{
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

    local no_whiteonly = vim.tbl_filter(function(v)
        return not v:match("^%s*$")
    end, split)

    local to_sort = {}
    local init_white = {}
    local post_white = {}
    for i, val in ipairs(no_whiteonly) do
        init_white[i], to_sort[i], post_white[i] = val:match("^(%s*)(.-)(%s*)$")
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
        table.insert(sorted, init_white[i] .. val .. post_white[i])
    end

    local output
    if mode == "char" then
        output = { table.concat(sorted, ",") }
    else
        output = sorted
    end

    return output, region[1], region[2]
end)
-- }}}

-- Command in Region {{{
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

-- Edit Region in Split {{{
local region_edit_hlns = api.nvim_create_namespace("region_edit")

-- edit a region of a file in a new window and bufferview
-- changes will be synced on write
operators.map_function("<C-w>e", function(mode, region, extra, get)
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
-- }}}

--[[ Change Directory {{{
Sometimes I need a quicker way to change dir than :cd, :lcd etc
This may benefit from being turned into a sub mode sometime
]]
local cdleader = "<space>."

local function get_cur_buf_parent()
    local path = fn.expand("%:h"):gsub("^oil://", "")
    return path
end

-- goto parent
map("n", cdleader .. "h", function()
    local dir = fn.getcwd(0, 0)
    vim.cmd.lcd(fn.fnamemodify(dir, ":h"))
end)

-- go one element right in current files path
map("n", cdleader .. "l", function()
    local dir = fn.getcwd(0, 0)
    local fpath = get_cur_buf_parent()
    if fpath ~= dir then
        local sdir = vim.split(dir, "/")
        local spath = vim.split(fpath, "/")

        local elem = 1
        while elem <= #sdir and elem <= #spath and sdir[elem] == spath[elem] do
            elem = elem + 1
        end

        vim.cmd.lcd(spath[elem])
    end
end)

-- go to current files dir
map("n", cdleader .. "c", function()
    vim.cmd.lcd(get_cur_buf_parent())
end)

-- go to a root
map("n", cdleader .. "r", function()
    local root = vim.fs.root(fn.getcwd(0, 0), { ".git", ".luarc.json", "Makefile" })
    if root then
        vim.cmd.lcd(root)
    end
end)
-- }}}
