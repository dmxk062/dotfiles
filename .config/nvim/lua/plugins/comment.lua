return {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function()
        local ft = require("Comment.ft")
        ft.hyprland = { "#%s" }
        require("Comment").setup()
    end,
}
