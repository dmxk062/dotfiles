require("theme.theme").load()
vim.g.nord_italic = true
vim.g.nord_borders = true

vim.o.relativenumber = true
vim.o.number = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.showmode = false
vim.o.smartcase = true
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.hlsearch = true
vim.o.termguicolors = true
vim.o.wildmenu = false

-- wrap at whitespace and, indent wrapped lines and show an indicator
vim.o.wrap = true
vim.o.linebreak = true
vim.o.breakindent = true
vim.o.breakindentopt = "sbr"
vim.o.showbreak = ""

-- idk why that isnt the default
vim.o.splitright = true
vim.o.splitbelow = true

-- disable all the search related messages
vim.opt.shortmess:append("S") -- hide search count
vim.opt.shortmess:append("s") -- hide search hit x
vim.opt.shortmess:append("q") -- hide macro


-- command mode: underline:
-- normal, visual etc: block
-- insert: bar, blink
-- normal: blink
vim.o.guicursor = "c-ci-cr:hor20,n-o-r-v-sm:block,i-ve:ver10,n-i-ve:blinkon1,"
vim.o.cursorline = true
vim.o.cursorlineopt = "number"

vim.o.title = true
vim.o.wrap = true

vim.g.c_syntax_for_h = true -- i use C more than C++

-- change the title in a more intelligent way
vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost", "BufNewFile", "VimEnter" }, {
    callback = function(args)
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

        if filetype == "TelescopePrompt" then
            path = ""
        elseif filetype == "oil" then
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

-- load all the "real" config in ./lua/ and the packages in ./lua/plugins/
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins", {
    dev = {
        path = "~/ws/nvim_plugins",
        patterns = {"dmxk062"},
        fallback = true,
    },
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
            list = {
                "󱦰",
                "󱞩",
                "󱞩",
                "󱞩",
            },
        }
    }
})

require("mappings")
-- for some reason lazy deactivates that
vim.o.modeline = true
