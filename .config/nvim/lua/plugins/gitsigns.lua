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
        local mapp = utils.local_mapper(bufnr, "<space>g")

        mapp("n", "t", gitsigns.toggle_signs)
        mapp("n", "p", gitsigns.preview_hunk)

        -- use fugitive cause its just better :(
        mapp("n", "d", "<cmd>rightbelow Gvdiffsplit<cr>")
        mapp("n", "D", "<cmd>rightbelow Gvdiffsplit !<cr>")
        mapp("n", "b", gitsigns.blame_line)
        mapp("n", "B", gitsigns.blame)
        mapp("n", "q", gitsigns.setqflist)
        mapp("n", "l", gitsigns.setloclist)

        mapp("n", "s", gitsigns.stage_hunk)
        mapp("n", "u", gitsigns.undo_stage_hunk)
        mapp("n", "R", gitsigns.reset_hunk)

        mapp("n", "w", gitsigns.toggle_word_diff)
        mapp("n", "r", gitsigns.toggle_deleted)

        utils.map({ "x", "o" }, "ig", gitsigns.select_hunk, { buffer = bufnr })
    end

    gitsigns.setup(opts)
end

return M
