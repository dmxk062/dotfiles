call plug#begin()
Plug 'nvim-lualine/lualine.nvim'
Plug 'ur4ltz/surround.nvim'
Plug 'kylechui/nvim-surround'
Plug 'ggandor/leap.nvim'
Plug 'tpope/vim-repeat'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'shaunsingh/nord.nvim'
Plug 'glepnir/nerdicons.nvim'
Plug 'numToStr/Comment.nvim'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
Plug 'NvChad/nvim-colorizer.lua'
Plug 'junegunn/fzf'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}
Plug 'nvim-lua/plenary.nvim'
Plug 'lukas-reineke/headlines.nvim'
Plug 'm4xshen/autoclose.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-path'
Plug 'onsails/lspkind.nvim'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'f3fora/cmp-spell'
Plug 'tamago324/cmp-zsh'
Plug 'kevinhwang91/nvim-ufo'
Plug 'kevinhwang91/promise-async'
Plug 'luukvbaal/statuscol.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'jose-elias-alvarez/typescript.nvim'
Plug 'b0o/schemastore.nvim'
Plug 'rafamadriz/friendly-snippets'
call plug#end()
