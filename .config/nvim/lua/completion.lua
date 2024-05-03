local lspkind = require('lspkind')
 local cmp = require'cmp'
 require("snip")
  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
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
          Variable = "󰀫 var",
          Class = "󰠱 class",
          Interface = " interface",
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
          -- cmp.config.window.bordered(),
          border='rounded',
        winhighlight= 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
      },
      documentation = { 
          -- cmp.config.window.bordered(),
          border='rounded',
        winhighlight= 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:CursorLine,Search:None',
    }
},
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      -- { name = 'vsnip' }, -- For vsnip users.
      { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
      { name = 'path' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' }, 
    }, {
      { name = 'buffer' },
    })
  })


    cmp.setup.filetype('markdown', {
        sources = cmp.config.sources({
            { name = 'luasnip' },
            { name = 'path' },
            { name = 'buffer' },
            { name = 'nvim_lsp' },
            { name = 'spell' } -- move spell to the bottom so it doesnt slow it down that much
        })
    })
  cmp.setup.cmdline({ '/', '?'}, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    -- mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

local capabilities = require('cmp_nvim_lsp').default_capabilities()
  require('lspconfig')['bashls'].setup {
    capabilities = capabilities
  }
  require('lspconfig')['marksman'].setup {
    capabilities = capabilities
  }
  require('lspconfig')['clangd'].setup {
    capabilities = capabilities
  }
