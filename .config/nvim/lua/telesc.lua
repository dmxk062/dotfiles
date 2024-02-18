local telescope = require("telescope")
telescope.load_extension('fzf')
telescope.setup {
    defaults = {
        layout_strategy = 'vertical',
        layout_config = {
          vertical = { width = 0.4 }
            }
  },
  pickers = {
      lsp_definitions = {
        jump_type="tab"
      }
  },
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    },
  }
}
local builtin = require('telescope.builtin')
vim.keymap.set('n', 'gr', builtin.lsp_references, {})
vim.keymap.set('n', 'gd', builtin.lsp_definitions, {})
vim.keymap.set('n', 'gD', builtin.diagnostics, {})

