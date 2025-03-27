local M = {
    "cbochs/grapple.nvim"
}
--[[ Rationale {{{
Builtin neovim marks just don't cut it anymore
Grapple makes everything a *lot* nicer
}}} ]]

local on_window_open = function(window)
    local actions = require("grapple.tag_actions")

    window:map("n", "<cr>", function()
        local cursor = window:cursor()
        window:perform_close(actions.select, { index = cursor[1] })
    end)
    window:map("n", "v", function()
        local cursor = window:cursor()
        window:perform_close(actions.select, { index = cursor[1], command = vim.cmd.vsplit })
    end)
    window:map("n", "s", function()
        local cursor = window:cursor()
        window:perform_close(actions.select, { index = cursor[1], command = vim.cmd.split })
    end)
    window:map("n", "t", function()
        local cursor = window:cursor()
        window:perform_close(actions.select, { index = cursor[1], command = vim.cmd.tabnew })
    end)

    window:map("n", "R", function()
        local entry = window:current_entry()
        local path = entry.data.path
        window:perform_retain(actions.rename, { path = path })
    end)

    window:map("n", "$", function()
        window:perform_close(actions.quickfix)
    end)

    for i = 1, 9 do
        window:map("n", ("%d"):format(i), function()
            window:perform_close(actions.select, { index = i })
        end)
    end
end

M.config = function()
    local grapple = require("grapple")

    grapple.setup {
        scope = "lsp",
        icons = false,
        win_opts = {
            width = 48,
            height = 0.3,
            row = 0.5,
            col = 0.5,

            border = "rounded",
            footer = "",
        },
        tag_hook = on_window_open,
        style = "colorized",
        styles = {
            colorized = function(entry, content)
                local path = require("grapple.path")

                local name = path.fs_relative(content.scope.path, entry.tag.path:gsub("^oil://", ""))
                local highlight = require("config.utils").highlight_fname(entry.tag.path)

                local marks = {}
                local end_col = vim.fn.strdisplaywidth(name) + 5 -- compensate for the ID grapple places there
                table.insert(marks, {
                    hl_mode = "combine",
                    end_col = end_col,
                    hl_group = highlight,
                })

                return {
                    display = name,
                    marks = marks
                }
            end
        }
    }

    local utils = require("config.utils")
    local map = utils.map

    local add_grapple = function()
        if vim.v.count > 0 then
            grapple.tag { index = vim.v.count }
        else
            grapple.tag()
        end
    end

    local rm_grapple = function()
        if vim.v.count > 0 then
            grapple.untag { index = vim.v.count }
        else
            grapple.untag()
        end
    end

    map("n", "<C-t>", add_grapple)
    map("n", "+g", add_grapple)
    map("n", "-g", rm_grapple)

    -- use the same prefix as the buffer maps
    map("n", "'g", function() grapple.open_tags() end)
    map("n", "'G", function() grapple.open_scopes { all = true } end)

    -- specifying the unnamed register makes little to no sense
    map("n", '""', function()
        if vim.v.count == 0 then
            grapple.cycle_tags("next")
        else
            grapple.select { index = vim.v.count }
        end
    end)
end

return M
