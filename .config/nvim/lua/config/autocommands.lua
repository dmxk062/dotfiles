local autocmd = vim.api.nvim_create_autocmd
local api = vim.api
local utils = require("config.utils")
local ftpref = require("config.ftpref")

-- Window Title {{{
-- change the title in a more intelligent way
autocmd({ "BufEnter", "BufReadPost", "BufNewFile", "VimEnter" }, {
    callback = function(args)
        local name, kind, show_modified = require("config.utils").format_buf_name(api.nvim_get_current_buf(), true)

        vim.o.titlestring = "nv: " .. (name or "[-]")
    end
})
vim.o.titlestring = "nv: NeoVIM" -- set initial
-- }}}

--[[ Mode Based Linenumber {{{
change line number based on mode:
- command mode: make it absolute for ranges etc
- normal mode: keep relative motions fast
]]

-- debounce cmdline enter events to make sure we dont have flickering for non user cmdline use
-- e.g. mappings using : instead of <cmd>
local cmdline_debounce_timer

utils.autogroup("config.cmdline_linenr", {
    CmdlineEnter = function()
        cmdline_debounce_timer = vim.uv.new_timer()
        cmdline_debounce_timer:start(100, 0, vim.schedule_wrap(function()
            if vim.o.number then
                vim.o.relativenumber = false
                api.nvim__redraw({ statuscolumn = true })
            end
        end))
    end,

    CmdlineLeave = function()
        if cmdline_debounce_timer then
            cmdline_debounce_timer:stop()
            cmdline_debounce_timer = nil
        end
        if vim.o.number then
            vim.o.relativenumber = true
        end
    end,
})
-- }}}

-- Smarter :h 'autocd' {{{
-- when opening a file, automatically lcd to its git repo ancestor
-- if already in a repo, behave somewhat like autocd

autocmd("BufReadPost", {
    callback = function(ev)
        if vim.bo[ev.buf].filetype == "help" then
            return
        end

        local path = api.nvim_buf_get_name(ev.buf)
        local git_root = vim.fs.root(path, ".git")
        local pwd = vim.fn.getcwd()
        if git_root and not vim.startswith(pwd, git_root) then
            vim.cmd.lcd(git_root)
        else
            pcall(vim.cmd.lcd, vim.fn.expand("%:p:h"))
        end
    end
})
-- }}}

-- auto resize on window resize
-- TODO: add actual heuristics for what to do
autocmd("VimResized", {
    callback = function()
        vim.cmd.wincmd("=")
    end
})

-- highlight yanked text
autocmd("TextYankPost", {
    callback = function(ev)
        vim.highlight.on_yank { timeout = 120, higroup = "Yanked" }
    end
})

-- show current directory
local function printdir()
    local name = utils.expand_home(vim.fn.getcwd(0, 0))
    api.nvim_echo({ { "pwd: ", "NonText" }, { name, "Directory" } }, false, {})
end

autocmd("DirChanged", {
    callback = vim.schedule_wrap(printdir)
})
