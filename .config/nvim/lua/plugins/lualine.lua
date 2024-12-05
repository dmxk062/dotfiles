local M = {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
}

local theme = require("theme.colors")
local pal = theme.palettes.dark
local col = theme.colors

local nord = {}
nord.normal = {
    a = { fg = pal.bg0, bg = pal.bg0 },
    b = { fg = pal.fg0, bg = pal.bg3 },
    c = { fg = pal.fg0, bg = pal.bg0 },
    y = { fg = pal.fg0, bg = pal.bg3 },
    z = { fg = pal.bg0, bg = col.teal },
}

nord.insert = {
    a = { fg = pal.bg0, bg = pal.bg0 },
    b = { fg = pal.fg0, bg = pal.bg3 },
    y = { fg = pal.fg0, bg = pal.bg3 },
    z = { fg = pal.inverted, bg = pal.fg2 },
}

nord.visual = {
    a = { fg = pal.bg0, bg = pal.bg0 },
    b = { fg = pal.fg0, bg = pal.bg3 },
    y = { fg = pal.fg0, bg = pal.bg3 },
    z = { fg = pal.bg0, bg = col.light_blue },
}

nord.replace = {
    a = { fg = pal.bg0, bg = pal.bg0 },
    b = { fg = pal.fg0, bg = pal.bg3 },
    y = { fg = pal.fg0, bg = pal.bg3 },
    z = { fg = pal.bg0, bg = col.red },
}

nord.command = {
    a = { fg = pal.bg0, bg = pal.bg0 },
    b = { fg = pal.fg0, bg = pal.bg3 },
    y = { fg = pal.fg0, bg = pal.bg3 },
    z = { fg = pal.bg0, bg = col.green },
}

nord.inactive = {
    a = { fg = pal.bg0, bg = pal.bg0 },
    b = { fg = pal.fg0, bg = pal.bg3 },
    y = { fg = pal.fg0, bg = pal.bg3 },
    z = { fg = pal.bg0, bg = pal.bg0 },
}

local bubble = { left = "", right = "" }
local lbubble = { left = "" }
local rbubble = { right = "" }

local modecolors = {
    n = { bg = col.teal, fg = pal.bg0 },
    i = { bg = pal.fg2, fg = pal.inverted },
    c = { bg = col.green, fg = pal.bg0 },
    v = { bg = col.light_blue, fg = pal.bg0 },
    V = { bg = col.light_blue, fg = pal.bg0 },
    [""] = { bg = col.light_blue, fg = pal.bg0 },
    R = { bg = col.red, fg = pal.bg0 },
    no = { bg = col.teal, fg = pal.bg0 },
    noV = { bg = col.teal, fg = pal.bg0 },
    ["!"] = { bg = col.teal, fg = pal.bg0 },
    t = { bg = col.teal, fg = pal.bg0 },
    nt = { bg = col.teal, fg = pal.bg0 },
    s = { bg = col.light_blue, fg = pal.bg0, gui = "italic" },
}

local modenames = {
    [""]   = "^V",
    ["no"] = "^O",
    ["noV"] = "O",
    ["no"]  = "o",
    ["R"]   = "r",
}

local mode = {
    "mode",
    padding = 0,
    fmt = function(str)
        local mode = modenames[vim.api.nvim_get_mode().mode] or str:sub(1, 1):lower()
        if #mode == 1 then
            return " " .. mode .. " "
        else
            return mode .. " "
        end
    end,
    color = function()
        return modecolors[vim.api.nvim_get_mode().mode] or modecolors.n
    end,
    separator = bubble,
}


local lsp_infos = {
    function()
        local buf = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients { bufnr = buf }
        if #clients == 0 then
            return ""
        end

        local active_clients = {}
        for _, client in ipairs(clients) do
            local name
            if #client.name > 8 then
                name = client.name:sub(1, 8) .. "…"
            else
                name = client.name
            end

            table.insert(active_clients, name)
        end

        return table.concat(active_clients, ", ")
    end,
    color = { fg = pal.fg0, bg = pal.bg1 },
}



M.opts = {
    options = {
        theme = nord,
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
            statusline = 100,
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
    sections = {
        lualine_a = {
            mode,
        },
        lualine_b = {
            {
                "filename",
                icons_enabled = true,
                padding = { left = 2, right = 2 },
                separator = rbubble,
                path = 4,
                file_status = true,
                newfile_status = true,
                shortening_target = 40,
                symbols = {
                    modified = "[+]",
                    readonly = "[ro]",
                    unnamed = "[-]",
                    newfile = "[~]",
                }
            }
        },
        lualine_c = {
            lsp_infos,
            {
                "diagnostics",
                color = { fg = pal.fg0, bg = pal.bg1 },
                sources = { "nvim_lsp" },
                sections = { "error", "warn", "info", "hint" },

                diagnostics_color = {
                    error = { fg = col.red },
                    warn  = { fg = col.orange },
                    info  = { fg = col.blue },
                    hint  = { fg = col.teal },
                },
                symbols = { error = "e:", warn = "w:", info = "i:", hint = "h:" },
                colored = true,
                update_in_insert = false,
                always_visible = false,
                draw_empty = true, -- always draw the bubble
                separator = rbubble,
            },
            {
                function()
                    local reg = vim.fn.reg_recording()
                    if reg == "" then
                        -- show last register
                        local last = vim.fn.reg_recorded()
                        if last == "" then
                            return ""
                        end

                        return '["' .. last .. ']'
                    end
                    return '<"' .. reg .. '>'
                end,
                color = { fg = col.bright_gray },

            },
            {
                "%S",
            }
        },
        lualine_x = {
            {
                "%l:%c",
            },
            {
                "diff",
                color = { bg = pal.bg1 },
                colored = true,
                diff_color = {
                    added    = { fg = col.green },
                    modified = { fg = col.yellow },
                    removed  = { fg = col.red }
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
                draw_empty = true,
                separator = lbubble,
            }
        },
        lualine_y = {
            {
                "filetype",
                fmt = function(str)
                    if str == "" then
                        return "[noft]"
                    else
                        return str
                    end
                end,
                colored = false,
                icons_enabled = false,
                separator = lbubble,
            },
            {
                "fileformat",
                symbols = {
                    unix = "\\n",
                    dos = "\\r\\n",
                    mac = "\\r",
                },
            },
        },
        lualine_z = {
            {
                function()
                    local wc = vim.fn.wordcount()
                    if wc.visual_words then -- text is selected in visual mode
                        return wc.visual_words .. "w:" .. wc.visual_chars .. "c"
                    else
                        return wc.words .. "w"
                    end
                end,
                separator = bubble,
            },
        },
    }
}

M.config = function(_, opts)
    require("lualine").setup(opts)
    vim.o.showcmdloc = "statusline"

    -- refresh statusline on macro recording
    vim.api.nvim_create_autocmd("RecordingEnter", { callback = require("lualine").refresh })
    vim.api.nvim_create_autocmd("RecordingLeave", {
        callback = function()
            local timer = vim.uv.new_timer()
            timer:start(50, 0, vim.schedule_wrap(require("lualine").refresh))
        end
    })
end

return M
