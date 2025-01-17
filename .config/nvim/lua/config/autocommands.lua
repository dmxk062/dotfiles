local autocmd = vim.api.nvim_create_autocmd
-- change the title in a more intelligent way
autocmd({ "BufEnter", "BufReadPost", "BufNewFile", "VimEnter" }, {
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


-- sane defaults for terminal mode
autocmd("TermOpen", {
    callback = function(ev)
        vim.wo[0].number = false
        vim.wo[0].relativenumber = false
        vim.wo[0].statuscolumn = ""
        vim.wo[0].signcolumn = "no"
        -- immediately hand over control
        vim.cmd.startinsert()
    end
})

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
        if not git_root or not vim.startswith(pwd, git_root) then
            vim.cmd.lcd(git_root)
        else
            vim.cmd.lcd(vim.fn.expand("%:p:h"))
        end
    end
})

-- auto resize on window resize
-- TODO: add actual heuristics for what to do
autocmd("VimResized", {
    callback = function(ev)
        vim.cmd.wincmd("=")
    end
})

-- highlight yanked text
autocmd("TextYankPost", {
    callback = function(ev)
        vim.highlight.on_yank { timeout = 120, higroup = "Yanked" }
    end
})

-- treat terminal buffers as terminals by default
autocmd("WinEnter", {
    callback = function(ev)
        if vim.bo[ev.buf].buftype == "terminal" then
            vim.cmd.startinsert()
        end
    end
})
