-- Spec {{{
local picker_maps = {
    buffers = "<space><space>",
    diagnostics = "<space>D",
    find_files = "<space>F",
    git_files = "<space>gf",
    git_status = "<space>gi",
    help_tags = "<space>h",
    jumplist = "<space><C-o>",
    live_grep = "<space>/",
    lsp_document_symbols = "<space>v",
    lsp_workspace_symbols = "<space>V",
    man_pages = "<space>H",
    oldfiles = "<space>o",
    search_history = "<space>?",
}

---@type LazySpec
local M = {
    "nvim-telescope/telescope.nvim",
    keys = vim.tbl_values(picker_maps),
    cmd = { "Telescope" },
    dependencies = {
        {
            "natecraddock/telescope-zf-native.nvim"
        },
        {
            "nvim-telescope/telescope-ui-select.nvim"
        }
    },
}

-- HACK: lazy load the ui select provider
M.init = function()
    vim.ui.select = function(...)
        require("telescope")
        return vim.ui.select(...)
    end
end
-- }}}

local utils = require("config.utils")

--[[ Custom Layouts {{{
Place prompt at bottom of screen, list and preview above it
]]

local function make_windows(results_conf, preview_conf, prompt_conf)
    local Layout = require("telescope.pickers.layout")

    local function make_win(enter, opts)
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

    return make_win(false, results_conf), preview_conf and make_win(false, preview_conf), make_win(true, prompt_conf)
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

local function create_layout(picker)
    local Layout = require("telescope.pickers.layout")
    local layout = Layout {
        picker = picker,
        mount = function(self)
            local width = vim.o.columns
            local factor = 0.45
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

            self.results, self.preview, self.prompt = make_windows({
                row = row,
                col = 0,
                width = fhalf,
                height = view_height,
                border = { "─", "─", "─", " ", "", "", "", "" },
            }, {
                row = row,
                col = fhalf + 2,
                width = shalf - 2,
                height = view_height + 1,
                border = { "┬", "─", "─", "", "", "", "", "│" },
            }, {
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
        update = function(self)
        end
    }

    return layout
end

-- requires preview to be disabled
local function short_layout(picker)
    local Layout = require("telescope.pickers.layout")
    return Layout {
        mount = function(self)
            local columns = vim.o.columns
            local lines = vim.o.lines

            local height = picker.layout_config.height or 12
            if type(height) == "function" then
                height = height()
            end
            local width = picker.layout_config.width or math.floor(columns * 0.4)
            if type(width) == "function" then
                width = width()
            end


            self.results, _, self.prompt = make_windows({
                row = lines - height - 5,
                col = 0,
                width = width,
                height = height,
                border = { "╭", "─", "╮", "│", "", "", "", "│" },
            }, nil, {
                row = lines - 4,
                col = 0,
                width = width,
                height = 1,
                border = { "│", "", "│", "─", "╯", "─", "╰", "│" },
            })
        end,
        unmount = function(self)
            destroy_win(self.results)
            destroy_win(self.prompt)
        end,
        update = function(self)
        end
    }
end

local MIN_FILENAME_WIDTH = 80
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

--[[ Entry Makers {{{
Why redo them?
Cause the builtin ones kinda suck sometimes :(
]]

local MAX_FILENAME_WIDTH = 24
local MAX_FILEPARENT_WIDTH = 24
local ROW_COL_WIDTH = 11

local function get_names_and_hl(path)
    local tail = vim.fn.fnamemodify(path, ":t")
    local parentdir = vim.fn.pathshorten(vim.fn.fnamemodify(path, ":~:.:h"), 6)
    local filename_highlight = utils.highlight_fname(tail)

    return tail, parentdir, filename_highlight
end

--[[ Grep {{{
File Name, Parent, Row:Col, Match
]]
local line_and_col_display
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


    return {
        value = line,
        display = function()
            local tail, parentdir, filename_highlight = get_names_and_hl(filename)

            return line_and_col_display {
                { tail,                       filename_highlight },
                { parentdir,                  "NonText" },
                { ("%d:%d"):format(row, col), "Number" },
                { text },
            }
        end,
        ordinal = string.format("%s:%s:%d", text, filename, row),
        lnum = row,
        col = col,
        filename = filename
    }
end
-- }}}

--[[ Plain File Names {{{
Name, Parent
]]
local file_display
local file_entry_maker = function(line)
    local max_name_width = MAX_FILENAME_WIDTH * 2

    if not file_display then
        file_display = require("telescope.pickers.entry_display").create {
            separator = " ",
            items = {
                { width = max_name_width },
                { width = 12 },
                { remaining = true,      right_justify = true },
            }
        }
    end


    return {
        value = line,
        display = function(entry)
            local value = entry.value

            local tail, parentdir, filename_highlight = get_names_and_hl(value)
            local st = vim.uv.fs_stat(entry.value)
            local mtime, timehl
            if not st then
                mtime = ""
                timehl = ""
            else
                mtime = os.date("%b %d %H:%M", st.mtime.sec)
                timehl = utils.highlight_time(st.mtime.sec)
            end


            return file_display {
                { tail,      filename_highlight },
                { mtime,     timehl },
                { parentdir, "NonText" }
            }
        end,
        filename = line,
        ordinal = line,
    }
end
-- }}}

--[[ Lsp Symbols {{{
Icon + Type, Name, File, Parent
]]
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
                { remaining = true }
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
        ordinal = string.format("%s:%s:%s:%d", entry.kind, name, filename, entry.lnum),
        display = function()
            -- use same highlights as cmp
            local hl = "BlinkCmpKind" .. entry.kind
            local tail, parentdir, filename_highlight = get_names_and_hl(filename)

            return lsp_entry_display {
                { utils.lsp_symbols[entry.kind] or entry.kind, hl },
                { name,                                        utils.lsp_highlights[entry.kind] },
                { tail,                                        filename_highlight },
                { parentdir,                                   "NonText" }
            }
        end
    }
end
-- }}}

--[[ Quickfix list {{{
Filename, Parent, Row:Column
]]
local quickfix_entry_display
local quickfix_entry_maker = function(entry)
    if not quickfix_entry_display then
        quickfix_entry_display = require("telescope.pickers.entry_display").create {
            separator = " ",
            items = {
                { width = MAX_FILENAME_WIDTH },
                { width = MAX_FILEPARENT_WIDTH },
                { width = ROW_COL_WIDTH },
                { remaining = true },
            }
        }
    end

    local filename = entry.filename or vim.api.nvim_buf_get_name(entry.buf)

    return {
        value = entry,
        ordinal = string.format("%s:%s:%d", entry.text, filename, entry.lnum),
        filename = filename,
        col = entry.col,
        lnum = entry.lnum,
        text = entry.text,
        display = function()
            local tail, parentdir, filename_highlight = get_names_and_hl(filename)
            return quickfix_entry_display {
                { tail,                                    filename_highlight },
                { parentdir,                               "NonText" },
                { ("%d:%d"):format(entry.lnum, entry.col), "Number" },
                { entry.text },
            }
        end
    }
end
-- }}}

-- Buffers {{{
local buffer_entry_display
local buffer_entry_maker = function(entry)
    if not buffer_entry_display then
        buffer_entry_display = require("telescope.pickers.entry_display").create {
            separator = " ",
            items = {
                { width = 4 },        -- shorthand number
                { width = 4 },        -- "real" number
                { width = 1 },        -- status.hidden
                { width = 4 },        -- status.readonly
                { width = 1 },        -- status.modified
                { width = 2 },        -- buffer kind
                { width = 4 },        -- line
                { remaining = true }, -- buffer name
            }
        }
    end

    local buf = entry.bufnr
    local shortbuf = Short_for_bufs[buf]
    local name, kind, show_modified = utils.format_buf_name(buf)
    local kindicon = utils.btypesymbols[kind]

    return {
        value = name,
        bufnr = buf,
        ordinal = string.format("%s:%s:%d:%d", kindicon, name, shortbuf or 0, buf),
        display = function()
            return buffer_entry_display {
                { shortbuf or "nil",                    shortbuf and "Number" or "NonText" },
                { buf,                                  "Number" },
                { entry.info.hidden == 1 and "." or "", entry.info.hidden == 1 and "NonText" },
                (vim.bo[buf].readonly
                    and { "[ro]", "NonText" }
                    or { "[rw]", "String" }),
                { entry.info.changed == 1 and show_modified and "~" or "", "Constant" },
                { kindicon,                                                "SlI" .. utils.btypehighlights[kind] },
                { ":" .. entry.info.lnum ~= 0 and entry.info.lnum or 1,    "Number" },
                { name }
            }
        end
    }
end
-- }}}

-- Diagnostics {{{
local diagnostics_display
local diagnostics_entry_maker = function(entry)
    if not diagnostics_display then
        diagnostics_display = require("telescope.pickers.entry_display").create {
            separator = " ",
            items = {
                { width = 1 },
                { width = 60 },
                { width = 9 },
                { width = MAX_FILENAME_WIDTH },
                { remaining = true }
            }
        }
    end

    local type = entry.type:sub(1, 1)

    -- lots of lsps suggest fixes there
    local text = entry.text:gsub("%s*%(.*%)%s*$", "")

    return {
        value = entry,
        filename = entry.filename,
        type = type,
        qf_type = type,
        lnum = entry.lnum,
        col = entry.col,
        text = text,
        ordinal = ("%s:%s:%s"):format(type, entry.filename, entry.text),
        display = function()
            local tail, parentdir, filename_highlight = get_names_and_hl(entry.filename)
            return diagnostics_display {
                { type,                                          "DiagnosticSign" .. entry.type },
                { text },
                { string.format("%d:%d", entry.lnum, entry.col), "Number" },
                { tail,                                          filename_highlight },
                { parentdir,                                     "NonText" },
            }
        end,
    }
end
-- }}}
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
            ["<cr>"]  = "select_default",
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
            ["<cr>"]   = "select_default",
            ["<C-cr>"] = "select_vertical",
            ["<S-cr>"] = "select_horizontal",
            ["<M-j>"]  = "move_selection_next",
            ["<M-k>"]  = "move_selection_previous",
            ["<Down>"] = "move_selection_next",
            ["<Up>"]   = "move_selection_previous",
            ["<C-t>"]  = "select_tab",
            ["<C-e>"]  = "file_edit",
            ["<C-s>"]  = "select_horizontal",
            ["<C-v>"]  = "select_vertical",
        }
    },
    dynamic_preview_title = true,
    results_title = false,
    selection_caret = "",
    entry_prefix = "",
    multi_icon = "",
    prompt_prefix = ":e ",
}

local lsp_config = default_config {
    jump_type = "drop",
    reuse_win = true,
    layout_config = {
        preview_width = 0.6,
    },
    entry_maker = quickfix_entry_maker
}

local qfconfig = default_config {
    entry_maker = quickfix_entry_maker
}

M.opts.pickers = {
    lsp_definitions = lsp_config,
    lsp_references = lsp_config,
    loclist = qfconfig,
    lsp_workspace_symbols = default_config {
        entry_maker = lsp_symbol_entry_maker,
    },
    lsp_document_symbols = default_config {
        entry_maker = lsp_symbol_entry_maker,
    },
    diagnostics = default_config {
        entry_maker = diagnostics_entry_maker,
    },
    live_grep = default_config {
        entry_maker = line_and_column_entry_maker
    },
    oldfiles = default_config {
        entry_maker = file_entry_maker,
    },
    buffers = default_config {
        entry_maker = buffer_entry_maker,
        create_layout = short_layout,
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
                return math.floor(math.min(math.max(ln * 0.2, 12), 32))
            end,
            width = function()
                local col = vim.o.columns
                return math.floor(math.min(math.max(col * 0.3, 48), 60))
            end
        }
    },
    find_files = default_config {
        entry_maker = file_entry_maker
    },
    git_files = default_config {
        entry_maker = file_entry_maker
    },
    help_tags = default_config {
        prompt_prefix = ":h ",
        create_layout = short_layout,
        previewer = false,
    },
    man_pages = default_config {
        prompt_prefix = ":man ",
    },
    search_history = default_config {
        create_layout = short_layout,
    }
}

M.opts.extensions = {
    ["zf-native"] = {},
    ["ui-select"] = {
        create_layout = short_layout,
        layout_config = {
            height = 4,
        }
    }
}

-- }}}

M.config = function(_, opts)
    local telescope = require("telescope")

    telescope.setup(opts)
    telescope.load_extension("zf-native")
    telescope.load_extension("ui-select")

    local builtin = require("telescope.builtin")
    local map = utils.map
    for picker, keys in pairs(picker_maps) do
        map("n", keys, builtin[picker])
    end
end

return M
