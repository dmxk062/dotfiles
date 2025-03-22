--[[ Rationale {{{
    Modes are simple overlays for editing files that (neo)vim is otherwise not very good at editing,
    e.g. binary files
    This module allows for that by wrapping those buffers in smth that is essentially a more capable
    ftplugin
}}} ]]


local M = {}

---@param buf integer
---@param magic table<string, string>
---@return string? magic name of magic found or nothing
local function buf_match_magic(buf, max_length, magic)
    local ch = vim.api.nvim_buf_get_text(buf, 0, 0, 0, max_length, {})[1]
    for name, bytes in pairs(magic) do
        if vim.startswith(ch, bytes) then
            return name
        end
    end

    return nil
end

-- magic numbers for which to use xxd
M.binary_magic_numbers = {
    ELF = "\x7fELF",
}

vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function(ev)
        if buf_match_magic(ev.buf, 10, M.binary_magic_numbers) then
            require("config.modes.xxd").attach(ev.buf)
        end
    end
})

local modes = {
    "xxd"
}

vim.api.nvim_create_user_command("Mode", function(args)
    if not vim.tbl_contains(modes, args.args) then
        vim.notify("No such mode: " .. args.args)
        return
    end

    require("config.modes." .. args.args).attach(vim.api.nvim_get_current_buf(), args)
end, {
    nargs = 1,
    complete = function()
        return modes
    end
})

return M
