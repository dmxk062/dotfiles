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
    z = { fg = pal.fg0, bg = pal.bg3 },
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
    z = { fg = pal.bg0, bg = col.magenta },
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
    i = { bg = pal.bg3, fg = pal.fg0, gui = "italic" },
    c = { bg = col.magenta, fg = pal.bg0 },
    v = { bg = col.light_blue, fg = pal.bg0 },
    V = { bg = col.light_blue, fg = pal.bg0 },
    [""] = { bg = col.light_blue, fg = pal.bg0 },
    R = { bg = col.red, fg = pal.bg0, gui = "bold" },
    no = { bg = col.teal, fg = pal.bg0, gui = "italic" },
    ["!"] = { bg = col.teal, fg = pal.bg0 },
    t = { bg = col.teal, fg = pal.bg0 },
    nt = { bg = col.teal, fg = pal.bg0 },
    s = { bg = col.teal, fg = pal.bg0, gui = "italic" },
}

local modenames = {
    ["V-LINE"] = "V",
    ["V-BLOCK"] = "^V"
}

local mode = {
    "mode",
    fmt = function(str)
        return modenames[str] or str:lower():sub(1, 1)
    end,
    color = function()
        return modecolors[vim.fn.mode(1)]
    end,
    separator = bubble,
}


local lsp_infos_show_all = false
local lsp_infos = {
    function()
        local icons = require("nvim-web-devicons")

        local buf = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients { bufnr = buf }
        if #clients == 0 then
            return ""
        end

        local active_clients = {}
        for _, client in ipairs(clients) do
            local lang = client.get_language_id(buf, vim.bo[buf].ft)
            local icon = icons.get_icon_by_filetype(lang or "")

            table.insert(active_clients, (icon and icon .. " " or "") .. client.name)
        end
        if lsp_infos_show_all then
            return table.concat(active_clients, ", ")
        else
            local ret = active_clients[1]
            if #active_clients > 1 then
                ret = ret .. " [+" .. #active_clients - 1 .. "]"
            end
            return ret or ""
        end
    end,

    ---@param num_clicks integer
    ---@param btn "l"|"r"|"m"
    ---@param mods "s"|"c"|"a"|"m"
    on_click = function(num_clicks, btn, mods)
        if btn == "r" then
            vim.api.nvim_command("LspInfo")
        elseif btn == "l" then
            lsp_infos_show_all = not lsp_infos_show_all
            require("lualine").refresh()
        end
    end,
    color = { fg = pal.fg0, bg = pal.bg1 },

}


local lualine_layout = {
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
            symbols = { error = "󰅖 ", warn = " ", info = " ", hint = "󰟶 " },
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
                    return ""
                end
                return [[macro -> "]] .. reg
            end,
            icon = { "󰌌", color = { fg = col.magenta, bold = true } }

        }
    },
    lualine_x = {
        {
            "diff",
            color = { bg = pal.bg1 },
            colored = true,
            diff_color = {
                added    = { fg = col.green },
                modified = { fg = col.magenta },
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
            separator = lbubble,
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
            "progress",
            separator = lbubble,
        },
        {
            function()
                if vim.v.hlsearch == 0 then
                    return ""
                end

                local ok, res = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 500 })
                if not ok or next(res) == nil then
                    return ""
                end
                local found = math.min(res.total, res.maxcount)
                return string.format("%d/%d", res.current, found)
            end,
        },
        {
            function()
                local wc = vim.fn.wordcount()
                if wc.visual_words then -- text is selected in visual mode
                    return wc.visual_words .. "w" .. "/" .. wc.visual_chars .. "c"
                else
                    return wc.words .. "w"
                end
            end,
            separator = rbubble,
        },
    }
}

M.config = function()
    require("lualine").setup {
        options = {
            -- icons_enabled = true,
            theme = nord,
            ignore_focus = {},
            always_divide_middle = true,
            globalstatus = true,
            refresh = {
                statusline = 1000,
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
    }

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
