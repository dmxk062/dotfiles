local M = {}

local uv = vim.uv
local api = vim.api
local fn = vim.fn

---@class config.scratch.file
---@field win integer?
---@field buf integer
---@field name string
---@field path string
---@field temporary boolean?
---@field del_on_hide boolean?
---@field augroup integer?
---@field data table
---@field ns integer

---@alias config.scratch.position "replace"|"vertical"|"horizontal"|"float"
---@alias config.scratch.openargs {position: config.scratch.position, temporary_file: boolean, del_on_hide: boolean, type: string}

M.scratchdir = fn.stdpath("data") .. "/scratch/"
local ns = api.nvim_create_namespace("config.scratch")

---@type table<string, config.scratch.file>
M.open_scratches = {}

fn.mkdir(M.scratchdir, "p")
local luarc = M.scratchdir .. ".luarc.json"
-- create empty luarc if not there
if not uv.fs_stat(luarc) then
    local f = io.open(luarc, "w")
    assert(f, "Failed to open scratch luarc for writing")
    f:write("{}")
    f:close()
end


---@param split config.scratch.position
---@param scratch config.scratch.file
local function open_scratch_in_win(split, scratch)
    if split == "replace" then
        scratch.win = api.nvim_get_current_win()
        api.nvim_set_current_buf(scratch.buf)
    elseif split == "float" then
        local w = vim.o.columns
        local h = vim.o.lines
        local width = math.floor(w * 0.6)
        local height = math.floor(h * 0.6)
        scratch.win = api.nvim_open_win(scratch.buf, true, {
            relative = "editor",
            border = "rounded",
            width = width,
            height = height,
            col = math.floor((w - width) / 2),
            row = math.floor((h - height) / 2),
        })
    else
        scratch.win = api.nvim_open_win(scratch.buf, true, {
            vertical = split == "vertical"
        })
    end
end

---@param scratch config.scratch.file
local function attach_autocommands(scratch)
    local group = api.nvim_create_augroup("scratch." .. scratch.name, { clear = true })

    local function clear_stuff()
            if scratch.temporary then
                uv.fs_unlink(scratch.path)
            end
            for _, client in ipairs(vim.lsp.get_clients { bufnr = scratch.buf }) do
                vim.lsp.buf_detach_client(scratch.buf, client.id)
            end
            api.nvim_del_augroup_by_id(scratch.augroup)
            M.open_scratches[scratch.name] = nil
    end
    scratch.augroup = group
    api.nvim_create_autocmd("WinClosed", {
        group = group,
        buffer = scratch.buf,
        callback = function()
            if scratch.del_on_hide then
                api.nvim_buf_delete(scratch.buf, { force = false})
                clear_stuff()
            end
            scratch.win = nil
        end
    })
    api.nvim_create_autocmd("BufDelete", {
        group = group,
        buffer = scratch.buf,
        callback = clear_stuff
    })
end

M.ft_options = {}

M.ft_options.lua = require("config.scratch.lua_eval")

---@param scratch config.scratch.file
---@param opts config.scratch.openargs
local function setup_filetype_stuff(scratch, opts)
    local buf = scratch.buf
    local ft = opts.type or vim.bo[buf].ft
    local ftconfig = M.ft_options[ft]
    if not ftconfig then
        return
    end

    local template = ftconfig.template
    if template then
        if api.nvim_buf_line_count(buf) < #template then
            api.nvim_buf_set_lines(buf, 0, #template, false, template)
            vim.bo[buf].modified = false
        end
        api.nvim_win_set_cursor(scratch.win, { #template, 0 })
    end

    local on_changes = ftconfig.on_changes
    if on_changes then
        api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
            buffer = buf,
            group = scratch.augroup,
            callback = function(ev)
                on_changes(scratch, ev)
            end
        })
        on_changes(scratch, nil)
    end

    if ftconfig.on_init then
        ftconfig.on_init(scratch)
    end
end

---@param name string
---@param opts config.scratch.openargs
local function create_and_open_scratch(name, opts)
    local inst = M.open_scratches[name]
    if inst then
        if inst.win then
            api.nvim_set_current_win(inst.win)
        else
            open_scratch_in_win(opts.position, inst)
        end
        return
    end

    local path = M.scratchdir .. name
    local buf = fn.bufadd(path)
    fn.bufload(buf)

    local scratch = {
        name = name,
        path = path,
        buf = buf,
        ns = ns,
    }

    vim.b[buf]._is_scratch = true
    vim.bo[buf].buflisted = true
    M.open_scratches[name] = scratch
    open_scratch_in_win(opts.position, scratch)
    attach_autocommands(scratch)
    setup_filetype_stuff(scratch, opts)

    return scratch
end

---@param name string
---@param opts config.scratch.openargs
function M.open_scratch(name,  opts)
    local scratch = create_and_open_scratch(name, opts)
    if not scratch then
        return
    end
    scratch.del_on_hide = opts.del_on_hide
    scratch.temporary = opts.temporary_file
end

return M
