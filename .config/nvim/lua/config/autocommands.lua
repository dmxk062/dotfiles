local autocmd = vim.api.nvim_create_autocmd
local utils = require("config.utils")

-- Window Title {{{
-- change the title in a more intelligent way
autocmd({ "BufEnter", "BufReadPost", "BufNewFile", "VimEnter" }, {
    callback = function(args)
        local name, kind, show_modified = require("config.utils").format_buf_name(vim.api.nvim_get_current_buf(), true)

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
local cmdline_group = vim.api.nvim_create_augroup("CmdlineLinenr", {})
-- debounce cmdline enter events to make sure we dont have flickering for non user cmdline use
-- e.g. mappings using : instead of <cmd>
local cmdline_debounce_timer

autocmd("CmdlineEnter", {
    group = cmdline_group,
    callback = function()
        cmdline_debounce_timer = vim.uv.new_timer()
        cmdline_debounce_timer:start(100, 0, vim.schedule_wrap(function()
            if vim.o.number then
                vim.o.relativenumber = false
                vim.api.nvim__redraw({ statuscolumn = true })
            end
        end))
    end
})

autocmd("CmdlineLeave", {
    group = cmdline_group,
    callback = function()
        if cmdline_debounce_timer then
            cmdline_debounce_timer:stop()
            cmdline_debounce_timer = nil
        end
        if vim.o.number then
            vim.o.relativenumber = true
        end
    end
})

-- }}}

-- Sane Defaults for Terminal Mode {{{
autocmd("TermOpen", {
    callback = function()
        vim.wo[0][0].number = false
        vim.wo[0][0].relativenumber = false
        vim.wo[0][0].statuscolumn = ""
        vim.wo[0][0].signcolumn = "no"
        -- immediately hand over control
        vim.cmd.startinsert()
    end
})

local leap_is_open = false
-- enter the terminal by default
autocmd("User", {
    pattern = "LeapEnter",
    callback = function() leap_is_open = true end
})
autocmd("User", {
    pattern = "LeapLeave",
    callback = function() leap_is_open = false end
})
autocmd({ "BufWinEnter", "WinEnter" }, {
    callback = function(ev)
        -- make sure that remote leap operations are not affected
        if vim.bo[ev.buf].buftype == "terminal" and not leap_is_open then
            vim.cmd.startinsert()
        end
    end
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

        local path = vim.api.nvim_buf_get_name(ev.buf)
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
    vim.api.nvim_echo({ { "pwd: ", "NonText" }, { name, "Directory" } }, false, {})
end

autocmd("DirChanged", {
    callback = vim.schedule_wrap(printdir)
})
