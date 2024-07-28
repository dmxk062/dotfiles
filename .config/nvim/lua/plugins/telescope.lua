local M = {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
}
M.config = function()
    local telescope = require("telescope")
    local utils = require("utils")

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
            lsp_definitions = default_config {
                jump_type = "tab drop",
                reuse_win = true,
            },
            diagnostics = default_config(),
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
                sort_lastused = true,     -- so i can just <space><space><cr> to cycle
                theme = "dropdown",
                previewer = false,
                layout_config = {
                    height = .5,
                    width = .5,
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
            lsp_workspace_symbols = default_config(),
            find_files = default_config(),
        },
        extensions = {
        }
    }
    local builtin = require("telescope.builtin")
    local _prefix = "<space>"


    for _, map in ipairs({
        { "D",       builtin.diagnostics },
        { "gF",      builtin.git_files },
        { "F",       builtin.find_files },
        { "h",       builtin.oldfiles },
        { "/",       builtin.live_grep },
        { "R",       builtin.registers },
        { "<space>", builtin.buffers },
    }) do
        utils.map("n", _prefix .. map[1], map[2])
    end
end

return M
