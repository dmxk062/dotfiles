--[[ Information {{{
The built in % is slow, switches modes, and is not really repeatable
This is much nicer while also supporting more node types
}}} ]] --

---@type LazySpec
local M = {
    "andymass/vim-matchup",
    event = { "BufReadPost", "BufNewFile", "FileType" },
}

M.init = function()
    -- easily gets cluttered for e.g. switch statements and returns
    vim.g.matchup_delim_nomids = 1
end

return M
