vim.o.showbreak = ""

local map = require("config.utils").local_mapper(vim.api.nvim_get_current_buf())
map("n", "j", "gj", { silent = true })
map("n", "k", "gk", { silent = true })
