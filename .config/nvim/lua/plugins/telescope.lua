-- Spec {{{
local picker_maps = {
    diagnostics = "<space>D",
    git_files = "<space>gf",
    git_status = "<space>gi",
    find_files = "<space>F",
    oldfiles = "<space>o",
    live_grep = "<space>/",
    lsp_workspace_symbols = "<space>V",
    lsp_document_symbols = "<space>v",
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

local utils = require("config.utils")
local strlib = require("plenary.strings")

--[[ Custom Layout {{{
Place prompt at bottom of screen, list and preview above it
]]

local MIN_FILENAME_WIDTH = 80
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
            local factor = 0.4
            local fhalf = math.floor(width * (factor))
            local shalf = math.floor(width * (1 - factor))

            if (fhalf + shalf) ~= width then
                fhalf = fhalf + 1
            end

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
                height = view_height + 1,
                border = { "┬", "─", "─", "", "", "", "", "│" },
            })
            self.prompt = create_win(true, {
                width = fhalf,
                height = 1,
                row = height - 3,
                col = 0,
                border = "none",
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

local path_display = function(opts, path)
    local tail = vim.fn.fnamemodify(path, ":t")
    local parendir = vim.fn.pathshorten(vim.fn.fnamemodify(path, ":~:.:h"), 6)

    local namelen = #tail
    local namewidth = vim.fn.strdisplaywidth(tail)
    local dirlen = #parendir
    local dirwidth = vim.fn.strdisplaywidth(parendir)

    local padding = math.max(MIN_FILENAME_WIDTH - (namewidth + dirwidth), 0)

    local hls = {
        {
            {
                0,
                namelen,
            },
            utils.highlight_fname(tail)
        },
        {
            {
                namelen + 1 + padding,
                namelen + dirlen + 1 + padding,
            },
            "NonText"
        }
    }

    return string.format("%s %s%s ", tail, (" "):rep(padding), parendir), hls
end
-- }}}

-- Entry Makers {{{

-- for grep
local line_and_col_display
local MAX_FILENAME_WIDTH = 24
local MAX_FILEPARENT_WIDTH = 24
local ROW_COL_WIDTH = 11
local line_and_column_entry_maker = function(line)
    if not line_and_col_display then
        line_and_col_display = require("telescope.pickers.entry_display").create {
            separator = " ",
            items = {
                { width = MAX_FILENAME_WIDTH },
                { width = MAX_FILEPARENT_WIDTH },
                { width = ROW_COL_WIDTH },
                { remaining = true }
            }
        }
    end

    local _, _, filename, row, col, text = string.find(line, "(..-):(%d+):(%d+):(.*)")
    row, col = tonumber(row), tonumber(col)
    local tail = vim.fn.fnamemodify(filename, ":t")
    local parentdir = vim.fn.pathshorten(vim.fn.fnamemodify(filename, ":~:.:h"), 6)
    local filename_highlight = utils.highlight_fname(tail)
    tail = strlib.truncate(tail, MAX_FILENAME_WIDTH, "~")
    parentdir = strlib.truncate(parentdir, MAX_FILEPARENT_WIDTH, "~")


    return {
        value = line,
        display = function()
            return line_and_col_display {
                { tail,                       filename_highlight },
                { parentdir,                  "NonText" },
                { ("%d:%d"):format(row, col), "Number" },
                { text },
            }
        end,
        ordinal = line,
        lnum = row,
        col = col,
        filename = filename
    }
end

-- for find_files and git_files
local file_display
local file_entry_maker = function(line)
    local max_name_width = MAX_FILENAME_WIDTH * 2

    if not file_display then
        file_display = require("telescope.pickers.entry_display").create {
            separator = " ",
            items = {
                { width = max_name_width },
                { remaining = true,      right_justify = true },
            }
        }
    end

    return {
        value = line,
        display = function(entry)
            local value = entry.value

            local tail = vim.fn.fnamemodify(value, ":t")
            local parentdir = vim.fn.pathshorten(vim.fn.fnamemodify(value, ":~:.:h"), 6)
            local filename_highlight = utils.highlight_fname(tail)

            tail = strlib.truncate(tail, max_name_width, "~")
            return file_display {
                { tail,      filename_highlight },
                { parentdir, "NonText" }
            }
        end,
        filename = line,
        ordinal = line,
    }
end

-- lsp_symbols
local lsp_entry_display
local MAX_SYMBOL_WIDTH = 60
local lsp_symbol_entry_maker = function(entry)
    if not lsp_entry_display then
        lsp_entry_display = require("telescope.pickers.entry_display").create {
            separator = " ",
            items = {
                { width = 8 }, -- icon and type
                { width = MAX_SYMBOL_WIDTH },
                { width = MAX_FILENAME_WIDTH },
            }
        }
    end

    local buf
    if not entry.filename then
        buf = vim.api.nvim_get_current_buf()
    end

    local filename = entry.filename or vim.api.nvim_buf_get_name(buf)
    local _, name = entry.text:match("^%[(.+)%]%s+(.*)")

    return {
        col = entry.col,
        lnum = entry.lnum,
        symbol_type = entry.kind,
        buffer = buf,
        filename = filename,
        value = entry,
        ordinal = entry.kind .. ":" .. filename .. ":" .. entry.lnum,
        display = function()
            -- use same highlights as cmp
            local hl = "CmpItemKind" .. entry.kind
            local tail = vim.fn.fnamemodify(filename, ":t")
            local file_hl = utils.highlight_fname(tail)
            return lsp_entry_display {
                { utils.lsp_symbols[entry.kind] or entry.kind, hl },
                { name,                          utils.lsp_highlights[entry.kind] },
                { tail,                          file_hl },
            }
        end
    }
end

local quickfix_entry_display
local quickfix_entry_maker = function(entry)
    if not quickfix_entry_display then
        quickfix_entry_display = require("telescope.pickers.entry_display").create {
            separator = " ",
            items = {
                { width = MAX_FILENAME_WIDTH },
                { width = MAX_FILEPARENT_WIDTH },
                { width = ROW_COL_WIDTH },
                { remaining = true }
            }
        }
    end

    local filename = entry.filename or vim.api.nvim_buf_get_name(entry.buf)

    return {
        value = entry,
        ordinal = filename .. " " .. entry.text,
        filename = filename,
        col = entry.col,
        lnum = entry.lnum,
        text = entry.text,
        display = function()
            local tail = vim.fn.fnamemodify(filename, ":t")
            local parentdir = vim.fn.pathshorten(vim.fn.fnamemodify(filename, ":~:.:h"), 6)
            local filename_highlight = utils.highlight_fname(tail)

            tail = strlib.truncate(tail, MAX_FILENAME_WIDTH, "~")
            parentdir = strlib.truncate(parentdir, MAX_FILEPARENT_WIDTH, "~")

            return quickfix_entry_display {
                { tail,                                   filename_highlight },
                { parentdir,                              "NonText" },
                { ("%d:%d"):format(entry.lnum, entry.col), "Number" },
                { entry.text }
            }
        end
    }
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
    path_display = path_display,
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
}

local lsp_config = default_config {
    jump_type = "drop",
    reuse_win = true,
    layout_config = {
        preview_width = 0.6,
    },
    entry_maker = quickfix_entry_maker
}

M.opts.pickers = {
    lsp_definitions = lsp_config,
    lsp_references = lsp_config,
    lsp_workspace_symbols = default_config {
        entry_maker = lsp_symbol_entry_maker,
    },
    lsp_document_symbols = default_config {
        entry_maker = lsp_symbol_entry_maker,
    },
    diagnostics = default_config {
        disable_coordinates = true,
    },
    live_grep = default_config {
        entry_maker = line_and_column_entry_maker
    },
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
    find_files = default_config {
        entry_maker = file_entry_maker
    },
    git_files = default_config {
        entry_maker = file_entry_maker
    },
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
    local map = utils.map
    for picker, keys in pairs(picker_maps) do
        map("n", keys, builtin[picker])
    end
end

return M
