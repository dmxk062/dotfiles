local M = {
    -- enabled = false,
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-omni",
    }
}

local kind_symbols = require("config.utils").lsp_symbols

local hlleader = "CmpItemKind"

---@alias vim_item {word: string, abbr: string, menu: string, info: string, kind: string, icase: boolean, user_data: string|table, kind_hl_group: string}

---@param text string
---@param max integer?
---@return string
local function shorten_name(text, max)
    max = max or 40
    local length = vim.fn.strdisplaywidth(text)
    if length <= max then
        return text
    end

    local fn_name, fn_args, fn_suff = text:match("([%w_]+)%((.*)%)(.*)$")
    -- try to simplify abbreviated functions
    if fn_args then
        return fn_name .. ("(%d …)"):format(#vim.split(fn_args, ",")) .. fn_suff
    else
        return text:sub(1, max - 1) .. "…"
    end
end

---@param entry table
---@param vitem vim_item
local function format_entry(entry, vitem)
    local kind = vitem.kind
    if entry.source.name == "vimtex" then
        kind = "Latex"
        vitem.kind_hl_group = hlleader .. "Latex"
    elseif entry.source.name == "neorg" then
        kind = "Neorg"
        vitem.kind_hl_group = hlleader .. "Neorg"
    elseif entry.source.name == "cmdline" then
        kind = "Cmd"
    end
    vitem.abbr = shorten_name(vitem.abbr)
    vitem.kind = kind_symbols[kind] or kind_symbols.Text
    return vitem
end

M.opts = {
    performance = {
        max_view_entries = 24,
    },
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
    formatting = {
        format = format_entry,
    },
    window = {
        completion = {
            border = "rounded",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
            scrollbar = false,
        },
        documentation = {
            border = "rounded",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:CursorLine,Search:None",
            scrollbar = false,
        }
    },
    sources = {
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "snippet" },
        { name = "buffer" },
    },
    sorting = {},
    experimental = {}

}

M.config = function(_, opts)
    local cmp = require("cmp")
    local compare = cmp.config.compare

    opts.mapping = {
        ["<C-e>"] = function(fallback)
            if cmp.visible() then
                cmp.abort()
            else
                fallback()
            end
        end,
        ["<C-n>"] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                cmp.complete()
            end
        end,
        ["<C-p>"] = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                cmp.complete()
            end
        end,
        ["<C-space>"] = cmp.mapping.confirm {
            select = true,
            behavior = cmp.ConfirmBehavior.Replace
        },
    }
    opts.sorting.comparators = {
        compare.offset,
        compare.exact,
        compare.scopes,
        compare.score,
        compare.recently_used,
        compare.locality,
        compare.kind,
        compare.order,
    }

    cmp.setup(opts)

    cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline({}),
        sources = cmp.config.sources({
            { name = "buffer" },
        })
    })

    cmp.setup.cmdline({ ":" }, {
        mapping = cmp.mapping.preset.cmdline({}),
        sources = cmp.config.sources(
            {
                { name = "path" }
            },
            {
                {
                    name = "cmdline",
                    option = {
                        ignore_cmds = {}
                    }
                }
            }
        )
    })
    cmp.setup.filetype("DressingInput", {
        mapping = {
            ["<Tab>"] = function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                else
                    cmp.complete()
                end
            end,
            ["<cr>"] = function(fallback) fallback() end
        },
        sources = cmp.config.sources({
            { name = "omni" },
        })
    })
    cmp.setup.filetype("oil", {
        sources = cmp.config.sources({
            {
                name = "path",
                option = {
                    get_cwd = function()
                        -- local pwd if ssh
                        return require("oil").get_current_dir() or vim.fn.getcwd()
                    end
                }
            },
            { name = "snippet" },
            { name = "buffer" },
        })
    })

    require("config.snippets").setup() -- my own snippet engine for this
end

return M
