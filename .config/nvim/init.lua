vim.cmd("source" .. vim.fn.stdpath("config") .. "/pkgs.vim")
vim.o.runtimepath = vim.o.runtimepath .. "," .. vim.fn.stdpath("config") .. "/lua/nord"
vim.g.nord_italic = true
vim.g.nord_borders = true
vim.cmd("colorscheme nord")

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
vim.o.wrap = true

-- idk why that isnt the default
vim.o.splitright = true
vim.o.splitbelow = true


vim.o.guicursor = "c-ci-cr:hor20,n-o-r-v-sm:block,i-ve:ver10,n-i-ve:blinkon1,"
vim.o.cursorline = true
vim.o.cursorlineopt = "number"

vim.o.title = true
vim.o.wrap = true

vim.api.nvim_create_autocmd({"BufEnter", "BufReadPost", "BufNewFile", "VimEnter"},{
callback = function(args)
    local function format_path(name, user)
        local expanded = name:gsub("/tmp/workspaces_" .. user, "~tmp")
            :gsub("/home/" .. user .. "/ws", "~ws")
            :gsub("/home/" .. user .. "/.config", "~cfg")
            :gsub("/home/" .. user, "~")
        return expanded
    end

    local path = ""
    local buf = vim.api.nvim_get_current_buf()
    local bufname  = vim.api.nvim_buf_get_name(buf)
    local filetype = vim.bo[buf]["filetype"]

    local user = vim.env.USER

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
    elseif filetype == "vim-plug" then
        path = "Plugins"
    elseif filetype == "alpha" then
        path = "NeoVIM"
    elseif bufname == "" then
        path = "[No Name]"
    else
        path = format_path(bufname, user)
    end

    vim.o.titlestring = "nv: " .. path
end
})

-- vim.api.nvim_create_autocmd("VimEnter", {
--     callback = function ()
--         vim.o.titlestring = "nv: NeoVIM"
--     end
-- })





require("mappings")
require("plugins")
