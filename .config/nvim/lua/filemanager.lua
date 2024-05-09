local actions = require("oil.actions")
local lspconfig = require("lspconfig.util")
local api = require("oil")
local utils = require("utils")


local perms_hlgroups = {
    ['-'] = "OilNoPerm",
    ['r'] = "OilRead",
    ['w'] = "OilWrite",
    ['x'] = "OilExec",
    ['t'] = "OilSticky",
    ['s'] = "OilSetuid",
}

api.setup({
    default_file_explorer = true,

    win_options = {
        cursorlineopt="line,number",
    },

    columns = {
        { 
            "icon",
            default_file = "󰈔",
            directory = "",
        },
        {
            "permissions",
            highlight = function(str)
                local hls = {}
                for i = 1, #str do
                    table.insert(hls, {perms_hlgroups[str:sub(i,i)], i - 1, i})
                end
                return hls
            end,

        }
    },
    constrain_cursor = "editable",
    skip_confirm_for_simple_edits = true,

    float = {
        padding = 16,
        max_width = 80,
        max_height = 40,

    },
    preview = {
        max_width = 0.4,
        min_width = 0.6,

    },
    use_default_keymaps = false,
    cleanup_delay_ms = 5000,
    extra_scp_args = {"-O"},
     
    view_options = {
        is_hidden_file = function(name, bufnr) 
            return vim.startswith(name, '.') and not (name:sub(2, 2) == ".")
        end,

        is_always_hidden = function(name, bufnr) 
            return name == "."
        end,
        natural_order = true,
    },

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
        -- open in other program
        ["eo"] = function()
            local entry = api.get_cursor_entry()

            vim.fn.jobstart("xdg-open \"" .. api.get_current_dir() .. "/" .. entry.name .. "\"")
        end,
        -- override the regular one
        [" sw"] = function()
            local pwd = api.get_current_dir()
            utils.kitty_new_dir(pwd, "window")
        end,
        [" st"] = function()
            local pwd = api.get_current_dir()
            utils.kitty_new_dir(pwd, "tab")
        end,
        ["g~"] = function()
            api.open(vim.fn.expand("~"))
        end,
        ["gh"] = function()
            api.open(vim.fn.expand("~"))
        end,
        ["gw"] = function()
            api.open(vim.fn.expand("~/ws"))
        end,
        ["g/"] = function()
            api.open("/")
        end,
        ["gr"] = function()
            api.open("/")
        end,
        ["g.."] = actions.parent,
        ["gp"] = actions.parent,
        ["gP"] = function()
            local ancestor = lspconfig.find_git_ancestor()
            api.open(ancestor)
        end,
        ["cd"] = function()
            vim.api.nvim_input"<ESC>:Oil "
            actions.cd.callback()
        end,
        ["es"] = actions.select_split,
        ["et"] = actions.select_tab,
        ["ev"] = actions.select_vsplit,
        ["<S-CR>"] = actions.select_tab,
        ["<C-CR>"] = actions.select_split,
        ["<M-CR>"] = actions.select_vsplit,
        ["e"] = actions.copy_entry_path,


    },
})

vim.keymap.set("n", " fF", api.open_float)
vim.keymap.set("n", " ff", api.open)

vim.keymap.set("n", " ft", function() 
    vim.api.nvim_command("tabnew")
    api.open() 
end)
vim.keymap.set("n", " fs", function() 
    vim.api.nvim_command("split")
    api.open() 
end)
vim.keymap.set("n", " fv", function() 
    vim.api.nvim_command("vsplit")
    api.open() 
end)

