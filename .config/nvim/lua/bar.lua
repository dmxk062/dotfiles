local function getWords()
    return tostring(vim.fn.wordcount().words)
end

local utils = require("lualine.utils.utils")
local highlight = require("lualine.highlight")

local diagnostics_message = require("lualine.component"):extend()

diagnostics_message.default = {
    colors = {
        error = utils.extract_color_from_hllist(
        { "fg", "sp" },
        { "DiagnosticError", "LspDiagnosticsDefaultError", "DiffDelete" }),
        warning = utils.extract_color_from_hllist(
        { "fg", "sp" },
        { "DiagnosticWarn", "LspDiagnosticsDefaultWarning", "DiffText" }),
        info = utils.extract_color_from_hllist(
        { "fg", "sp" },
        { "DiagnosticInfo", "LspDiagnosticsDefaultInformation", "DiffChange" }),
        hint = utils.extract_color_from_hllist(
        { "fg", "sp" },
        { "DiagnosticHint", "LspDiagnosticsDefaultHint", "DiffAdd" }),
    },
}
function diagnostics_message:init(options)
    diagnostics_message.super:init(options)
    self.options.colors = vim.tbl_extend("force", diagnostics_message.default.colors, self.options.colors or {})
    self.highlights = { error = "", warn = "", info = "", hint = "" }
    self.highlights.error = highlight.create_component_highlight_group(
    { fg = self.options.colors.error },
    "diagnostics_message_error",
    self.options
    )
    self.highlights.warn = highlight.create_component_highlight_group(
    { fg = self.options.colors.warn },
    "diagnostics_message_warn",
    self.options
    )
    self.highlights.info = highlight.create_component_highlight_group(
    { fg = self.options.colors.info },
    "diagnostics_message_info",
    self.options
    )
    self.highlights.hint = highlight.create_component_highlight_group(
    { fg = self.options.colors.hint },
    "diagnostics_message_hint",
    self.options
    )
end

function diagnostics_message:update_status(is_focused)
    local r, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local diagnostics = vim.diagnostic.get(0, { lnum = r - 1 })
    if #diagnostics > 0 then
        local top = diagnostics[1]
        for _, d in ipairs(diagnostics) do
            if d.severity < top.severity then
                top = d
            end
        end
        local hl = { self.highlights.error, self.highlights.warn, self.highlights.info, self.highlights.hint }
        local icons = { "Err: ", "Warn: ", "Info: ", "Hint: " }
        local length_max = vim.o.columns/5
        local message = top.message    
        if #message > length_max then
            message = string.sub(top.message, 1, length_max) .. "..."
        end
        return highlight.component_format_highlight(hl[top.severity])
        .. icons[top.severity]
        .. " "
        .. utils.stl_escape(message)
    else
        return ""
    end
end
local function min_window_width(width)
    return function() return vim.fn.winwidth(0) > width end
end
require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'nord',
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {
            statusline = {},
            winbar = {'NvimTree'},

        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        lualine_a = {
            {
                'branch',
            },
            {
                'mode'
            },
        },
        lualine_b = {
            {
                'filename',
                icons_enabled = true,
                padding = {left = 2, right = 2 },
                icon = {'', align='left'},
                path = 4,
                file_status = true,
                newfile_status = true,
                shortening_target = 40,
                symbols = {
                    modified = '[+]',
                    readonly = '[ ro]',
                    unamed = '[No Name]',
                    newfile = '[New]',
                }
            }
        },
        lualine_c = {
            {
                'diagnostics',

                -- Table of diagnostic sources, available sources are:
                --   'nvim_lsp', 'nvim_diagnostic', 'nvim_workspace_diagnostic', 'coc', 'ale', 'vim_lsp'.
                -- or a function that returns a table as such:
                --   { error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt }
                sources = { 'nvim_lsp', 'coc' },

                -- Displays diagnostics for the defined severity types
                sections = { 'error', 'warn', 'info', 'hint' },

                diagnostics_color = {
                    -- Same values as the general color option can be used here.
                    error = 'DiagnosticError', -- Changes diagnostics' error color.
                    warn  = 'DiagnosticWarn',  -- Changes diagnostics' warn color.
                    info  = 'DiagnosticInfo',  -- Changes diagnostics' info color.
                    hint  = 'DiagnosticHint',  -- Changes diagnostics' hint color.
                },
                symbols = {error = '  ', warn = '  ', info = '  ', hint = ' 󰌵 '},
                colored = true,           -- Displays diagnostics status in color if set to true.
                update_in_insert = false, -- Update diagnostics in insert mode.
                always_visible = false,   -- Show diagnostics even if there are none.
            },
            {
                diagnostics_message,
                colors = {
                    error = '#BF616A', -- Changes diagnostics' error color.
                    warn  = '#D08770',  -- Changes diagnostics' warn color.
                    info  = '#5E81Ac',  -- Changes diagnostics' info color.
                    hint  = '#88c0d0',  -- Changes diagnostics' hint color.
                }
            }
        },
        lualine_d = {

        },
        lualine_x = {},
        lualine_y = {
            {
                'searchcount', 
                maxcount = 65536,
                timeout = 500,
            }, 
            {
                'fileformat',
                symbols = {
                    unix = '',
                    dos = 'crlf',
                    mac = 'cr',
                }
            }, 
            {
                'filetype',
            }
        },
        lualine_z = {
            {
                'location',
            },
            {
                getWords,
                icon= {'Words', align='right'}
            },
        }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {
        lualine_a = {
            {
                'tabs',
                max_length = vim.o.columns-10,
                colored = true,
                mode = 3,
                use_mode_colors = true,
            },
        },
        lualine_b = {
            { 
                'filename',
                icons_enabled = true,
                icon = {'', align='left'},
                cond = min_window_width(150),
                padding= { left = 2, right = 0 },
                path = 3,
                file_status = true,
                newfile_status = true,
                shortening_target = 30,
                symbols = {
                    modified = '[+]',
                    readonly = '[]',
                    unamed = '[No Name]',
                    newfile = '[New]',
                }
            },
        },
        lualine_y = {
            { 
                'windows',
                mode = 2,
                colored = true,
            }
        },
        lualine_z = {
            {
                'datetime',
                style="%H:%M",
            }, 
        },
    },
    winbar = {},
    inactive_winbar = {
        lualine_a = {      
            {
                'filename',
                icons_enabled = true,
                icon = {'', align='left'},
                path = 4,
                file_status = true,
                newfile_status = true,
                shortening_target = 30,
                symbols = {
                    modified = '[+]',
                    readonly = '[]',
                    unamed = '[No Name]',
                    newfile = '[New]',
                }
            }
        },
        lualine_b={
            {
                'searchcount',
                maxcount=65536,
                tiemout=500,

            }
        },
        lualine_c = {
            'filetype',
        },
        lualine_z = {
            'location',
        },
    },
    extensions = {'nvim-tree','fzf'}
}
