local utils = require("utils")


-- move between windows more efficiently, i rarely use W anyways
-- also allows me to use <C-w> in kitty
utils.map("n", "W", "<C-w>")

-- for some reason smth else remaps those 
utils.map("i", "<M-k>", "<esc>k")
utils.map("i", "<M-j>", "<esc>j")


local tab_winleader = ","
-- tabs 1 - 9
for i = 1, 9 do
    utils.map("n", tab_winleader .. i, i .. "gt", { silent = true })
end

utils.map("n", tab_winleader .. "h", function() vim.api.nvim_command("tabprevious") end)
utils.map("n", tab_winleader .. "l", function() vim.api.nvim_command("tabnext") end)
utils.map("n", tab_winleader .. "t", ":tabnew ")

utils.map("n", tab_winleader .. "v", ":vsp ")
utils.map("n", tab_winleader .. "s", ":sp ")



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

-- evaluate lua and insert result
utils.map("n", "<space>el", utils.insert_eval_lua)
