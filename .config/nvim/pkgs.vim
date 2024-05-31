call plug#begin()
Plug 'nvim-lualine/lualine.nvim'
Plug 'kylechui/nvim-surround'

Plug 'ggandor/leap.nvim'
Plug 'ggandor/leap-spooky.nvim'

Plug 'tpope/vim-repeat'
Plug 'numToStr/Comment.nvim'

Plug 'iamcco/markdown-preview.nvim', {'do': 'cd app && yarn install' }
" Plug 'MeanderingProgrammer/markdown.nvim'
Plug 'lukas-reineke/headlines.nvim'

Plug 'NvChad/nvim-colorizer.lua'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'nvim-lua/plenary.nvim'
Plug 'm4xshen/autoclose.nvim'
Plug 'neovim/nvim-lspconfig'

Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-path'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'f3fora/cmp-spell'

Plug 'micangl/cmp-vimtex'
Plug 'lervag/vimtex'
Plug 'onsails/lspkind.nvim'
Plug 'L3MON4D3/LuaSnip', {'do': 'make install_jsregexp'}
" Plug 'tamago324/cmp-zsh'
Plug 'kevinhwang91/nvim-ufo', {'branch': 'main'}
Plug 'kevinhwang91/promise-async'
Plug 'luukvbaal/statuscol.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'jose-elias-alvarez/typescript.nvim'
Plug 'b0o/schemastore.nvim'
Plug 'rafamadriz/friendly-snippets'
Plug 'gbrlsnchs/telescope-lsp-handlers.nvim'
Plug 'nvim-telescope/telescope-ui-select.nvim'
Plug 'rafcamlet/tabline-framework.nvim'

Plug 'stevearc/oil.nvim'
Plug 'refractalize/oil-git-status.nvim'
Plug 'lewis6991/gitsigns.nvim'

Plug 'startup-nvim/startup.nvim'
Plug 'goolord/alpha-nvim'
call plug#end()
