local utils = require("utils")


local function map(mode, keys, action, opts) 
    vim.keymap.set(mode, keys, action, opts or {})
end


local function abbrev(mode, keys, string)
    vim.api.nvim_command(mode .. "abbrev" .. " " .. keys .. " " .. string)
end

-- move between windows more efficiently, i rarely use W anyways
map("n", "Wj", "<C-w>j")
map("n", "Wk", "<C-w>k")
map("n", "Wh", "<C-w>h")
map("n", "Wl", "<C-w>l")

map("n", "WJ", "<C-w>J")
map("n", "WK", "<C-w>K")
map("n", "WH", "<C-w>H")
map("n", "WL", "<C-w>L")


local tab_winleader = ","
-- tabs 1 - 9
for i=1, 9 do
    map("n", tab_winleader .. i, i .. "gt", {silent = true})
end

map("n", tab_winleader .. "h", function() vim.api.nvim_command("tabprevious") end)
map("n", tab_winleader .. "l", function() vim.api.nvim_command("tabnext") end)
map("n", tab_winleader .. "t", ":tabnew ")

map("n", tab_winleader .. "v", ":vsp ")
map("n", tab_winleader .. "s", ":sp ")


-- faster to exit
map("n", "q", ":q<CR>")
abbrev("c", "Q", "q!")

-- shortcuts for some stuff i toggle often
abbrev("c", "mo", "set mouse=a")
abbrev("c", "mf", "set mouse=")

abbrev("c", "spen", "setlocal spell spellang=en_us")
abbrev("c", "spde", "setlocal spell spellang=de_at")
abbrev("c", "spoff", "setlocal spell& spellang&")

-- open a kitty terminal window
map("n", " T", function() utils.kitty_new_dir(vim.fn.expand("%:p:h"), "window") end)
