vim.cmd.colorscheme("mynord")

-- only open the startscreen if stdin is empty
-- and there are no command line arguments
local open_start_screen = vim.fn.argc() == 0
vim.api.nvim_create_autocmd("StdinReadPre", {
    once = true,
    callback = function(ctx)
        open_start_screen = false
    end
})

local opt = vim.opt
local o = vim.o

-- Basic options {{{
o.cursorline = true
o.cursorlineopt = "number"
o.expandtab = true
o.hlsearch = true
o.ignorecase = true
o.incsearch = true
o.number = true
o.numberwidth = 2
o.relativenumber = true
o.scrolloff = 1
o.shiftwidth = 4
o.showmode = false
o.smartcase = true
o.softtabstop = 4
o.title = true
o.undofile = true
-- }}}

-- Wrapping {{{
-- wrap at whitespace, indent wrapped lines and show an indicator
o.wrap = true
o.linebreak = true
o.breakindent = true
o.breakindentopt = "sbr"
o.showbreak = ""
-- }}}

-- idk why that isn't the default, much more intuitive imo
o.splitright = true
o.splitbelow = true

opt.shortmess:append("S") -- hide search count
opt.shortmess:append("s") -- hide search hit x
opt.shortmess:append("q") -- hide macro

-- Characters {{{
opt.fillchars = {
    -- its visible from the gaps anyways
    diff = " ",
    lastline = "",
}

opt.listchars = {
    eol = "",
    tab = "󰌒 ",
    space = "·",
    multispace = " · ",
}

-- }}}

opt.diffopt = {
    "filler",
    "internal",
    "closeoff",
    "context:4", -- 6 is a bit too much for me
}

-- current directory, children and parent
-- this can be **super** slow in large directories, just don't use it then :)
opt.path = {
    ".",
    "**",
    "../",
    "../*",
}

-- normal, o-pending, visual: block
-- replace: underscore
-- insert, command: bar
-- all except o-pending: blink
opt.guicursor = {
    "n-o-v:block",
    "r:hor20",
    "i-c-ci-cr:ver10",
    "n-c-ci-cr-r-v:blinkon1",
}

-- ftplugins {{{
vim.g.c_syntax_for_h = true -- i use C more than C++
-- }}}

-- Lazy {{{
-- use lazy for the remaining config
-- all the package definitions in ./lua/plugins/ will be loaded
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
    -- so i can work on my own local plugins
    dev = {
        path = "~/ws/nvim_plugins",
        patterns = { "dmxk062" },
        fallback = true,
    },

    install = {
        colorscheme = { "mynord" },
    },

    -- just plain annoying with a simpler config
    change_detection = {
        enabled = false,
        notify  = false,
    },

    ui = {
        title = "Plugins - Lazy",
        border = "rounded",
        backdrop = 100,
        pills = false,
        icons = {
            loaded     = "󰗠",
            not_loaded = "󰍷",
            ft         = "󰈔",
            cmd        = "",
            event      = "󰍢",
            lazy       = "󰒲",
            start      = "󰐥",
            runtime    = "",
            list       = {
                "󱦰",
                "󱞩",
                "󱞩",
                "󱞩",
            },
        }
    },
    performance = {
        rtp = {
            reset = true,
            disabled_plugins = {
                "tutor",   -- I *think* I know vim well enough

                "matchit", -- use matchup instead
                "matchparen"
            }
        }
    }
})
-- }}}

-- Load Config {{{
require("config.autocommands") -- set various useful autocommands
require("config.mappings")     -- set all the mappings
require("config.commands")     -- custom commands for all buffers
require("config.statusline")   -- at bottom of screen
require("config.bufferline")   -- at the top
-- }}}

-- for some reason lazy deactivates that
o.modeline = true

-- create this autocommand after nvim had a chance to read from stdin
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function(ctx)
        if open_start_screen then
            require("config.startscreen").show_start_screen()
        end
    end
})
