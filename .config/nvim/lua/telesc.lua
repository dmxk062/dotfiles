local telescope = require("telescope")
local themes = require("telescope.themes")
-- telescope.load_extension('fzf')
telescope.setup {
    defaults = {
        dynamic_preview_title = true,
        results_title = false,
        selection_caret = "> ",
        prompt_prefix = " ",
  },
  pickers = {
      lsp_definitions = {
          jump_type="tab",
          theme = "ivy",
      },
      diagnostics = {
          theme = "ivy",
      },
      find_files = {
          theme = "ivy",
          layout_config = {
              height = .3,
          }
      },
      live_grep = {
          theme = "ivy",
      },
      registers = {
          theme = "cursor",
      },
      lsp_references = {
          theme = "ivy",
      },
  },
  extensions = {
    ["ui-select"] = {
        themes.get_cursor {},
    },
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
    },
  }
}
local builtin = require('telescope.builtin')
vim.keymap.set('n', 'gr', builtin.lsp_references)
vim.keymap.set('n', 'gd', builtin.lsp_definitions)
vim.keymap.set('n', ' D', builtin.diagnostics)
vim.keymap.set('n', ',F', builtin.find_files)
vim.keymap.set('n', ',S', builtin.live_grep)
vim.keymap.set('n', ',R', builtin.registers)
-- and for insert too
function register_and_insert()
    builtin.registers()
    vim.cmd('startinsert')
end
vim.keymap.set('i', '<C-R>', register_and_insert)

-- vim.keymap.set('n', '<space>a', builtin.)
require("telescope").load_extension("ui-select")

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argv(0) == "" then
      builtin.find_files({theme = "ivy", layout_config = { height = .8}})
    end
  end,
})
