local actions = require("oil.actions")
local api = require("oil")
require("oil").setup({
    default_file_explorer = true,

    win_options = {
        cursorlineopt="line",
    },

    columns = {
        "icon",
    },
    constrain_cursor = "name",

    float = {
        padding = 16,
        max_width = 80,
        max_height = 40,

    },
    use_default_keymaps = false,

    keymaps = {
        ["<CR>"] = actions.select,
        ["<C-H>"] = actions.toggle_hidden,
        ["<C-->"] = function()
            actions.open_cmdline.callback()
            vim.api.nvim_input("!chmod ")
        end,
        ["!"] = function()
            actions.open_cmdline.callback()
            vim.api.nvim_input("! ")
        end,
        ["ws"] = function()
            local pwd = api.get_current_dir()
            vim.fn.jobstart(string.format("kitty @ launch --type=window --cwd \"%s\" -- zsh -i", pwd))
        end,
        ["g.."] = actions.parent,
        ["v"] = actions.select_vsplit,
        ["s"] = actions.select_split,
        ["t"] = actions.select_tab,
        ["Y"] = actions.copy_entry_path,

    },
})
