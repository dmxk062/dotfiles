-- Spec {{{
local picker_maps = {
    diagnostics = "<space>D",
    git_files = "<space>gf",
    git_status = "<space>gi",
    find_files = "<space>F",
    oldfiles = "<space>o",
    live_grep = "<space>/",
    lsp_workspace_symbols = "<space>v",
    buffers = "<space><space>",
    jumplist = "<space><C-o>",
}

local M = {
    "nvim-telescope/telescope.nvim",
    keys = vim.tbl_values(picker_maps),
    cmd = { "Telescope" },
    dependencies = {
        {
            "natecraddock/telescope-zf-native.nvim"
        },
    },
}
-- }}}


local cur_max_length = 0

--[[ Custom Layout {{{
Place prompt at bottom of screen, list and preview above it
]]
local function create_layout(picker)
    local Layout = require("telescope.pickers.layout")
    ---@param enter boolean
    ---@param opts vim.api.keyset.win_config
    local function create_win(enter, opts)
        local buf = vim.api.nvim_create_buf(false, true)

        local winopts = vim.tbl_extend("force", {
            style = "minimal",
            relative = "editor",
        }, opts)
        local win = vim.api.nvim_open_win(buf, enter, winopts)

        return Layout.Window {
            bufnr = buf,
            winid = win,
        }
    end

    local function destroy_win(win)
        if win then
            if vim.api.nvim_win_is_valid(win.winid) then
                vim.api.nvim_win_close(win.winid, true)
            end
            if vim.api.nvim_buf_is_valid(win.bufnr) then
                vim.api.nvim_buf_delete(win.bufnr, { force = true })
            end
        end
    end

    local layout = Layout {
        picker = picker,
        mount = function(self)
            local width = vim.o.columns
            local factor = 0.5
            local fhalf = math.floor(width * (factor))
            local shalf = math.floor(width * (1 - factor))

            if (fhalf + shalf) ~= width then
                fhalf = fhalf + 1
            end
            cur_max_length = fhalf

            local height = vim.o.lines
            local height_override = self.picker.layout_config.height
            local view_height

            if height_override then
                if type(height_override) == "function" then
                    view_height = height_override()
                else
                    view_height = height_override
                end
            else
                view_height = math.floor(0.4 * (height - 4))
                if view_height > 30 then
                    view_height = 30
                elseif view_height < 8 then
                    view_height = 8
                end
            end

            local row = height - view_height - 4

            self.results = create_win(false, {
                row = row,
                col = 0,
                width = fhalf,
                height = view_height,
                border = { "─", "─", "─", " ", "", "", "", "" },
            })
            self.preview = create_win(false, {
                row = row,
                col = fhalf + 2,
                width = shalf - 2,
                height = view_height,
                border = { "┬", "─", "─", "", "", "", "", "│" },
            })
            self.prompt = create_win(true, {
                width = width,
                height = 1,
                row = height - 3,
                col = 0,
            })
        end,
        unmount = function(self)
            destroy_win(self.results)
            destroy_win(self.preview)
            destroy_win(self.prompt)
        end,
        update = function(self) end
    }

    return layout
end
-- }}}

local default_config_tbl = {
    disable_devicons = true,
}

local function default_config(extra)
    return vim.tbl_deep_extend("force", default_config_tbl, extra or {})
end

-- Options {{{
M.opts = {}
M.opts.defaults = {
    create_layout = create_layout,
    default_mappings = {
        n = {
            ["<cr>"]  = "select_drop",
            ["t"]     = "select_tab",
            ["e"]     = "file_edit",
            ["s"]     = "select_horizontal",
            ["v"]     = "select_vertical",

            ["j"]     = "move_selection_next",
            ["k"]     = "move_selection_previous",

            ["gg"]    = "move_to_top",
            ["G"]     = "move_to_bottom",

            ["L"]     = "move_to_bottom",
            ["M"]     = "move_to_middle",
            ["H"]     = "move_to_top",

            ["$"]     = "smart_send_to_qflist",
            ["#"]     = "smart_send_to_loclist",

            ["<esc>"] = "close",
            ["q"]     = "close",
        },
        i = {
            ["<cr>"]   = "select_drop",
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
    prompt_prefix = "ed: ",
    path_display = function(opts, path)
        local tail = vim.fn.fnamemodify(path, ":t")
        local parendir = vim.fn.pathshorten(vim.fn.fnamemodify(path, ":~:.:h"), 6)

        local namewidth = vim.fn.strdisplaywidth(tail)
        local namelen = #tail

        local dirwidth = vim.fn.strdisplaywidth(parendir)
        local dirlen = #parendir

        local padding_width = cur_max_length - (namewidth + dirwidth)
        if padding_width < 0 then
            padding_width = 1
        end

        local hls = {
            {
                {
                    0,
                    namelen,
                },
                require("config.utils").highlight_fname(tail)
            },
            {
                {
                    namelen + padding_width,
                    namelen + padding_width + dirlen,
                },
                "NonText"
            }
        }

        return string.format("%s%s%s", tail, (" "):rep(padding_width), parendir), hls
    end,
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
    lsp_workspace_symbols = lsp_config,
    diagnostics = default_config {
        disable_coordinates = true,
    },
    git_files = default_config_tbl,
    live_grep = default_config_tbl,
    oldfiles = default_config_tbl,
    buffers = default_config {
        sort_lastused = true, -- so i can just <space><space><cr> to cycle
        previewer = false,
        mappings = {
            n = {
                ["dd"] = "delete_buffer",
            },
        },
        layout_config = {
            height = function()
                local ln = vim.o.lines
                return math.min(math.max(ln * 0.1, 8), 4)
            end
        }
    },
    find_files = default_config_tbl,
    help_tags = default_config_tbl,
}

M.opts.extensions = {
    ["zf-native"] = {}
}

-- }}}

M.config = function(_, opts)
    local telescope = require("telescope")

    telescope.setup(opts)
    telescope.load_extension("zf-native")

    local builtin = require("telescope.builtin")
    local map = require("config.utils").map
    for picker, keys in pairs(picker_maps) do
        map("n", keys, builtin[picker])
    end
end

return M
