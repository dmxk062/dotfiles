local leap = require("leap")
local utils = require("utils")

-- Super Jump, plain <s> and <S> are already taken by surround
utils.map("n", "sj", "<Plug>(leap)")
utils.map("n", "Sj", "<Plug>(leap-from-window)")
utils.map({"x", "o"}, "S", "<Plug>(leap-forward)")
