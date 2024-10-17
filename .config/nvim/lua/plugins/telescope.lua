local M = {
    "nvim-telescope/telescope.nvim",
    keys = {
        { "<space>D",       function() require("telescope.builtin").diagnostics() end },
        { "<space>g",       function() require("telescope.builtin").git_files() end },
        { "<space>F",       function() require("telescope.builtin").find_files() end },
        { "<space>h",       function() require("telescope.builtin").oldfiles() end },
        { "<space>H",       function() require("telescope.builtin").help_tags() end },
        { "<space>/",       function() require("telescope.builtin").live_grep() end },
        { "<space>[",       function() require("telescope.builtin").lsp_document_symbols() end },
        { "<space>]",       function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end },
        { "<space>R",       function() require("telescope.builtin").registers() end },
        { "<space><space>", function() require("telescope.builtin").buffers() end },
        {
            "z=",
            mode = { "n", "x" },
            function() require("telescope.builtin").spell_suggest() end
        },
    },
    cmd = { "Telescope" },
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
        },
        {
            "jvgrootveld/telescope-zoxide",
        },
    },
}

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
            local lines = vim.o.lines
            if lines > 40 then
                return math.floor(lines * 0.9)
            end

            return lines
        end,
        width = function()
            local cols = vim.o.columns
            if cols > 80 then
                return math.floor(cols * 0.9)
            end

            return cols
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

M.opts = {}
M.opts.defaults = {
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
}
M.opts.pickers = {
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
    spell_suggest = {
        theme = "cursor",
        prompt_title = "Spell",
        prompt_prefix = "󰓆 fix: ",
        layout_config = {
            height = function()
                return math.floor(vim.o.lines / 4)
            end,
            width = function()
                return math.floor(vim.o.columns / 4)
            end,
        },
        mappings = {
            i = {
                ["<esc>"] = "close",
            }
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
}
M.opts.extensions = {
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
    },
    smart_open = {
        prompt_title = "test",
    }
}


M.config = function(_, opts)
    local telescope = require("telescope")

    telescope.setup(opts)
    telescope.load_extension("fzf")
    telescope.load_extension("zoxide")

    -- fix it not using my settings xD
    local old_zoxide = telescope.extensions.zoxide.list
    telescope.extensions.zoxide.list = function(args)
        old_zoxide(vim.tbl_extend("force", default_config_tbl, args or {}))
    end
end

return M
