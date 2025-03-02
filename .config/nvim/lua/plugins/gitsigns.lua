local M = {
    "lewis6991/gitsigns.nvim",
}

M.opts = {
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

    diff_opts = {
        vertical = true,
    },
}

M.config = function(_, opts)
    local gitsigns = require("gitsigns")
    opts.on_attach = function(bufnr)
        local utils = require("config.utils")
        local map = utils.local_mapper(bufnr, "<space>g")

        map("n", "t", gitsigns.toggle_signs)
        map("n", "p", gitsigns.preview_hunk)

        -- use fugitive cause its just better :(
        map("n", "d", "<cmd>rightbelow Gvdiffsplit<cr>")
        map("n", "D", "<cmd>rightbelow Gvdiffsplit !<cr>")
        map("n", "v", "<cmd>rightbelow Gdiffsplit<cr>")
        map("n", "V", "<cmd>rightbelow Gdiffsplit<cr>")

        map("n", "b", gitsigns.blame_line)
        map("n", "B", gitsigns.blame)
        map("n", "q", gitsigns.setqflist)
        map("n", "l", gitsigns.setloclist)

        map("n", "s", gitsigns.stage_hunk)
        map("n", "u", gitsigns.undo_stage_hunk)
        map("n", "U", gitsigns.reset_hunk)

        map("n", "w", gitsigns.toggle_word_diff)
        map("n", "r", gitsigns.toggle_deleted)

        utils.map({ "x", "o" }, "ig", gitsigns.select_hunk, { buffer = bufnr })
    end

    gitsigns.setup(opts)
end

return M
