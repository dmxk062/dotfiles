local colors = require("nord.named_colors")

local nord = {}
nord.normal = {
	a = { fg = colors.black, bg = colors.black },
	b = { fg = colors.white, bg = colors.light_gray },
	c = { fg = colors.white, bg = colors.black },
	y = { fg = colors.white, bg = colors.light_gray },
    z = { fg = colors.black, bg = colors.teal },
}

nord.insert = {
	a = { fg = colors.black, bg = colors.black },
	b = { fg = colors.white, bg = colors.light_gray },
	y = { fg = colors.white, bg = colors.light_gray },
    z = { fg = colors.white, bg = colors.light_gray },
}

nord.visual = {
	a = { fg = colors.black, bg = colors.black },
	b = { fg = colors.white, bg = colors.light_gray },
	y = { fg = colors.white, bg = colors.light_gray },
    z = { fg = colors.black, bg = colors.blue },
}

nord.replace = {
	a = { fg = colors.black, bg = colors.black },
	b = { fg = colors.white, bg = colors.light_gray },
	y = { fg = colors.white, bg = colors.light_gray },
    z = { fg = colors.black, bg = colors.red },
}

nord.command = {
	a = { fg = colors.black, bg = colors.black },
	b = { fg = colors.white, bg = colors.light_gray },
	y = { fg = colors.white, bg = colors.light_gray },
    z = { fg = colors.black, bg = colors.purple },
}

nord.inactive = {
	a = { fg = colors.black, bg = colors.black },
	b = { fg = colors.white, bg = colors.light_gray },
	y = { fg = colors.white, bg = colors.light_gray },
    z = { fg = colors.black, bg = colors.black },
}
local bubble = {left = "", right = ""}
local lbubble = {left = ""}
local rbubble = {right = ""}



local spacing = {
    function()
        return " "
    end,
    color = { bg = colors.black, fg = colors.black }
}

local branch = {
    "branch",
    fmt = function(str)
        if str == "" then
            return "None"
        else
            return str .. ":"
        end
    end,
    icon = "",
    separator = lbubble,
    color = { bg = colors.dark_gray, fg = colors.white},
}

local modecolors = {
    n = { bg = colors.teal, fg = colors.black},
    i = { bg = colors.light_gray, fg = colors.white, gui = "italic"},
    c = { bg = colors.purple, fg = colors.black},
    v = { bg = colors.blue, fg = colors.black},
    V = { bg = colors.blue, fg = colors.black},
    [""] = { bg = colors.glacier, fg = colors.black},
    R = { bg = colors.red, fg = colors.black, gui = "bold"},
    no = { bg = colors.teal, fg = colors.black, gui = "italic"},
    ["!"] = {bg = colors.teal, fg = colors.black},
    t = { bg = colors.teal, fg = colors.black},
    nt = { bg = colors.teal, fg = colors.black},
    s = { bg = colors.teal, fg = colors.black, gui = "italic"},
}
local mode = {
    "mode",
    icons_enabled = true,
    fmt = function(str)
        return string.lower(str)
    end,
    color = function()
        return modecolors[vim.fn.mode(1)]
    end,
    separator = bubble,
}

local position = {
}

local function min_window_width(width)
    return function() return vim.fn.winwidth(0) > width end
end

local function getWords()
    local wc = vim.fn.wordcount()
    if wc["visual_words"] then -- text is selected in visual mode
        return wc["visual_words"] .. "w" .. "/" .. wc['visual_chars'] .. "c"
    else 
        return wc["words"] .. "w"
    end
end

local function search_progress()
    if vim.v.hlsearch == 0 then
        return ''
    end

    local ok, res = pcall(vim.fn.searchcount, {maxcount = 999, timeout = 500})
    if not ok or next(res) == nil then
        return ''
    end
    local found = math.min(res.total, res.maxcount)
    return string.format('%d/%d', res.current, found)
end

require('lualine').setup {
    options = {
        -- icons_enabled = true,
        theme = nord,
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
            statusline = 1000,
            winbar = 1000,
        },
        disabled_filetypes = {
            statusline = {
                "alpha", "TelescopePrompt"
            },
        },
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
    },
    sections = {
        lualine_a = {
            mode,
        },
        lualine_b = {
            {
                'filename',
                icons_enabled = true,
                padding = {left = 2, right = 2 },
                icon = {'󰈔', align='left'},
                separator = rbubble,
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
                separator = {right = ""},
                color = {fg = colors.white, bg = colors.dark_gray},
                sources = { 'nvim_lsp', 'coc' },
                sections = { 'error', 'warn', 'info', 'hint' },

                diagnostics_color = {
                    error = {fg = colors.red},
                    warn  = {fg = colors.orange},
                    info  = {fg = colors.blue},
                    hint  = {fg = colors.cyan},
                },
                symbols = {error = '󰅖 ', warn = ' ', info = ' ', hint = '󰟶 '},
                colored = true,         
                update_in_insert = false,
                always_visible = false,  
            },
        },
        lualine_d = {},
        lualine_x = {
            branch,
            {
                'diff',
                color = {bg = colors.dark_gray},
                colored = true,
                diff_color = {
                    added    = {fg = colors.green},
                    modified = {fg = colors.yellow},
                    removed  = {fg = colors.red}
                },
                source = function()
                    if vim.b.gitsigns_status_dict then
                        local signs = vim.b.gitsigns_status_dict
                        return {
                            added    = signs.added,
                            removed  = signs.removed,
                            modified = signs.changed,
                        }
                    end
                end,
            }
        },
        lualine_y = {
            {
                separator = lbubble,
                'filetype',
                colored = false,
            },
            {
                'fileformat',
                symbols = {
                    unix = '',
                    dos = '\\r\\n',
                    mac = '\\r',
                }
            }, 
        },
        lualine_z = {
            {
                'location',
                separator = lbubble,
            },
            {
                search_progress,
                icon = "󰈞",
            }, 
            {
                getWords,
                separator = rbubble,
            }
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
    tabline = {},
    -- extensions = {"oil"},
    winbar = {},
    inactive_winbar = {}
}
