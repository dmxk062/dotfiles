local utils = require("utils")


-- move between windows more efficiently, i rarely use W anyways
utils.map("n", "Wj", "<C-w>j")
utils.map("n", "Wk", "<C-w>k")
utils.map("n", "Wh", "<C-w>h")
utils.map("n", "Wl", "<C-w>l")

utils.map("n", "WJ", "<C-w>J")
utils.map("n", "WK", "<C-w>K")
utils.map("n", "WH", "<C-w>H")
utils.map("n", "WL", "<C-w>L")


local tab_winleader = ","
-- tabs 1 - 9
for i=1, 9 do
    utils.map("n", tab_winleader .. i, i .. "gt", {silent = true})
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

utils.abbrev("c", "spen", "setlocal spell spellang=en_us")
utils.abbrev("c", "spde", "setlocal spell spellang=de_at")
utils.abbrev("c", "spoff", "setlocal spell& spellang&")

-- open a kitty terminal window
--
utils.map("n", " sw", function()
    utils.kitty_new_dir(vim.fn.expand("%:p:h"), "window") 
end)
-- tab
utils.map("n", " st", function()
    utils.kitty_new_dir(vim.fn.expand("%:p:h"), "tab") 
end)
