local utils = require("utils")
local textobj = require("textobjs")


-- move between windows more efficiently, i rarely use W anyways
-- also allows me to use <C-w> in kitty
utils.map("n", "W", "<C-w>")

-- for some reason smth else remaps those 
utils.map("i", "<M-k>", "<esc>k")
utils.map("i", "<M-j>", "<esc>j")


local winleader = ","
-- tabs 1 - 9
for i = 1, 9 do
    utils.map("n", winleader .. i, i .. "gt", { silent = true })
end

utils.map("n", winleader .. "h", "<cmd>tabprevious<cr>")
utils.map("n", winleader .. "l", "<cmd>tabnext<cr>")
utils.map("n", winleader .. "t", ":tabnew ")

utils.map("n", winleader .. "v", ":vsp ")
utils.map("n", winleader .. "s", ":sp ")



-- faster to exit
utils.map("n", "q", ":q<CR>")
utils.abbrev("c", "Q", "q!")

-- shortcuts for some stuff i toggle often
utils.abbrev("c", "mo", "set mouse=a")
utils.abbrev("c", "mf", "set mouse=")

utils.abbrev("c", "spen", "setlocal spell spelllang=en_us")
utils.abbrev("c", "spde", "setlocal spell spelllang=de_at")
utils.abbrev("c", "spoff", "setlocal spell& spelllang&")

-- open a shell in a kitty window of some kind
-- works even for remote oil buffers via ssh
local shellleader = "<space>s"
utils.map("n", shellleader .. "w", function()
    utils.kitty_shell_in(vim.fn.expand("%:p:h"), "window")
end)
utils.map("n", shellleader .. "v", function()
    utils.kitty_shell_in(vim.fn.expand("%:p:h"), "window", {location = "vsplit"})
end)
utils.map("n", shellleader .. "s", function()
    utils.kitty_shell_in(vim.fn.expand("%:p:h"), "window", {location = "hsplit"})
end)
utils.map("n", shellleader .. "W", function()
    utils.kitty_shell_in(vim.fn.expand("%:p:h"), "os-window")
end)
utils.map("n", shellleader .. "t", function()
    utils.kitty_shell_in(vim.fn.expand("%:p:h"), "tab")
end)
utils.map("n", shellleader .. "o", function()
    utils.kitty_shell_in(vim.fn.expand("%:p:h"), "overlay")
end)

-- evaluate lua and insert result, expr=true needed for repeat
utils.map("n", "<space>el", utils.insert_eval_lua, {expr = true})


-- my own custom textobjects

-- useful characters for csv, paths and long chains of method calls
for _, char in ipairs({",", "/", "."}) do
    textobj.create_delim_obj(char, char)
end

-- numbers
-- without periods and minus
utils.map({"x", "o"}, "in", function()
    textobj.pattern("%d+")
end)
-- with periods and minus
utils.map({"x", "o"}, "an", function()
    textobj.pattern("%-?%d*%.?%d+")
end)
