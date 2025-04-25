--[[ Information {{{
Wtf is an overlay?
An overlay is a "mode" that transforms data in a file
to textual data that (neo)vim can work with.

e.g.
- binary files with xxd on read/write
}}} ]]

---@class config.overlay
---@field name string
---@field writeable boolean
---@field detach fun(realbuf: integer, drawbuf: integer)
---@field attach fun(realbuf: integer, drawbuf: integer): boolean
---@field write fun(realbuf: integer, drawbuf: integer): boolean
---@field state table

local M = {}
local api = vim.api

local function attach_to_buf(buf, name, args)
    local overlay = require("config.overlays." .. name)
    local drawbuf = api.nvim_create_buf(true, false)
    api.nvim_set_current_buf(drawbuf)

    local ok = overlay.attach(buf, drawbuf)

    if not ok then
        api.nvim_buf_delete(drawbuf, { force = true })
        return
    end

    vim.b[drawbuf].special_buftype = "overlay"

    -- quit the overlay
    api.nvim_buf_create_user_command(drawbuf, "Oq", function()
        api.nvim_buf_del_user_command(drawbuf, "Oq")
        overlay.detach(buf, drawbuf)
        api.nvim_buf_delete(drawbuf, { force = true })
    end, { desc = "Quit Overlay" })
end

---@param buf integer
---@param magic table<string, string>
---@return string? magic name of magic found or nil
local function buf_match_magic(buf, max_length, magic)
    local ch = api.nvim_buf_get_text(buf, 0, 0, 0, max_length, {})[1]
    for name, bytes in pairs(magic) do
        if vim.startswith(ch, bytes) then
            return name
        end
    end

    return nil
end

-- magic numbers for which to use xxd
M.elf_magic_numbers = {
    ELF = "\x7fELF",
}

api.nvim_create_autocmd("BufReadPost", {
    callback = function(ev)
        if buf_match_magic(ev.buf, 10, M.elf_magic_numbers) then
            attach_to_buf(ev.buf, "objdump")
        end
    end
})

local modes = {
    "xxd",
    "objdump"
}

api.nvim_create_user_command("Overlay", function(args)
    if not vim.tbl_contains(modes, args.args) then
        vim.notify("No such mode: " .. args.args)
        return
    end

    local buf = api.nvim_get_current_buf()
    attach_to_buf(buf, args.args, args)
end, {
    nargs = 1,
    complete = function()
        return modes
    end
})

return M
