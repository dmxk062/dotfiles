local M = {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
}

local colors = require("nord.colors")

local nord = {}
nord.normal = {
    a = { fg = colors.nord0_gui, bg = colors.nord0_gui },
    b = { fg = colors.nord6_gui, bg = colors.nord3_gui },
    c = { fg = colors.nord6_gui, bg = colors.nord0_gui },
    y = { fg = colors.nord6_gui, bg = colors.nord3_gui },
    z = { fg = colors.nord0_gui, bg = colors.nord7_gui },
}

nord.insert = {
    a = { fg = colors.nord0_gui, bg = colors.nord0_gui },
    b = { fg = colors.nord6_gui, bg = colors.nord3_gui },
    y = { fg = colors.nord6_gui, bg = colors.nord3_gui },
    z = { fg = colors.nord6_gui, bg = colors.nord3_gui },
}

nord.visual = {
    a = { fg = colors.nord0_gui, bg = colors.nord0_gui },
    b = { fg = colors.nord6_gui, bg = colors.nord3_gui },
    y = { fg = colors.nord6_gui, bg = colors.nord3_gui },
    z = { fg = colors.nord0_gui, bg = colors.nord10_gui },
}

nord.replace = {
    a = { fg = colors.nord0_gui, bg = colors.nord0_gui },
    b = { fg = colors.nord6_gui, bg = colors.nord3_gui },
    y = { fg = colors.nord6_gui, bg = colors.nord3_gui },
    z = { fg = colors.nord0_gui, bg = colors.nord11_gui },
}

nord.command = {
    a = { fg = colors.nord0_gui, bg = colors.nord0_gui },
    b = { fg = colors.nord6_gui, bg = colors.nord3_gui },
    y = { fg = colors.nord6_gui, bg = colors.nord3_gui },
    z = { fg = colors.nord0_gui, bg = colors.nord15_gui },
}

nord.inactive = {
    a = { fg = colors.nord0_gui, bg = colors.nord0_gui },
    b = { fg = colors.nord6_gui, bg = colors.nord3_gui },
    y = { fg = colors.nord6_gui, bg = colors.nord3_gui },
    z = { fg = colors.nord0_gui, bg = colors.nord0_gui },
}
local bubble = { left = "", right = "" }
local lbubble = { left = "" }
local rbubble = { right = "" }


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
    color = { bg = colors.nord1_gui, fg = colors.nord6_gui },
}

local modecolors = {
    n = { bg = colors.nord7_gui, fg = colors.nord0_gui },
    i = { bg = colors.nord3_gui, fg = colors.nord6_gui, gui = "italic" },
    c = { bg = colors.nord15_gui, fg = colors.nord0_gui },
    v = { bg = colors.nord10_gui, fg = colors.nord0_gui },
    V = { bg = colors.nord10_gui, fg = colors.nord0_gui },
    [""] = { bg = colors.nord9_gui, fg = colors.nord0_gui },
    R = { bg = colors.nord11_gui, fg = colors.nord0_gui, gui = "bold" },
    no = { bg = colors.nord7_gui, fg = colors.nord0_gui, gui = "italic" },
    ["!"] = { bg = colors.nord7_gui, fg = colors.nord0_gui },
    t = { bg = colors.nord7_gui, fg = colors.nord0_gui },
    nt = { bg = colors.nord7_gui, fg = colors.nord0_gui },
    s = { bg = colors.nord7_gui, fg = colors.nord0_gui, gui = "italic" },
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

local function getWords()
    local wc = vim.fn.wordcount()
    if wc["visual_words"] then -- text is selected in visual mode
        return wc["visual_words"] .. "w" .. "/" .. wc["visual_chars"] .. "c"
    else
        return wc["words"] .. "w"
    end
end

local function search_progress()
    if vim.v.hlsearch == 0 then
        return ""
    end

    local ok, res = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 500 })
    if not ok or next(res) == nil then
        return ""
    end
    local found = math.min(res.total, res.maxcount)
    return string.format("%d/%d", res.current, found)
end
local lualine_layout = {
    lualine_a = {
        mode,
    },
    lualine_b = {
        {
            "filename",
            icons_enabled = true,
            padding = { left = 2, right = 2 },
            icon = { "󰈔", align = "left" },
            separator = rbubble,
            path = 4,
            file_status = true,
            newfile_status = true,
            shortening_target = 40,
            symbols = {
                modified = "[+]",
                readonly = "[ ro]",
                unamed = "[No Name]",
                newfile = "[New]",
            }
        }
    },
    lualine_c = {
        {
            "diagnostics",
            separator = { right = "" },
            color = { fg = colors.nord6_gui, bg = colors.nord1_gui },
            sources = { "nvim_lsp", "coc" },
            sections = { "error", "warn", "info", "hint" },

            diagnostics_color = {
                error = { fg = colors.nord11_gui },
                warn  = { fg = colors.nord12_gui },
                info  = { fg = colors.nord10_gui },
                hint  = { fg = colors.nord7_gui },
            },
            symbols = { error = "󰅖 ", warn = " ", info = " ", hint = "󰟶 " },
            colored = true,
            update_in_insert = false,
            always_visible = false,
        },
    },
    lualine_d = {},
    lualine_x = {
        branch,
        {
            "diff",
            color = { bg = colors.nord1_gui },
            colored = true,
            diff_color = {
                added    = { fg = colors.nord14_gui },
                modified = { fg = colors.nord13_gui },
                removed  = { fg = colors.nord11_gui }
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
            "filetype",
            colored = false,
        },
        {
            "fileformat",
            symbols = {
                unix = "",
                dos = "\\r\\n",
                mac = "\\r",
            }
        },
    },
    lualine_z = {
        {
            "location",
            separator = lbubble,
        },
        {
            search_progress,
            icon = "󰈞",
        },
        {
            getWords,
            separator = rbubble,
        },
        {
            function()
                if not vim.b[0].creation_time then
                    return ""
                end
                local now = os.time()
                return vim.fn.strftime("%M:%S", now - vim.b[0].creation_time)
            end
        }
    }
}

M.config = function()
    vim.api.nvim_create_autocmd({"BufNew", "VimEnter"}, {
        callback = function(opts)
            vim.b[opts.buf].creation_time = os.time()
        end
    })
    require("lualine").setup {
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
                    -- "alpha",
                    -- "TelescopePrompt"
                },
            },
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
        },
        sections = lualine_layout,
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
end


return M
