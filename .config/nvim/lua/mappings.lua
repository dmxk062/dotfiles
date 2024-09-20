local utils = require("utils")

-- move between windows more efficiently, i rarely use W anyways
-- still works in o pending etc
-- also allows me to use <C-w> in kitty for the same purpose
-- utils.map("n", "W", "<C-w>")

-- less annoying way to exit terminal mode
utils.map("t", "<S-Esc>", "<C-\\><C-n>")

-- for some reason smth else remaps those 
utils.map("i", "<M-k>", "<esc>k")
utils.map("i", "<M-j>", "<esc>j")

local tableader = "\\"

-- tabs 1 - 9
for i = 1, 9 do
    utils.map("n", tableader .. i, i .. "gt", { silent = true })
end

utils.map("n", tableader .. "h", "<cmd>tabprevious<cr>")
utils.map("n", tableader .. "l", "<cmd>tabnext<cr>")

utils.map("n", tableader .. "t", ":tabnew ")
utils.map("n", tableader .. "v", ":vsp ")
utils.map("n", tableader .. "s", ":sp ")

-- stop {} from polluting the jumplist
utils.map({"x", "o", "n"}, "{", "<cmd>keepj normal!{<cr>", {remap = false})
utils.map({"x", "o", "n"}, "}", "<cmd>keepj normal!}<cr>", {remap = false})

-- use <space>@ for macros instead, i dont use them that often
utils.map("n", "<space>@", "q", {})

-- faster to exit
utils.map("n", "q", "<cmd>q<CR>")
utils.abbrev("c", "Q", "q!")

-- shortcuts to enable/disable spelling
utils.abbrev("c", "spen", "setlocal spell spelllang=en_us")
utils.abbrev("c", "spde", "setlocal spell spelllang=de_at")
utils.abbrev("c", "spoff", "setlocal spell& spelllang&")

-- open a shell in a kitty window of some kind
-- works even for remote oil buffers via ssh
local shellleader = "<space>s"
utils.map("n", shellleader .. "w", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "window") end)
utils.map("n", shellleader .. "v", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "window", {location = "vsplit"}) end)
utils.map("n", shellleader .. "s", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "window", {location = "hsplit"}) end)
utils.map("n", shellleader .. "W", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "os-window") end)
utils.map("n", shellleader .. "t", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "tab") end)
utils.map("n", shellleader .. "o", function() utils.kitty_shell_in(vim.fn.expand("%:p:h"), "overlay") end)

-- exit terminal mode with a single chord instead of 2
utils.map("t", "<C-Esc>", "<C-\\><C-n>")


-- my own custom textobjects
local textobjs = require("textobjs")


-- move between diagnostics, shortcuts for textobjects are in ./plugins/lspconfig.lua, since those just work with lsp
-- these work with all diagnostics
utils.map("n", "<space>d", vim.diagnostic.open_float)

-- indents, very useful for e.g. python
-- skips lines with spaces and tries to generally be as simple to use as possible
-- a includes one line above and below
utils.map({"x", "o"}, "ii", function() textobjs.indent(false) end)
utils.map({"x", "o"}, "ai", function() textobjs.indent(true) end)

utils.map({"x", "o"}, "iS", function() textobjs.leap_selection(false) end)
utils.map({"x", "o"}, "aS", function() textobjs.leap_selection(true) end)

vim.api.nvim_create_user_command("MimeType", function(args)
    local type, err = require("mimetypes").get_mime(vim.fn.expand(args.args))
    if err then
        vim.notify(err, vim.log.levels.ERROR)
    else
        print(type)
    end
end, {
    desc = "Get the mimetype of a file",
    complete = "file",
    nargs = 1
})

local operators = require("operators")


-- evaluate lua and insert result in buffer
operators.map_function("<space>el", function (mode, region, get_content)
    local code = table.concat(get_content(), "\n") .. "\n"
    local result = vim.split(vim.inspect(loadstring(code)()), "\n")

    return result, region[1], region[2]
end)

-- evalute qalculate expression/math and insert result in buffer
operators.map_function("<space>eq", function (mode, region, get_content)
    local expressions = get_content()
    local result = vim.system({ "qalc", "-t", "-f", "-" }, { stdin = expressions }):wait().stdout
    if not result then
        return nil
    end

    local output = vim.split(result, "\n")
    return output, region[1], region[2]
end)
