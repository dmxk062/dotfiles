local open_start_screen = (vim.fn.argc() == 0)

vim.api.nvim_create_autocmd("StdinReadPre", {
    once = true,
    callback = function(ctx)
        open_start_screen = false
    end
})


vim.cmd.colorscheme "mynord"
vim.o.relativenumber = true
vim.o.number = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.showmode = false
vim.o.smartcase = true
vim.o.expandtab = true
-- vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.hlsearch = true
-- vim.o.termguicolors = true
-- vim.o.wildmenu = false
vim.o.scrolloff = 1
vim.o.undofile = true

-- wrap at whitespace, indent wrapped lines and show an indicator
vim.o.wrap = true
vim.o.linebreak = true
vim.o.breakindent = true
vim.o.breakindentopt = "sbr"
vim.o.showbreak = ""

-- idk why that isn't the default, much more intuitive imo
vim.o.splitright = true
vim.o.splitbelow = true

vim.opt.shortmess:append("S") -- hide search count
vim.opt.shortmess:append("s") -- hide search hit x
vim.opt.shortmess:append("q") -- hide macro

vim.opt.fillchars = {
    -- its visible from the gaps anyways
    diff = " ",
    lastline = "",
}

vim.opt.listchars = {
    eol = "",
    tab = "󰌒 ",
    space = "·",
    multispace = " · ",
}

-- command mode: underline
-- normal, visual etc: block
-- insert: bar, blink
-- normal: blink
vim.opt.guicursor = {
    "c-ci-cr:hor20",
    "n-o-v-sm:block",
    "r:hor20",
    "i-ve:ver10",
    "n-i-ve:blinkon1",
}
vim.o.cursorline = true
vim.o.cursorlineopt = "number"

-- enable terminal title
vim.o.title = true

-- i use C more than C++
vim.g.c_syntax_for_h = true


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

vim.opt.rtp:prepend(lazypath)
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
    }
})

-- set various useful autocommands
require("modules.autocommands")

-- set all the mappings
require("mappings")

-- for some reason lazy deactivates that
vim.o.modeline = true

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function(ctx)
        if open_start_screen then
            require("modules.startscreen").show_start_screen()
        end
    end
})
