local M = {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
        },
        {
            "jvgrootveld/telescope-zoxide",
        }
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

    local default_config_tbl = {
        layout_config = {
            height = function()
                return vim.o.lines
            end,
            width = function()
                return vim.o.columns
            end,
            preview_cutoff = 1,
            prompt_position = "bottom",
        },
        mappings = buffer_on_enter,
        borderchars = {
            prompt = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
            results = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
            preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        }
    }

    local function default_config(extra)
        return vim.tbl_deep_extend("force", default_config_tbl, extra or {})
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
            prompt_prefix = " ed: ",
        },
        pickers = {
            lsp_definitions = default_config {
                jump_type = "tab drop",
                reuse_win = true,
                layout_config = {
                    preview_width = 0.8,
                }
            },
            lsp_references = default_config {
                jump_type = "tab drop",
                reuse_win = true,
                layout_config = {
                    preview_width = 0.8,
                }
            },
            lsp_dynamic_workspace_symbols = default_config {
                jump_type = "tab drop",
                prompt_title = "Symbols",
                reuse_win = true,
                layout_config = {
                    preview_width = 0.6,
                }

            },
            lsp_document_symbols = default_config {
                jump_type = "tab drop",
                prompt_title = "Symbols",
                reuse_win = true,
                layout_config = {
                    preview_width = 0.6,
                }

            },
            diagnostics = default_config {
                layout_config = {
                    preview_width = 0.5,
                }
            },
            git_files = default_config { prompt_title = "Files in Git" },
            live_grep = default_config(),
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
                sort_lastused = true, -- so i can just <space><space><cr> to cycle
                theme = "dropdown",
                previewer = false,
                layout_config = {
                    height = function()
                        local nh = math.floor(vim.o.lines * .1)
                        return nh >= 8 and nh or 8
                    end,
                    width = function()
                        return math.min(vim.o.columns - 4, 64)
                    end
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
            find_files = default_config {
                hidden = true,
            },
            help_tags = default_config {
                mappings = {
                    n = {
                        ["<CR>"] = "select_default",
                        ["v"] = "select_vertical",
                        ["s"] = "select_horizontal",
                        ["t"] = "select_tab"
                    },
                    i = {
                        ["<CR>"] = "select_default",
                    }
                }
            },
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case"
            },
            zoxide = {
                prompt_title = "Zoxide",
                mappings = {
                    -- cd/edit instead of anything else
                    default = {
                        action = function(selection)
                            vim.cmd.edit(selection.path)
                        end,
                        after_action = function(selection)
                        end
                    },
                }
            }
        }
    }
    telescope.load_extension("fzf")
    telescope.load_extension("zoxide")

    -- fix it not using my settings xD
    local old_zoxide = telescope.extensions.zoxide.list
    telescope.extensions.zoxide.list = function(args)
        old_zoxide(vim.tbl_extend("force", default_config_tbl, args or {}))
    end

    local builtin = require("telescope.builtin")
    local _prefix = "<space>"


    for _, map in ipairs({
        { "D",       builtin.diagnostics },
        { "g",       builtin.git_files },
        { "F",       builtin.find_files },
        { "h",       builtin.oldfiles },
        { "H",       builtin.help_tags },
        { "/",       builtin.live_grep },
        { "[",       builtin.lsp_document_symbols },
        { "]",       builtin.lsp_dynamic_workspace_symbols },
        { "R",       builtin.registers },
        { "<space>", builtin.buffers },

    }) do
        utils.map("n", _prefix .. map[1], map[2])
    end
end

return M
