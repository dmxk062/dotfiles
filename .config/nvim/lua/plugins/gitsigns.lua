local M = {
    "lewis6991/gitsigns.nvim",
}

M.config = function()
    local gitsigns = require("gitsigns")

    gitsigns.setup {
        signs = {
            add          = { text = "│" },
            change       = { text = "│" },
            delete       = { text = "_" },
            topdelete    = { text = "-" },
            changedelete = { text = "~" },
            untracked    = { text = "." },
        },

        preview_config = {
            border = "rounded",
        },

        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "right_align",
            delay = 200,
        },

        current_line_blame_formatter = "<author>, <author_time:%Y/%m/%d> - <summary>",

        on_attach = function(bufnr)
            local utils = require("utils")
            local prefix = "<space>g"

            utils.lmap(bufnr, "n", prefix .. "t", gitsigns.toggle_signs)
            utils.lmap(bufnr, "n", prefix .. "d", function() gitsigns.diffthis(nil, {split = "botright"}) end)
            utils.lmap(bufnr, "n", prefix .. "p", gitsigns.preview_hunk)
            utils.lmap(bufnr, "n", prefix .. "D", function() gitsigns.diffthis("~", {split = "botright"}) end)
            utils.lmap(bufnr, "n", prefix .. "b", gitsigns.blame_line)
            utils.lmap(bufnr, "n", prefix .. "B", gitsigns.toggle_current_line_blame)

            utils.lmap(bufnr, "n", prefix .. "s", gitsigns.stage_hunk)
            utils.lmap(bufnr, "n", prefix .. "u", gitsigns.undo_stage_hunk)
            utils.lmap(bufnr, "n", prefix .. "R", gitsigns.reset_hunk)

            utils.lmap(bufnr, "n", prefix .. "w", gitsigns.toggle_word_diff)
            utils.lmap(bufnr, "n", prefix .. "r", gitsigns.toggle_deleted)

            utils.lmap(bufnr, { "x", "o" }, "igh", "<cmd>Gitsigns select_hunk<cr>")
        end,
    }
end

return M
