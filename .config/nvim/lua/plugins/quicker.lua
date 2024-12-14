local M = {
    "stevearc/quicker.nvim",
    event = "FileType qf",
}

M.opts = {
   opts = {
       buflisted = true,
       signcolumn = "no",
   },
   type_icons = {
       E = "E",
       W = "W",
       I = "I",
       H = "H",
       N = ".",
   },
   borders = {
        vert = "│",

   },
}

return M
