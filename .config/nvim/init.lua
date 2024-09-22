require("theme.theme").load()

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
vim.o.termguicolors = true
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
    "n-o-r-v-sm:block",
    "i-ve:ver10",
    "n-i-ve:blinkon1"
}
vim.o.cursorline = true
vim.o.cursorlineopt = "number"

-- enable terminal title
vim.o.title = true

-- i use C more than C++
vim.g.c_syntax_for_h = true

-- change the title in a more intelligent way
vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost", "BufNewFile", "VimEnter" }, {
    callback = function(args)
        -- expand stuff similarly to my shell directory aliases
        local function format_path(name, user)
            local expanded = name:gsub("/tmp/workspaces_" .. user, "~tmp")
                :gsub("/home/" .. user .. "/ws", "~ws")
                :gsub("/home/" .. user .. "/.config", "~cfg")
                :gsub("/home/" .. user, "~")
            return expanded
        end

        local path     = ""
        local buf      = vim.api.nvim_get_current_buf()
        local bufname  = vim.api.nvim_buf_get_name(buf)
        local filetype = vim.bo[buf]["ft"]

        local user     = vim.env.USER

        if filetype == "oil" then
            if vim.startswith(bufname, "oil-ssh://") then
                local remote_path = bufname:match("//.-(/.*)"):sub(2, -1) -- the path at the host
                path = "ssh:" .. remote_path
            else
                path = format_path(bufname:sub(#"oil:///"), user)
            end
        elseif filetype == "help" then
            path = "Help"
        elseif filetype == "lazy" then
            path = "Plugins"
        elseif filetype == "alpha" then
            path = "NeoVIM"
        elseif bufname == "" then
            return
        else
            path = format_path(bufname, user)
        end

        vim.o.titlestring = "nv: " .. path
    end
})

vim.o.titlestring = "nv: NeoVIM" -- set initial

-- change line number based on mode:
-- for command mode: make it absolute for ranges etc
-- for normal mode: relative movements <3
local cmdline_group = vim.api.nvim_create_augroup("CmdlineLinenr", {})
vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = cmdline_group,
    callback = function()
        if vim.o.number then
            vim.o.relativenumber = false
            vim.api.nvim__redraw({ statuscolumn = true })
        end
    end
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = cmdline_group,
    callback = function()
        if vim.o.number then
            vim.o.relativenumber = true
        end
    end
})


-- sane defaults for terminal mode
vim.api.nvim_create_autocmd("TermOpen", {
    callback = function(ev)
        vim.wo[0].number = false
        vim.wo[0].relativenumber = false
        -- immediately hand over control
        vim.cmd.startinsert()
    end
})

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

-- set all the mappings
require("mappings")

-- for some reason lazy deactivates that
vim.o.modeline = true
