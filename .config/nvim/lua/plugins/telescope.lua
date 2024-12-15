local M = {
    "nvim-telescope/telescope.nvim",
    keys = {
        "<space>Df",
        "<space>gf",
        "<space>F",
        "<space>o",
        "<space>/",
        "<space>v",
        "<space>V",
        "<space><space>",
        {
            "z=",
            mode = { "n", "x" },
        },
    },
    cmd = { "Telescope" },
    dependencies = {
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
        },
        {
            "jvgrootveld/telescope-zoxide",
        },
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
    default_mappings = {
        n = {
            ["<cr>"]     = "select_drop",
            ["t"]        = "select_tab",
            ["e"]        = "file_edit",
            ["s"]        = "select_horizontal",
            ["v"]        = "select_vertical",

            ["j"]        = "move_selection_next",
            ["k"]        = "move_selection_previous",
            ["gg"]       = "move_to_top",
            ["G"]        = "move_to_bottom",

            ["L"]        = "move_to_bottom",
            ["M"]        = "move_to_middle",
            ["H"]        = "move_to_top",

            ["<space>c"] = "send_to_qflist",

            ["<esc>"]    = "close",
            ["q"]        = "close",
        },
        i = {
            ["<cr>"]    = "select_drop",
            ["<M-j>"]  = "move_selection_next",
            ["<M-k>"]  = "move_selection_previous",
            ["<Down>"] = "move_selection_next",
            ["<Up>"]   = "move_selection_previous",
        }
    },
    dynamic_preview_title = true,
    results_title = false,
    selection_caret = "",
    entry_prefix = "",
    multi_icon = "",
    prompt_prefix = " ed: ",
    path_display = {
        shorten = 8,
    },
}

local lsp_config = default_config {
    jump_type = "drop",
    reuse_win = true,
    layout_config = {
        preview_width = 0.6,
    }
}
M.opts.pickers = {
    lsp_definitions = lsp_config,
    lsp_references = lsp_config,
    lsp_dynamic_workspace_symbols = lsp_config,
    lsp_document_symbols = lsp_config,
    diagnostics = default_config_tbl,
    git_files = default_config_tbl,
    live_grep = default_config_tbl,
    oldfiles = default_config_tbl,
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
                ["<cr>"] = "select_default",
            }
        }
    },
    find_files = default_config {
        hidden = true,
    },
    help_tags = default_config_tbl,
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

    local maps = {
        diagnostics = "<space>Df",
        git_files = "<space>gf",
        find_files = "<space>F",
        oldfiles = "<space>o",
        live_grep = "<space>/",
        lsp_document_symbols = "<space>v",
        lsp_dynamic_workspace_symbols = "<space>V",
        buffers = "<space><space>",
    }

    local builtin = require("telescope.builtin")
    for picker, keys in pairs(maps) do
        vim.keymap.set("n", keys, builtin[picker])
    end
    vim.keymap.set({ "x", "n" }, "z=", builtin.spell_suggest)
end

return M
