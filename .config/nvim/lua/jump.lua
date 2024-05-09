local leap = require("leap")
local utils = require("utils")

-- Super Jump, plain <s> and <S> are already taken by surround
utils.map("n", "s", "<Plug>(leap)")
utils.map("n", "S", "<Plug>(leap-from-window)")
utils.map({"x", "o"}, "S", "<Plug>(leap-forward)")
