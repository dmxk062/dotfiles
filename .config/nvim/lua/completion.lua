require("snip")

local lspkind = require("lspkind")
local cmp = require("cmp")

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
    },
    formatting = {
        format = lspkind.cmp_format({mode = "symbol",
        symbol_map = {
            Text = "󰉿 txt",
            Method = "󰆧 method",
            Function = "󰊕 func",
            Constructor = " constructor",
            Field = "󰽐 field",
            Variable = "α var",
            Class = "󰠱 class",
            Interface = " type",
            Module = " module",
            Property = "󰜢 prop",
            Unit = "󰑭 unit",
            Value = "󰎠 val",
            Enum = " enum",
            Keyword = "󰌋 keywd",
            Snippet = " snip",
            Color = "󰏘 color",
            File = "󰈙 file",
            Reference = "󰈇 ref",
            Folder = " dir",
            EnumMember = " enum Member",
            Constant = "󰏿 const",
            Struct = "󰙅 struct",
            Event = " event",
            Operator = "󰆕 op",
            TypeParameter = " param",
        },
    }),
},
window = {
    completion = {
        border='rounded',
        winhighlight= 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
    },
    documentation = { 
        border='rounded',
        winhighlight= 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:CursorLine,Search:None',
    }
},
mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<M-j>"] = cmp.mapping.select_next_item(),
    ["<M-k>"] = cmp.mapping.select_prev_item(),
}),
sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
    { name = "buffer" },
})
})

cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({
        { name = "git" }, 
    }, {
        { name = "buffer" },
    })
})


cmp.setup.filetype("markdown", {
    sources = cmp.config.sources({
        { name = "luasnip" },
        { name = "path" },
        { name = "buffer" },
        { name = "nvim_lsp" },
        { name = "spell" } -- move spell to the bottom so it doesnt slow it down that much
    })
})
cmp.setup.cmdline({ "/", "?"}, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" }
    }
})

cmp.setup.cmdline(":", {
    sources = cmp.config.sources({
        { name = "path" },
        { name = "cmdline" },
    })
})
