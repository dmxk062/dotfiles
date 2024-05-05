local telescope = require("telescope")
local themes = require("telescope.themes")
-- telescope.load_extension('fzf')
telescope.setup {
    defaults = {
        mappings = {
            n = {
                ["t"] = "select_tab",
                ["e"] = "file_edit",
                ["s"] = "select_horizontal",
                ["v"] = "select_vertical",
                ["<enter>"] = "select_drop",
                ["<S-enter>"] = "select_tab_drop",
            },
            i = {
                ["<enter>"] = "select_drop",
                ["<S-enter>"] = "select_tab_drop",
            }
        },
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
          mappings = {
              n = {
                  ["e"] = "edit_register"
              }
          }
      },
      buffers = {
          theme = "dropdown",
          previewer = false,
          layout_config = {
              height = .2,
              width = .3,
          },
          mappings = {
              n = {
                  ["dd"] = "delete_buffer",
              }
          }
      },
      lsp_references = {
          theme = "ivy",
      },
  },
  extensions = {
    ["ui-select"] = {
        themes.get_cursor {
            layout_config = {
                height = 4,
                width = 60
            }
        },
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
local _prefix = "<space>"
vim.keymap.set('n', 'gr', builtin.lsp_references)
vim.keymap.set('n', 'gd', builtin.lsp_definitions)
vim.keymap.set('n', _prefix .. 'D', builtin.diagnostics)
vim.keymap.set('n', _prefix .. 'F', builtin.find_files)
vim.keymap.set('n', _prefix .. '/', builtin.live_grep)
vim.keymap.set('n', _prefix .. 'r', builtin.registers)
vim.keymap.set('n', _prefix .. '<space>', builtin.buffers)
-- and for insert too
function register_and_insert()
    builtin.registers()
    vim.cmd('startinsert')
end
vim.keymap.set('i', '<C-R>', register_and_insert)

-- vim.keymap.set('n', '<space>a', builtin.)
telescope.load_extension("ui-select")


vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argv(0) == "" then
      builtin.find_files({theme = "ivy", layout_config = { height = .8}})
    end
  end,
})
