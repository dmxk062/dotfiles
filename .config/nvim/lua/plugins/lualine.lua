local M = {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
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
    z = { fg = colors.nord0_gui, bg = colors.nord9_gui },
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



local modecolors = {
    n = { bg = colors.nord7_gui, fg = colors.nord0_gui },
    i = { bg = colors.nord3_gui, fg = colors.nord6_gui, gui = "italic" },
    c = { bg = colors.nord15_gui, fg = colors.nord0_gui },
    v = { bg = colors.nord9_gui, fg = colors.nord0_gui },
    V = { bg = colors.nord9_gui, fg = colors.nord0_gui },
    [""] = { bg = colors.nord9_gui, fg = colors.nord0_gui },
    R = { bg = colors.nord11_gui, fg = colors.nord0_gui, gui = "bold" },
    no = { bg = colors.nord7_gui, fg = colors.nord0_gui, gui = "italic" },
    ["!"] = { bg = colors.nord7_gui, fg = colors.nord0_gui },
    t = { bg = colors.nord7_gui, fg = colors.nord0_gui },
    nt = { bg = colors.nord7_gui, fg = colors.nord0_gui },
    s = { bg = colors.nord7_gui, fg = colors.nord0_gui, gui = "italic" },
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
    color = { fg = colors.nord6_gui, bg = colors.nord1_gui },

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
            color = { fg = colors.nord6_gui, bg = colors.nord1_gui },
            sources = { "nvim_lsp" },
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
            draw_empty = true, -- always draw the bubble
            separator = rbubble,
        },
    },
    lualine_x = {
        {
            "diff",
            color = { bg = colors.nord1_gui },
            colored = true,
            diff_color = {
                added    = { fg = colors.nord14_gui },
                modified = { fg = colors.nord15_gui },
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
end


return M
