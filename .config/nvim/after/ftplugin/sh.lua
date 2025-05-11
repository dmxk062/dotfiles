local map = require("config.utils").local_mapper(0)

-- easily insert pipelines
map("i", "<M-\\>", "<esc>A\\<esc>o| ", { desc = "Insert pipe on new line" })
map("n", "<localleader>o", "A\\<esc>o| ", { desc = "Insert pipe on new line" })
