local telescope = require("telescope")
local utils = require("utils")
local themes = require("telescope.themes")

-- telescope.load_extension('fzf')
local buffer_on_enter = {
    n = {
        ["<enter>"] = "select_drop",
        ["<S-enter>"] = "select_tab_drop",
        ["<M-j>"] = "move_selection_next",
        ["<M-k>"] = "move_selection_previous",
    },
    i = {
        ["<enter>"] = "select_drop",
        ["<S-enter>"] = "select_tab_drop",
        ["<M-j>"] = "move_selection_next",
        ["<M-k>"] = "move_selection_previous",
    },
}

local function default_config(extra)
    local default = {
        theme = "ivy",
        layout_config = {
            height = .3,
        },
        mappings = buffer_on_enter,
    }
    return vim.tbl_deep_extend("force", default, extra or {})
end
telescope.setup {
    defaults = {
        mappings = {
            n = {
                ["t"] = "select_tab",
                ["e"] = "file_edit",
                ["s"] = "select_horizontal",
                ["v"] = "select_vertical",
                ["<M-j>"] = "move_selection_next",
                ["<M-k>"] = "move_selection_previous",
            },
        },
        dynamic_preview_title = true,
        results_title = false,
        selection_caret = "> ",
        prompt_prefix = " ",
    },
    pickers = {
        lsp_definitions = default_config { jump_type = "tab" },
        diagnostics = default_config(),
        find_files = default_config(),
        git_files = default_config { prompt_title = "Files in Git" },
        live_grep = default_config(),
        grep_string = default_config(),
        oldfiles = default_config { prompt_title = "History" },
        registers = {
            theme = "cursor",
            mappings = {
                n = {
                    ["e"] = "edit_register"
                }
            }
        },
        buffers = {
            theme = "dropdown",
            previewer = false,
            layout_config = {
                height = .3,
                width = .3,
            },
            mappings = {
                n = {
                    ["dd"] = "delete_buffer",
                    ["t"] = "select_tab_drop",
                    ["s"] = "select_horizontal",
                    ["v"] = "select_vertical",
                    ["<enter>"] = "select_drop",
                    ["<S-enter>"] = "select_default"
                },
                i = {
                    ["<enter>"] = "select_drop",
                    ["<S-enter>"] = "select_default",
                    ["<M-j>"] = "move_selection_next",
                    ["<M-k>"] = "move_selection_previous",
                },
            }
        },
        lsp_references = default_config(),
        treesitter = default_config { prompt_title = "Symbols" },
    },
    extensions = {
        ["ui-select"] = {
            themes.get_cursor {
                layout_config = {
                    height = 6,
                    width = 60
                }
            },
        },
    }
}
local builtin = require('telescope.builtin')
local _prefix = "<space>"

utils.map('n', 'gr', builtin.lsp_references)
utils.map('n', 'gd', builtin.lsp_definitions)
utils.map('n', 'gi', builtin.lsp_implementations)

for _, map in ipairs({
    { "D",       builtin.diagnostics },
    { "T",       builtin.treesitter },
    { "F",       builtin.find_files },
    { "gF",      builtin.git_files },
    { "h",       builtin.oldfiles },
    { "/",       builtin.live_grep },
    { "r",       builtin.registers },
    { "<space>", builtin.buffers },
    { "#",       builtin.grep_string }
}) do
    utils.map("n", _prefix .. map[1], map[2])
end

function register_and_insert()
    builtin.registers {
        mappings = {
            n = {
                ["e"] = "edit_register",
            }
        }
    }
end

utils.map('i', '<C-R>', register_and_insert)

telescope.load_extension("ui-select")
