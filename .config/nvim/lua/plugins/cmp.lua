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
        "f3fora/cmp-spell",
    }
}

local kind_symbols = {
    Text          = "󰉿 txt",
    Method        = "󰊕 method",
    Function      = "󰊕 func",
    Constructor   = "󰙴 init",
    Field         = ". field",
    Variable      = "α var",
    Class         = "󰅩 class",
    Interface     = " type",
    Module        = " mod",
    Property      = ". prop",
    Unit          = "󰑭 unit",
    Value         = "󰎠 val",
    Enum          = " enum",
    EnumMember    = " enum",
    Keyword       = " keywd",
    Snippet       = " snip",
    Color         = "󰏘 color",
    File          = "󰈙 file",
    Reference     = "󰌷 ref",
    Folder        = " dir",
    Constant      = "π const",
    Struct        = "󰅩 struct",
    Event         = "! event",
    Operator      = "± op",
    TypeParameter = " param",
    Latex         = " tex",
    Neorg         = "󱞁 norg",
    Omnifunc      = " omni",
}

local hlleader = "CmpItemKind"

---@alias vim_item {word: string, abbr: string, menu: string, info: string, kind: string, icase: boolean, user_data: string|table, kind_hl_group: string}

---heuristics to determine the type of completion of a omnifunc
---@param vitem vim_item
---@return string|nil
---@return string|nil
local function get_omni_kind(vitem)
    -- *might* also just be a string with that content, but i rarely use cmp for that sort of thing anyways
    if vim.uv.fs_stat(vim.fn.expand(vitem.word)) then
        if vitem.word:sub(-1) == "/" then
            return "Folder", hlleader .. "Folder"
        else
            return "File", hlleader .. "File"
        end
    end
end

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
    elseif entry.source.name == "omni" then
        kind = "Omnifunc"
        local infered_kind, hl = get_omni_kind(vitem)
        if infered_kind and hl then
            kind = infered_kind
            vitem.kind_hl_group = hl
        end
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
    experimental = {
        -- ghost_text = true,
    }

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
        ["<CR>"] = cmp.mapping.confirm { select = true, behavior = cmp.ConfirmBehavior.Replace },
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

    cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
            { name = "snippet" },
            { name = "buffer" },
        })
    })


    cmp.setup.filetype("markdown", {
        sources = cmp.config.sources({
            { name = "snippet" },
            { name = "path" },
            { name = "buffer" },
            { name = "nvim_lsp" },
            { name = "spell" } -- move spell to the bottom so it doesnt slow it down that much
        })
    })
    cmp.setup.filetype("norg", {
        sources = cmp.config.sources({
            { name = "neorg" },
            { name = "snippet" },
            { name = "path" },
            { name = "buffer" },
            { name = "spell" } -- move spell to the bottom so it doesnt slow it down that much
        })
    })
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
        mapping = cmp.mapping.preset.cmdline({}),
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
            { name = "nvim_lsp" },
        })
    })

    require("modules.snippets").setup()
end

return M
